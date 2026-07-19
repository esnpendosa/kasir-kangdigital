<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\License;
use App\Models\KasirUser;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

class LicenseApiController extends Controller
{
    /**
     * Helper to get token from Authorization header or request body
     */
    private function getLicenseToken(Request $request)
    {
        $header = $request->header('Authorization');
        if ($header && preg_match('/Bearer\s(\S+)/', $header, $matches)) {
            return $matches[1];
        }
        return $request->input('token');
    }

    /**
     * POST /api/license/activate
     */
    public function activate(Request $request)
    {
        $request->validate([
            'license_key' => 'required|string',
            'device_id' => 'required|string',
            'app_version' => 'nullable|string',
            'platform' => 'nullable|string',
        ]);

        $licenseKey = $request->input('license_key');
        $deviceId = $request->input('device_id');
        $appVersion = $request->input('app_version');
        $platform = $request->input('platform');

        $license = License::where('license_key', $licenseKey)->first();

        if (!$license) {
            return response()->json([
                'success' => false,
                'message' => 'Kunci lisensi tidak ditemukan.'
            ], 404);
        }

        // Check if expired
        if ($license->status === 'expired' || ($license->expires_at && Carbon::parse($license->expires_at)->isPast())) {
            $license->update(['status' => 'expired']);
            return response()->json([
                'success' => false,
                'message' => 'Lisensi ini sudah kadaluarsa.'
            ], 400);
        }

        // Check/Add device ID
        $devices = [];
        if (!empty($license->device_id)) {
            $devices = explode(',', $license->device_id);
        }

        if (in_array($deviceId, $devices)) {
            // Already active on this device
            $token = $license->token ?? bin2hex(random_bytes(32));
        } else {
            // New device activation
            if (count($devices) >= $license->device_limit) {
                return response()->json([
                    'success' => false,
                    'message' => 'Batas maksimal perangkat tercapai (maksimal ' . $license->device_limit . ' perangkat).'
                ], 400);
            }
            $devices[] = $deviceId;
            $token = $license->token ?? bin2hex(random_bytes(32));
        }

        $activatedAt = $license->activated_at ?? now();
        $expiresAt = $license->expires_at;
        if ($expiresAt === null && $license->duration_type !== 'lifetime') {
            $expiresAt = now()->addYear(); // default fallback for non-lifetime
        }

        $license->update([
            'device_id' => implode(',', $devices),
            'app_version' => $appVersion,
            'platform' => $platform,
            'status' => 'active',
            'activated_at' => $activatedAt,
            'expires_at' => $expiresAt,
            'token' => $token,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Aktivasi berhasil.',
            'data' => [
                'license_key' => $license->license_key,
                'token' => $license->token,
                'status' => 'active',
                'device_ids' => $devices,
                'device_limit' => $license->device_limit,
                'activated_at' => $license->activated_at ? $license->activated_at->toIso8601String() : null,
                'expires_at' => $license->expires_at ? $license->expires_at->toIso8601String() : null,
            ]
        ]);
    }

    /**
     * POST /api/license/check
     */
    public function check(Request $request)
    {
        $request->validate([
            'device_id' => 'required|string',
        ]);

        $token = $this->getLicenseToken($request);
        $deviceId = $request->input('device_id');

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token otorisasi diperlukan.'
            ], 401);
        }

        $license = License::where('token', $token)->first();

        if (!$license) {
            return response()->json([
                'success' => false,
                'message' => 'Lisensi tidak valid.'
            ], 401);
        }

        $devices = [];
        if (!empty($license->device_id)) {
            $devices = explode(',', $license->device_id);
        }

        if (!in_array($deviceId, $devices)) {
            return response()->json([
                'success' => false,
                'message' => 'Lisensi tidak cocok dengan perangkat ini.'
            ], 401);
        }

        if ($license->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Lisensi tidak aktif.'
            ], 403);
        }

        if ($license->expires_at && Carbon::parse($license->expires_at)->isPast()) {
            $license->update(['status' => 'expired']);
            return response()->json([
                'success' => false,
                'message' => 'Lisensi sudah kadaluarsa.'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'license_key' => $license->license_key,
                'token' => $license->token,
                'status' => 'active',
                'device_ids' => $devices,
                'device_limit' => $license->device_limit,
                'activated_at' => $license->activated_at ? $license->activated_at->toIso8601String() : null,
                'expires_at' => $license->expires_at ? $license->expires_at->toIso8601String() : null,
            ]
        ]);
    }

    /**
     * POST /api/license/deactivate
     */
    public function deactivate(Request $request)
    {
        $request->validate([
            'device_id' => 'required|string',
        ]);

        $token = $this->getLicenseToken($request);
        $deviceId = $request->input('device_id');

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token otorisasi diperlukan.'
            ], 401);
        }

        $license = License::where('token', $token)->first();

        if (!$license) {
            return response()->json([
                'success' => false,
                'message' => 'Lisensi tidak ditemukan.'
            ], 404);
        }

        $devices = [];
        if (!empty($license->device_id)) {
            $devices = explode(',', $license->device_id);
        }

        if (!in_array($deviceId, $devices)) {
            return response()->json([
                'success' => false,
                'message' => 'Perangkat tidak terdaftar di lisensi ini.'
            ], 400);
        }

        // Remove device
        $devices = array_diff($devices, [$deviceId]);

        if (empty($devices)) {
            $license->update([
                'status' => 'inactive',
                'device_id' => null,
                'token' => null,
            ]);
        } else {
            $license->update([
                'device_id' => implode(',', $devices)
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Deaktivasi berhasil.'
        ]);
    }

    /**
     * POST /api/license/refresh
     */
    public function refresh(Request $request)
    {
        $token = $this->getLicenseToken($request);

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token otorisasi diperlukan.'
            ], 401);
        }

        $license = License::where('token', $token)->first();

        if (!$license || $license->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Lisensi tidak aktif atau tidak ditemukan.'
            ], 401);
        }

        // Generate a new token and update last checked
        $newToken = bin2hex(random_bytes(32));
        $license->update([
            'token' => $newToken
        ]);

        $devices = [];
        if (!empty($license->device_id)) {
            $devices = explode(',', $license->device_id);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'license_key' => $license->license_key,
                'token' => $license->token,
                'status' => 'active',
                'device_ids' => $devices,
                'device_limit' => $license->device_limit,
                'activated_at' => $license->activated_at ? $license->activated_at->toIso8601String() : null,
                'expires_at' => $license->expires_at ? $license->expires_at->toIso8601String() : null,
            ]
        ]);
    }

    /**
     * GET /api/version
     */
    public function version()
    {
        return response()->json([
            'latest_version' => '1.0.0',
            'download_url' => 'https://kangdigital.web.id/downloads/kasir_umkm.apk',
            'force_update' => false
        ]);
    }

    /**
     * GET /api/users
     * Sync users belonging to the authenticated license
     */
    public function users(Request $request)
    {
        $token = $this->getLicenseToken($request);

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token otorisasi diperlukan.'
            ], 401);
        }

        $license = License::where('token', $token)->first();

        if (!$license || $license->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Lisensi tidak aktif atau tidak ditemukan.'
            ], 401);
        }

        // Get users mapped to the schema required by Flutter
        $users = KasirUser::where('license_id', $license->id)
            ->get()
            ->map(function ($user) {
                return [
                    'username' => $user->username,
                    'display_name' => $user->name,
                    'password_hash' => $user->password,
                    'role' => $user->role,
                    'is_active' => (bool)$user->is_active,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }
}
