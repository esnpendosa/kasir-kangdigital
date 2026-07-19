<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\License;
use App\Models\Store;
use App\Models\CloudBackup;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Storage;

/**
 * BackupApiController
 * Mengelola backup/restore database dari Android ke server hPanel.
 *
 * File backup disimpan di: storage/app/backups/{store_id}/{filename}
 * Compatible dengan shared hosting hPanel (tidak butuh queue/websocket)
 * Max file size disesuaikan dengan batas PHP upload_max_filesize hosting.
 */
class BackupApiController extends Controller
{
    /**
     * Helper: Ambil token
     */
    private function getLicenseToken(Request $request): ?string
    {
        $header = $request->header('Authorization');
        if ($header && preg_match('/Bearer\s(\S+)/', $header, $matches)) {
            return $matches[1];
        }
        return $request->input('token');
    }

    /**
     * Helper: Validasi license dan store
     */
    private function validateStoreAccess(Request $request, $storeId): array
    {
        $token = $this->getLicenseToken($request);
        if (!$token) {
            return [null, null, response()->json(['success' => false, 'message' => 'Token diperlukan.'], 401)];
        }

        $license = License::where('token', $token)->first();
        if (!$license || $license->status !== 'active') {
            return [null, null, response()->json(['success' => false, 'message' => 'Lisensi tidak aktif.'], 401)];
        }

        if ($license->expires_at && Carbon::parse($license->expires_at)->isPast()) {
            $license->update(['status' => 'expired']);
            return [null, null, response()->json(['success' => false, 'message' => 'Lisensi kadaluarsa.'], 403)];
        }

        $store = Store::where('id', $storeId)->where('license_id', $license->id)->first();
        if (!$store) {
            return [null, null, response()->json(['success' => false, 'message' => 'Toko tidak ditemukan.'], 404)];
        }

        return [$license, $store, null];
    }

    /**
     * POST /api/backup/{store_id}/upload
     * Upload file backup (.db atau .zip) dari Android ke server
     *
     * Form-data:
     *   - backup_file: file binary
     *   - app_version: string (optional)
     *   - device_id: string (optional)
     *   - notes: string (optional)
     */
    public function upload(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $request->validate([
            'backup_file' => 'required|file|max:51200', // max 50MB
            'app_version' => 'nullable|string|max:20',
            'device_id' => 'nullable|string|max:100',
            'notes' => 'nullable|string|max:500',
        ]);

        $file = $request->file('backup_file');
        $originalName = $file->getClientOriginalName();
        $extension = $file->getClientOriginalExtension();

        // Validasi extension
        if (!in_array(strtolower($extension), ['db', 'zip', 'sqlite', 'bak'])) {
            return response()->json([
                'success' => false,
                'message' => 'Format file tidak didukung. Gunakan .db, .zip, .sqlite, atau .bak',
            ], 422);
        }

        // Generate nama file unik di server
        $timestamp = now()->format('Y-m-d_H-i-s');
        $filename = "backup_{$store->store_code}_{$timestamp}.{$extension}";
        $storagePath = "backups/{$store->id}";

        // Simpan file
        $file->storeAs($storagePath, $filename, 'local');

        // Hash file untuk verifikasi integritas
        $filePath = storage_path("app/{$storagePath}/{$filename}");
        $fileHash = md5_file($filePath);
        $fileSize = $file->getSize();

        // Simpan metadata ke database
        $backup = CloudBackup::create([
            'store_id' => $store->id,
            'filename' => $filename,
            'original_filename' => $originalName,
            'file_size' => $fileSize,
            'file_hash' => $fileHash,
            'backup_type' => 'full',
            'app_version' => $request->input('app_version'),
            'device_id' => $request->input('device_id'),
            'notes' => $request->input('notes'),
        ]);

        // Hapus backup lama jika lebih dari 5 (keep only latest 5)
        $oldBackups = CloudBackup::where('store_id', $store->id)
            ->orderByDesc('created_at')
            ->skip(5)
            ->take(100)
            ->get();

        foreach ($oldBackups as $old) {
            $oldPath = "backups/{$store->id}/{$old->filename}";
            if (Storage::disk('local')->exists($oldPath)) {
                Storage::disk('local')->delete($oldPath);
            }
            $old->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Backup berhasil diupload ke cloud.',
            'data' => [
                'id' => $backup->id,
                'filename' => $backup->filename,
                'file_size' => $backup->file_size_formatted,
                'file_hash' => $backup->file_hash,
                'created_at' => $backup->created_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * GET /api/backup/{store_id}/list
     * List semua backup file untuk toko ini
     */
    public function list(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $backups = CloudBackup::where('store_id', $store->id)
            ->orderByDesc('created_at')
            ->get()
            ->map(function ($backup) {
                return [
                    'id' => $backup->id,
                    'filename' => $backup->filename,
                    'original_filename' => $backup->original_filename,
                    'file_size' => $backup->file_size,
                    'file_size_formatted' => $backup->file_size_formatted,
                    'file_hash' => $backup->file_hash,
                    'app_version' => $backup->app_version,
                    'device_id' => $backup->device_id,
                    'notes' => $backup->notes,
                    'created_at' => $backup->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'success' => true,
            'store' => $store->store_name,
            'data' => $backups,
            'total' => $backups->count(),
        ]);
    }

    /**
     * GET /api/backup/{store_id}/download/{backup_id}
     * Download file backup dari server ke Android
     */
    public function download(Request $request, $storeId, $backupId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $backup = CloudBackup::where('id', $backupId)
            ->where('store_id', $store->id)
            ->first();

        if (!$backup) {
            return response()->json(['success' => false, 'message' => 'Backup tidak ditemukan.'], 404);
        }

        $filePath = "backups/{$store->id}/{$backup->filename}";

        if (!Storage::disk('local')->exists($filePath)) {
            return response()->json(['success' => false, 'message' => 'File backup tidak ditemukan di server.'], 404);
        }

        $fullPath = storage_path("app/{$filePath}");

        return response()->download($fullPath, $backup->original_filename, [
            'Content-Type' => 'application/octet-stream',
            'X-File-Hash' => $backup->file_hash,
            'X-File-Size' => $backup->file_size,
        ]);
    }

    /**
     * DELETE /api/backup/{store_id}/{backup_id}
     * Hapus backup tertentu
     */
    public function destroy(Request $request, $storeId, $backupId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $backup = CloudBackup::where('id', $backupId)->where('store_id', $store->id)->first();
        if (!$backup) {
            return response()->json(['success' => false, 'message' => 'Backup tidak ditemukan.'], 404);
        }

        $filePath = "backups/{$store->id}/{$backup->filename}";
        if (Storage::disk('local')->exists($filePath)) {
            Storage::disk('local')->delete($filePath);
        }
        $backup->delete();

        return response()->json(['success' => true, 'message' => 'Backup berhasil dihapus.']);
    }
}
