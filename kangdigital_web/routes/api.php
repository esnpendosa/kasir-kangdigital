<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LicenseApiController;
use App\Http\Controllers\StoreApiController;
use App\Http\Controllers\SyncApiController;
use App\Http\Controllers\BackupApiController;

/*
|--------------------------------------------------------------------------
| API Routes — kangdigital.web.id
|--------------------------------------------------------------------------
|
| Semua endpoint API untuk:
| 1. License & Membership (verifikasi lisensi Android)
| 2. Multi-Store Management (kelola banyak toko per lisensi)
| 3. Data Sync (produk, transaksi, pelanggan, dll)
| 4. Cloud Backup (upload/download backup SQLite)
|
| Autentikasi: semua endpoint butuh header:
|   Authorization: Bearer {license_token}
|
*/

// ─── 1. License & Membership ─────────────────────────────────────────────────
Route::prefix('license')->group(function () {
    Route::post('/activate', [LicenseApiController::class, 'activate']);
    Route::post('/check', [LicenseApiController::class, 'check']);
    Route::post('/deactivate', [LicenseApiController::class, 'deactivate']);
    Route::post('/refresh', [LicenseApiController::class, 'refresh']);
});

// App version check & member sync
Route::get('/version', [LicenseApiController::class, 'version']);
Route::get('/users', [LicenseApiController::class, 'users']);

// ─── 2. Multi-Store Management ───────────────────────────────────────────────
Route::prefix('stores')->group(function () {
    Route::get('/', [StoreApiController::class, 'index']);           // GET   /api/stores
    Route::post('/', [StoreApiController::class, 'store']);           // POST  /api/stores
    Route::put('/{storeId}', [StoreApiController::class, 'update']); // PUT   /api/stores/{id}
    Route::post('/{storeId}/sync-ping', [StoreApiController::class, 'syncPing']); // POST sync ping
});

// ─── 3. Data Sync (per toko) ─────────────────────────────────────────────────
Route::prefix('sync/{storeId}')->group(function () {
    // PUSH: Android → Server
    Route::post('/categories', [SyncApiController::class, 'pushCategories']);   // sync kategori
    Route::post('/products', [SyncApiController::class, 'pushProducts']);       // sync produk
    Route::post('/customers', [SyncApiController::class, 'pushCustomers']);     // sync pelanggan
    Route::post('/transactions', [SyncApiController::class, 'pushTransactions']); // sync transaksi
    Route::post('/expenses', [SyncApiController::class, 'pushExpenses']);       // sync pengeluaran
    Route::post('/suppliers', [SyncApiController::class, 'pushSuppliers']);     // sync supplier

    // PULL: Server → Android (restore / device baru)
    Route::get('/pull', [SyncApiController::class, 'pull']);                    // full pull all data

    // REPORT: Summary laporan
    Route::get('/report', [SyncApiController::class, 'report']);                // laporan omzet dll
});

// ─── 4. Cloud Backup ─────────────────────────────────────────────────────────
Route::prefix('backup/{storeId}')->group(function () {
    Route::post('/upload', [BackupApiController::class, 'upload']);             // upload backup
    Route::get('/list', [BackupApiController::class, 'list']);                  // list backups
    Route::get('/download/{backupId}', [BackupApiController::class, 'download']); // download backup
    Route::delete('/{backupId}', [BackupApiController::class, 'destroy']);     // hapus backup
});
