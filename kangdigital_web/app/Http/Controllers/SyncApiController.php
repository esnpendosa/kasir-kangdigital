<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\License;
use App\Models\Store;
use App\Models\SyncProduct;
use App\Models\SyncCategory;
use App\Models\SyncCustomer;
use App\Models\SyncTransaction;
use App\Models\SyncTransactionItem;
use App\Models\SyncExpense;
use App\Models\SyncSupplier;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * SyncApiController
 * Menangani sinkronisasi data dua arah antara Android (SQLite) dan server (MySQL).
 *
 * Strategi sinkronisasi:
 * - PUSH: Android kirim data ke server (upsert berdasarkan store_id + remote_id)
 * - PULL: Android minta semua data dari server (untuk restore/device baru)
 *
 * Compatible dengan shared hosting hPanel (tidak butuh queue worker / websocket)
 */
class SyncApiController extends Controller
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

    // ─── PUSH ENDPOINTS (Android → Server) ───────────────────────────────────

    /**
     * POST /api/sync/{store_id}/categories
     * Sinkronisasi kategori dari Android ke server (bulk upsert)
     */
    public function pushCategories(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $request->validate([
            'data' => 'required|array',
            'data.*.id' => 'required|integer',
            'data.*.name' => 'required|string',
        ]);

        $synced = 0;
        DB::transaction(function () use ($request, $store, &$synced) {
            foreach ($request->input('data') as $item) {
                SyncCategory::updateOrCreate(
                    ['store_id' => $store->id, 'remote_id' => $item['id']],
                    [
                        'name' => $item['name'],
                        'color' => $item['color'] ?? null,
                        'icon' => $item['icon'] ?? null,
                        'is_active' => $item['is_active'] ?? true,
                        'synced_at' => now(),
                    ]
                );
                $synced++;
            }
        });

        $store->update(['last_synced_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Berhasil sync {$synced} kategori.",
            'synced' => $synced,
            'server_time' => now()->toIso8601String(),
        ]);
    }

    /**
     * POST /api/sync/{store_id}/products
     * Sinkronisasi produk dari Android ke server (bulk upsert)
     */
    public function pushProducts(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $request->validate([
            'data' => 'required|array',
            'data.*.id' => 'required|integer',
            'data.*.name' => 'required|string',
        ]);

        $synced = 0;
        DB::transaction(function () use ($request, $store, &$synced) {
            foreach ($request->input('data') as $item) {
                SyncProduct::updateOrCreate(
                    ['store_id' => $store->id, 'remote_id' => $item['id']],
                    [
                        'remote_category_id' => $item['category_id'] ?? null,
                        'name' => $item['name'],
                        'sku' => $item['sku'] ?? null,
                        'barcode' => $item['barcode'] ?? null,
                        'price' => $item['selling_price'] ?? $item['price'] ?? 0,
                        'cost_price' => $item['buying_price'] ?? $item['cost_price'] ?? 0,
                        'stock' => $item['stock'] ?? 0,
                        'min_stock' => $item['reorder_point'] ?? $item['min_stock'] ?? 0,
                        'unit' => $item['unit'] ?? 'pcs',
                        'description' => $item['description'] ?? null,
                        'image_url' => $item['image_url'] ?? null,
                        'is_active' => $item['is_active'] ?? true,
                        'synced_at' => now(),
                    ]
                );
                $synced++;
            }
        });

        $store->update(['last_synced_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Berhasil sync {$synced} produk.",
            'synced' => $synced,
            'server_time' => now()->toIso8601String(),
        ]);
    }

    /**
     * POST /api/sync/{store_id}/customers
     * Sinkronisasi pelanggan dari Android ke server
     */
    public function pushCustomers(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $request->validate([
            'data' => 'required|array',
            'data.*.id' => 'required|integer',
            'data.*.name' => 'required|string',
        ]);

        $synced = 0;
        DB::transaction(function () use ($request, $store, &$synced) {
            foreach ($request->input('data') as $item) {
                SyncCustomer::updateOrCreate(
                    ['store_id' => $store->id, 'remote_id' => $item['id']],
                    [
                        'name' => $item['name'],
                        'phone' => $item['phone'] ?? null,
                        'email' => $item['email'] ?? null,
                        'address' => $item['address'] ?? null,
                        'points' => $item['loyalty_points'] ?? $item['points'] ?? 0,
                        'total_spent' => $item['total_spent'] ?? 0,
                        'synced_at' => now(),
                    ]
                );
                $synced++;
            }
        });

        $store->update(['last_synced_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Berhasil sync {$synced} pelanggan.",
            'synced' => $synced,
            'server_time' => now()->toIso8601String(),
        ]);
    }

    /**
     * POST /api/sync/{store_id}/transactions
     * Sinkronisasi transaksi dari Android ke server (dengan items)
     */
    public function pushTransactions(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $request->validate([
            'data' => 'required|array',
            'data.*.id' => 'required|integer',
            'data.*.total_amount' => 'nullable|numeric',
        ]);

        $synced = 0;
        $errors = [];

        DB::transaction(function () use ($request, $store, &$synced, &$errors) {
            foreach ($request->input('data') as $item) {
                try {
                    $transaction = SyncTransaction::updateOrCreate(
                        ['store_id' => $store->id, 'remote_id' => $item['id']],
                        [
                            'remote_customer_id' => $item['customer_id'] ?? null,
                            'invoice_no' => $item['invoice_number'] ?? $item['invoice_no'] ?? null,
                            'cashier_username' => $item['cashier_name'] ?? $item['cashier_username'] ?? null,
                            'subtotal' => $item['subtotal'] ?? 0,
                            'discount_amount' => $item['discount_amount'] ?? 0,
                            'tax_amount' => $item['tax_amount'] ?? 0,
                            'total' => $item['total_amount'] ?? $item['total'] ?? 0,
                            'paid_amount' => $item['amount_paid'] ?? $item['paid_amount'] ?? 0,
                            'change_amount' => $item['change_amount'] ?? 0,
                            'payment_method' => $item['payment_method'] ?? 'cash',
                            'status' => $item['status'] ?? 'completed',
                            'notes' => $item['note'] ?? $item['notes'] ?? null,
                            'sold_at' => isset($item['date']) ? Carbon::parse($item['date']) : now(),
                            'synced_at' => now(),
                        ]
                    );

                    // Sync items jika ada
                    if (!empty($item['items'])) {
                        // Hapus items lama dan insert baru
                        SyncTransactionItem::where('transaction_id', $transaction->id)->delete();
                        foreach ($item['items'] as $saleItem) {
                            SyncTransactionItem::create([
                                'transaction_id' => $transaction->id,
                                'remote_product_id' => $saleItem['product_id'] ?? null,
                                'product_name' => $saleItem['product_name'] ?? 'Produk',
                                'product_sku' => $saleItem['product_sku'] ?? null,
                                'price' => $saleItem['unit_price'] ?? $saleItem['price'] ?? 0,
                                'cost_price' => $saleItem['cost_price'] ?? 0,
                                'quantity' => $saleItem['quantity'] ?? 1,
                                'discount' => $saleItem['discount'] ?? 0,
                                'subtotal' => $saleItem['subtotal'] ?? 0,
                            ]);
                        }
                    }

                    $synced++;
                } catch (\Exception $e) {
                    $errors[] = ['id' => $item['id'], 'error' => $e->getMessage()];
                }
            }
        });

        $store->update(['last_synced_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Berhasil sync {$synced} transaksi.",
            'synced' => $synced,
            'errors' => $errors,
            'server_time' => now()->toIso8601String(),
        ]);
    }

    /**
     * POST /api/sync/{store_id}/expenses
     * Sinkronisasi pengeluaran dari Android ke server
     */
    public function pushExpenses(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $request->validate([
            'data' => 'required|array',
            'data.*.id' => 'required|integer',
        ]);

        $synced = 0;
        DB::transaction(function () use ($request, $store, &$synced) {
            foreach ($request->input('data') as $item) {
                SyncExpense::updateOrCreate(
                    ['store_id' => $store->id, 'remote_id' => $item['id']],
                    [
                        'category' => $item['category'] ?? 'umum',
                        'description' => $item['description'] ?? null,
                        'amount' => $item['amount'] ?? 0,
                        'payment_method' => $item['payment_method'] ?? 'cash',
                        'cashier_username' => $item['cashier_name'] ?? null,
                        'expense_date' => isset($item['date']) ? Carbon::parse($item['date']) : now(),
                        'synced_at' => now(),
                    ]
                );
                $synced++;
            }
        });

        $store->update(['last_synced_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Berhasil sync {$synced} pengeluaran.",
            'synced' => $synced,
            'server_time' => now()->toIso8601String(),
        ]);
    }

    /**
     * POST /api/sync/{store_id}/suppliers
     * Sinkronisasi supplier dari Android ke server
     */
    public function pushSuppliers(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $request->validate([
            'data' => 'required|array',
            'data.*.id' => 'required|integer',
            'data.*.name' => 'required|string',
        ]);

        $synced = 0;
        DB::transaction(function () use ($request, $store, &$synced) {
            foreach ($request->input('data') as $item) {
                SyncSupplier::updateOrCreate(
                    ['store_id' => $store->id, 'remote_id' => $item['id']],
                    [
                        'name' => $item['name'],
                        'phone' => $item['phone'] ?? null,
                        'email' => $item['email'] ?? null,
                        'address' => $item['address'] ?? null,
                        'contact_person' => $item['contact_person'] ?? null,
                        'notes' => $item['notes'] ?? null,
                        'is_active' => $item['is_active'] ?? true,
                        'synced_at' => now(),
                    ]
                );
                $synced++;
            }
        });

        $store->update(['last_synced_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Berhasil sync {$synced} supplier.",
            'synced' => $synced,
            'server_time' => now()->toIso8601String(),
        ]);
    }

    // ─── PULL ENDPOINT (Server → Android) ────────────────────────────────────

    /**
     * GET /api/sync/{store_id}/pull
     * Ambil SEMUA data dari server untuk restore ke device baru atau full sync
     * Parameter opsional: ?since=2024-01-01T00:00:00Z (hanya data setelah tanggal ini)
     */
    public function pull(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $since = $request->query('since');
        $sinceDate = $since ? Carbon::parse($since) : null;

        $query = fn($model) => $sinceDate
            ? $model->where('updated_at', '>=', $sinceDate)
            : $model;

        $categories = $query(SyncCategory::where('store_id', $store->id))->get();
        $products = $query(SyncProduct::where('store_id', $store->id))->get();
        $customers = $query(SyncCustomer::where('store_id', $store->id))->get();
        $suppliers = $query(SyncSupplier::where('store_id', $store->id))->get();
        $transactions = $query(SyncTransaction::where('store_id', $store->id))
            ->with('items')
            ->get();
        $expenses = $query(SyncExpense::where('store_id', $store->id))->get();

        return response()->json([
            'success' => true,
            'store' => [
                'id' => $store->id,
                'store_name' => $store->store_name,
                'store_code' => $store->store_code,
                'currency' => $store->currency,
                'currency_symbol' => $store->currency_symbol,
                'receipt_footer' => $store->receipt_footer,
            ],
            'data' => [
                'categories' => $categories,
                'products' => $products,
                'customers' => $customers,
                'suppliers' => $suppliers,
                'transactions' => $transactions,
                'expenses' => $expenses,
            ],
            'counts' => [
                'categories' => $categories->count(),
                'products' => $products->count(),
                'customers' => $customers->count(),
                'suppliers' => $suppliers->count(),
                'transactions' => $transactions->count(),
                'expenses' => $expenses->count(),
            ],
            'server_time' => now()->toIso8601String(),
        ]);
    }

    // ─── REPORTS ENDPOINT ─────────────────────────────────────────────────────

    /**
     * GET /api/sync/{store_id}/report
     * Summary laporan toko: omzet, pengeluaran, produk terlaris
     * Parameter: ?from=2024-01-01&to=2024-01-31
     */
    public function report(Request $request, $storeId)
    {
        [$license, $store, $error] = $this->validateStoreAccess($request, $storeId);
        if ($error) return $error;

        $from = $request->query('from') ? Carbon::parse($request->query('from'))->startOfDay() : now()->startOfMonth();
        $to = $request->query('to') ? Carbon::parse($request->query('to'))->endOfDay() : now()->endOfDay();

        // Penjualan
        $salesQuery = SyncTransaction::where('store_id', $store->id)
            ->where('status', 'completed')
            ->whereBetween('sold_at', [$from, $to]);

        $totalRevenue = $salesQuery->sum('total');
        $totalTransactions = $salesQuery->count();
        $avgTransaction = $totalTransactions > 0 ? $totalRevenue / $totalTransactions : 0;

        // Pengeluaran
        $totalExpenses = SyncExpense::where('store_id', $store->id)
            ->whereBetween('expense_date', [$from, $to])
            ->sum('amount');

        // Produk terlaris (dari transaction items)
        $topProducts = DB::table('sync_transaction_items as si')
            ->join('sync_transactions as st', 'si.transaction_id', '=', 'st.id')
            ->where('st.store_id', $store->id)
            ->where('st.status', 'completed')
            ->whereBetween('st.sold_at', [$from, $to])
            ->select('si.product_name', DB::raw('SUM(si.quantity) as qty_sold'), DB::raw('SUM(si.subtotal) as revenue'))
            ->groupBy('si.product_name')
            ->orderByDesc('qty_sold')
            ->limit(10)
            ->get();

        // Metode pembayaran breakdown
        $paymentBreakdown = SyncTransaction::where('store_id', $store->id)
            ->where('status', 'completed')
            ->whereBetween('sold_at', [$from, $to])
            ->select('payment_method', DB::raw('COUNT(*) as count'), DB::raw('SUM(total) as total'))
            ->groupBy('payment_method')
            ->get();

        // Transaksi per hari (untuk grafik)
        $dailySales = SyncTransaction::where('store_id', $store->id)
            ->where('status', 'completed')
            ->whereBetween('sold_at', [$from, $to])
            ->select(
                DB::raw('DATE(sold_at) as date'),
                DB::raw('COUNT(*) as transactions'),
                DB::raw('SUM(total) as revenue')
            )
            ->groupBy(DB::raw('DATE(sold_at)'))
            ->orderBy('date')
            ->get();

        return response()->json([
            'success' => true,
            'store' => $store->store_name,
            'period' => [
                'from' => $from->toDateString(),
                'to' => $to->toDateString(),
            ],
            'summary' => [
                'total_revenue' => (float) $totalRevenue,
                'total_transactions' => $totalTransactions,
                'avg_transaction' => round((float) $avgTransaction, 2),
                'total_expenses' => (float) $totalExpenses,
                'net_profit' => (float) ($totalRevenue - $totalExpenses),
            ],
            'top_products' => $topProducts,
            'payment_breakdown' => $paymentBreakdown,
            'daily_sales' => $dailySales,
        ]);
    }
}
