<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\License;
use App\Models\Store;
use Illuminate\Support\Str;

/**
 * StoreApiController
 * Mengelola data toko (store) per lisensi.
 * Satu lisensi bisa punya BANYAK toko (multi-store).
 *
 * Semua endpoint butuh header: Authorization: Bearer {license_token}
 */
class StoreApiController extends Controller
{
    /**
     * Helper: Ambil token dari header atau body request
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
     * Helper: Validasi token dan kembalikan license aktif
     */
    private function getActiveLicense(Request $request): ?License
    {
        $token = $this->getLicenseToken($request);
        if (!$token) return null;

        $license = License::where('token', $token)->first();
        if (!$license || $license->status !== 'active') return null;

        // Cek expired
        if ($license->expires_at && \Carbon\Carbon::parse($license->expires_at)->isPast()) {
            $license->update(['status' => 'expired']);
            return null;
        }

        return $license;
    }

    /**
     * GET /api/stores
     * List semua toko milik lisensi yang aktif
     */
    public function index(Request $request)
    {
        $license = $this->getActiveLicense($request);
        if (!$license) {
            return response()->json(['success' => false, 'message' => 'Lisensi tidak valid atau tidak aktif.'], 401);
        }

        $stores = Store::where('license_id', $license->id)
            ->withCount(['products', 'transactions', 'customers'])
            ->get()
            ->map(function ($store) {
                return [
                    'id' => $store->id,
                    'store_name' => $store->store_name,
                    'store_code' => $store->store_code,
                    'address' => $store->address,
                    'phone' => $store->phone,
                    'email' => $store->email,
                    'currency' => $store->currency,
                    'currency_symbol' => $store->currency_symbol,
                    'receipt_footer' => $store->receipt_footer,
                    'is_active' => $store->is_active,
                    'last_synced_at' => $store->last_synced_at?->toIso8601String(),
                    'products_count' => $store->products_count,
                    'transactions_count' => $store->transactions_count,
                    'customers_count' => $store->customers_count,
                    'created_at' => $store->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $stores,
            'license_key' => $license->license_key,
        ]);
    }

    /**
     * POST /api/stores
     * Buat toko baru untuk lisensi ini
     */
    public function store(Request $request)
    {
        $license = $this->getActiveLicense($request);
        if (!$license) {
            return response()->json(['success' => false, 'message' => 'Lisensi tidak valid atau tidak aktif.'], 401);
        }

        $request->validate([
            'store_name' => 'required|string|max:255',
            'address' => 'nullable|string',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'currency' => 'nullable|string|max:10',
            'currency_symbol' => 'nullable|string|max:10',
            'receipt_footer' => 'nullable|string',
        ]);

        // Buat kode toko unik
        $storeCode = 'TOKO-' . strtoupper(Str::random(6));
        while (Store::where('store_code', $storeCode)->exists()) {
            $storeCode = 'TOKO-' . strtoupper(Str::random(6));
        }

        $store = Store::create([
            'license_id' => $license->id,
            'store_name' => $request->input('store_name'),
            'store_code' => $storeCode,
            'address' => $request->input('address'),
            'phone' => $request->input('phone'),
            'email' => $request->input('email'),
            'currency' => $request->input('currency', 'IDR'),
            'currency_symbol' => $request->input('currency_symbol', 'Rp'),
            'receipt_footer' => $request->input('receipt_footer'),
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Toko berhasil dibuat.',
            'data' => [
                'id' => $store->id,
                'store_name' => $store->store_name,
                'store_code' => $store->store_code,
            ],
        ], 201);
    }

    /**
     * PUT /api/stores/{store_id}
     * Update informasi toko
     */
    public function update(Request $request, $storeId)
    {
        $license = $this->getActiveLicense($request);
        if (!$license) {
            return response()->json(['success' => false, 'message' => 'Lisensi tidak valid.'], 401);
        }

        $store = Store::where('id', $storeId)
            ->where('license_id', $license->id)
            ->first();

        if (!$store) {
            return response()->json(['success' => false, 'message' => 'Toko tidak ditemukan.'], 404);
        }

        $store->update($request->only([
            'store_name', 'address', 'phone', 'email',
            'currency', 'currency_symbol', 'receipt_footer',
        ]));

        return response()->json(['success' => true, 'message' => 'Toko berhasil diperbarui.']);
    }

    /**
     * POST /api/stores/{store_id}/sync-ping
     * Update timestamp sinkronisasi toko
     */
    public function syncPing(Request $request, $storeId)
    {
        $license = $this->getActiveLicense($request);
        if (!$license) {
            return response()->json(['success' => false, 'message' => 'Lisensi tidak valid.'], 401);
        }

        $store = Store::where('id', $storeId)->where('license_id', $license->id)->first();
        if (!$store) {
            return response()->json(['success' => false, 'message' => 'Toko tidak ditemukan.'], 404);
        }

        $store->update(['last_synced_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Ping sinkronisasi berhasil.',
            'server_time' => now()->toIso8601String(),
        ]);
    }
}
