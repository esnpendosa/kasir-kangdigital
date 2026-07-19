import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/cloud_providers.dart';
import '../../../core/services/cloud_sync_service.dart';
import '../../../core/constants/app_strings.dart';

/// Cloud Sync Screen — Kelola sinkronisasi data dengan kangdigital.web.id
///
/// Fitur:
/// - Pilih toko aktif
/// - Push semua data ke server
/// - Pull data dari server (restore)
/// - Lihat status sinkronisasi terakhir
/// - Laporan ringkasan dari cloud
class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedStoreId;
  String? _selectedStoreName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storesAsync = ref.watch(storesProvider);
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Sinkronisasi Cloud',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'Toko'),
            Tab(icon: Icon(Icons.sync), text: 'Sync'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Laporan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ─── Tab 1: Pilih Toko ────────────────────────────────────────────
          _buildStoreTab(storesAsync),

          // ─── Tab 2: Sync ──────────────────────────────────────────────────
          _buildSyncTab(syncState),

          // ─── Tab 3: Laporan ───────────────────────────────────────────────
          _buildReportTab(),
        ],
      ),
    );
  }

  Widget _buildStoreTab(AsyncValue<List<Map<String, dynamic>>> storesAsync) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(storesProvider.future),
      child: storesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Tidak dapat terhubung ke server',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(e.toString(), style: const TextStyle(color: Colors.red, fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(storesProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              ),
            ],
          ),
        ),
        data: (stores) => Column(
          children: [
            // Status bar
            if (_selectedStoreId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF1A3A2A),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Toko aktif: $_selectedStoreName',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // Tombol Tambah Toko
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddStoreDialog(),
                  icon: const Icon(Icons.add_business, color: Color(0xFF6C63FF)),
                  label: const Text('Tambah Toko Baru', style: TextStyle(color: Color(0xFF6C63FF))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6C63FF)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

            // List Toko
            if (stores.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store_mall_directory_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada toko terdaftar', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Tap "Tambah Toko Baru" untuk memulai', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stores.length,
                  itemBuilder: (ctx, i) => _buildStoreCard(stores[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    final isSelected = _selectedStoreId == store['id'];
    return Card(
      color: isSelected ? const Color(0xFF1A1A3E) : const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.store, color: isSelected ? Colors.white : Colors.grey),
        ),
        title: Text(
          store['store_name'] ?? '-',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(store['store_code'] ?? '-', style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
            if (store['last_synced_at'] != null) ...[
              const SizedBox(height: 2),
              Text(
                'Sync terakhir: ${_formatDateTime(store['last_synced_at'])}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                _statChip('Produk', '${store['products_count'] ?? 0}'),
                const SizedBox(width: 8),
                _statChip('Transaksi', '${store['transactions_count'] ?? 0}'),
                const SizedBox(width: 8),
                _statChip('Pelanggan', '${store['customers_count'] ?? 0}'),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF6C63FF))
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () {
          setState(() {
            _selectedStoreId = store['id'];
            _selectedStoreName = store['store_name'];
          });
          ref.read(activeStoreIdProvider.notifier).state = store['id'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Toko "${store['store_name']}" dipilih'),
              backgroundColor: const Color(0xFF6C63FF),
            ),
          );
        },
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }

  Widget _buildSyncTab(SyncState syncState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildSyncStatusCard(syncState),
          const SizedBox(height: 20),

          // Store Check
          if (_selectedStoreId == null)
            _buildWarningCard(
              icon: Icons.store_outlined,
              title: 'Pilih Toko Terlebih Dahulu',
              message: 'Buka tab "Toko" dan pilih toko untuk disinkronisasi.',
            )
          else ...[
            // Push Section
            _buildSectionTitle('Push ke Server'),
            const SizedBox(height: 12),
            _buildSyncActionCard(
              icon: Icons.cloud_upload,
              title: 'Upload Semua Data',
              subtitle: 'Kirim produk, transaksi, pelanggan, dll ke server cloud',
              color: const Color(0xFF6C63FF),
              isLoading: syncState.isSyncing,
              onTap: syncState.isSyncing ? null : () => _pushAllData(),
            ),
            const SizedBox(height: 12),

            // Pull Section
            _buildSectionTitle('Pull dari Server'),
            const SizedBox(height: 12),
            _buildSyncActionCard(
              icon: Icons.cloud_download,
              title: 'Download Semua Data',
              subtitle: 'Restore data dari server (gunakan di device baru)',
              color: const Color(0xFF10B981),
              isLoading: syncState.isSyncing,
              onTap: syncState.isSyncing ? null : () => _pullAllData(),
            ),
            const SizedBox(height: 12),
            _buildSyncActionCard(
              icon: Icons.update,
              title: 'Sync Incremental',
              subtitle: 'Ambil data baru sejak sync terakhir saja',
              color: const Color(0xFFF59E0B),
              isLoading: syncState.isSyncing,
              onTap: syncState.isSyncing ? null : () => _pullIncrementalData(),
            ),

            // Last result
            if (syncState.lastResult != null) ...[
              const SizedBox(height: 20),
              _buildSectionTitle('Hasil Sync Terakhir'),
              const SizedBox(height: 12),
              _buildLastResultCard(syncState.lastResult!),
            ],

            if (syncState.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(syncState.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSyncStatusCard(SyncState syncState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A3E), Color(0xFF0F0F2A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: syncState.isSyncing
                  ? const Color(0xFF6C63FF).withAlpha(30)
                  : const Color(0xFF10B981).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: syncState.isSyncing
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C63FF)),
                  )
                : const Icon(Icons.cloud_done, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  syncState.isSyncing ? 'Sedang Sinkronisasi...' : 'Status Sinkronisasi',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                if (syncState.lastSyncedAt != null)
                  Text(
                    'Terakhir: ${_formatDateTime(syncState.lastSyncedAt!.toIso8601String())}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  )
                else
                  Text('Belum pernah sync', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isLoading,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            else
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLastResultCard(SyncResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
      ),
      child: Column(
        children: [
          _resultRow('Total', '${result.total} item', const Color(0xFF10B981)),
          _resultRow('Kategori', '${result.categories}', Colors.blue),
          _resultRow('Produk', '${result.products}', Colors.orange),
          _resultRow('Pelanggan', '${result.customers}', Colors.purple),
          _resultRow('Transaksi', '${result.transactions}', Colors.green),
          _resultRow('Pengeluaran', '${result.expenses}', Colors.red),
          _resultRow('Supplier', '${result.suppliers}', Colors.teal),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    if (_selectedStoreId == null) {
      return Center(
        child: _buildWarningCard(
          icon: Icons.bar_chart_outlined,
          title: 'Pilih Toko Terlebih Dahulu',
          message: 'Buka tab "Toko" dan pilih toko untuk melihat laporan.',
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: ref.read(cloudSyncServiceProvider).getReport(_selectedStoreId!),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
        }
        if (snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Tidak dapat memuat laporan', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final summary = data['summary'] as Map<String, dynamic>? ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Ringkasan ${data['store'] ?? ''} — Bulan Ini'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildSummaryCard('Omzet', 'Rp ${_formatNumber(summary['total_revenue'])}', Icons.trending_up, const Color(0xFF10B981)),
                  _buildSummaryCard('Transaksi', '${summary['total_transactions'] ?? 0}x', Icons.receipt_long, const Color(0xFF6C63FF)),
                  _buildSummaryCard('Pengeluaran', 'Rp ${_formatNumber(summary['total_expenses'])}', Icons.money_off, const Color(0xFFEF4444)),
                  _buildSummaryCard('Profit Bersih', 'Rp ${_formatNumber(summary['net_profit'])}', Icons.account_balance, const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard({required IconData icon, required String title, required String message}) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(80)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 48),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[400], fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2));
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _pushAllData() async {
    // TODO: Inject actual data from local database
    // Ini contoh push dengan data dummy untuk demo
    await ref.read(syncNotifierProvider.notifier).pushAll(
      storeId: _selectedStoreId!,
      categories: [], // ambil dari SQLite lokal
      products: [],
      customers: [],
      transactions: [],
      expenses: [],
      suppliers: [],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sinkronisasi selesai!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _pullAllData() async {
    final result = await ref.read(syncNotifierProvider.notifier).pullAll(_selectedStoreId!);
    if (mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil download ${result.totalRecords} data dari server'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _pullIncrementalData() async {
    final since = DateTime.now().subtract(const Duration(days: 7));
    final result = await ref.read(syncNotifierProvider.notifier).pullAll(_selectedStoreId!, since: since);
    if (mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incremental sync: ${result.totalRecords} data baru'),
          backgroundColor: const Color(0xFFF59E0B),
        ),
      );
    }
  }

  void _showAddStoreDialog() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Tambah Toko Baru', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(nameCtrl, 'Nama Toko *', Icons.store),
              const SizedBox(height: 12),
              _buildDialogField(addressCtrl, 'Alamat', Icons.location_on),
              const SizedBox(height: 12),
              _buildDialogField(phoneCtrl, 'No. Telepon', Icons.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);

              final syncService = ref.read(cloudSyncServiceProvider);
              final result = await syncService.createStore(
                storeName: nameCtrl.text,
                address: addressCtrl.text.isEmpty ? null : addressCtrl.text,
                phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
              );

              if (mounted) {
                if (result != null) {
                  ref.invalidate(storesProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Toko "${nameCtrl.text}" berhasil dibuat!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal membuat toko. Periksa koneksi.'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFF0F0F1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final num = double.tryParse(value.toString()) ?? 0;
    if (num >= 1000000000) return '${(num / 1000000000).toStringAsFixed(1)}M';
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}jt';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)}rb';
    return num.toStringAsFixed(0);
  }
}
