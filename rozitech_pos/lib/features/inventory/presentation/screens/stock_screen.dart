import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/domain/entities/product.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/stock_log.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Stok Saat Ini'),
            Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Stok Rendah'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _StockListTab(),
          _LowStockTab(),
          _StockHistoryTab(),
        ],
      ),
    );
  }
}

class _StockListTab extends ConsumerWidget {
  const _StockListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<Product>>(
      stream: ProductRepositoryImpl(db).watchProducts(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        final products = snap.data ?? [];
        if (products.isEmpty) {
          return const EmptyStateWidget(
            title: 'Belum ada produk',
            icon: Icons.inventory_2_outlined,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (ctx, i) {
            final p = products[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('SKU: ${p.sku}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StockBadge(qty: p.stockQuantity, min: p.minStockLevel),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Sesuaikan Stok',
                      onPressed: () =>
                          _showAdjustDialog(context, ref, p),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAdjustDialog(
      BuildContext context, WidgetRef ref, Product product) async {
    final qtyCtrl = TextEditingController();
    StockMovementType type = StockMovementType.stockIn;
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Sesuaikan Stok: ${product.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Stok saat ini: ${product.stockQuantity} ${product.unit}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<StockMovementType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Jenis'),
                  items: [
                    DropdownMenuItem(
                        value: StockMovementType.stockIn,
                        child: const Text('Stok Masuk')),
                    DropdownMenuItem(
                        value: StockMovementType.stockOut,
                        child: const Text('Stok Keluar')),
                    DropdownMenuItem(
                        value: StockMovementType.adjustment,
                        child: const Text('Penyesuaian')),
                  ],
                  onChanged: (v) => setS(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Diperlukan';
                    if (int.tryParse(v) == null) return 'Harus angka';
                    if (int.parse(v) <= 0) return 'Harus > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Alasan / Catatan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final db = ref.read(appDatabaseProvider);
                final repo = StockRepositoryImpl(db);
                int change = int.parse(qtyCtrl.text);
                if (type == StockMovementType.stockOut) change = -change;

                await repo.adjustStock(StockAdjustment(
                  productId: product.id!,
                  quantityChange: change,
                  movementType: type,
                  reason: reasonCtrl.text.isEmpty ? null : reasonCtrl.text,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.qty, required this.min});
  final int qty;
  final int min;

  @override
  Widget build(BuildContext context) {
    final isLow = qty <= min;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        qty.toString(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isLow ? Colors.red.shade700 : Colors.green.shade700,
        ),
      ),
    );
  }
}

class _LowStockTab extends ConsumerWidget {
  const _LowStockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<Product>>(
      stream: ProductRepositoryImpl(db).watchLowStockProducts(),
      builder: (ctx, snap) {
        final products = snap.data ?? [];
        if (products.isEmpty) {
          return const EmptyStateWidget(
            title: 'Semua stok mencukupi',
            subtitle: 'Tidak ada produk dengan stok rendah',
            icon: Icons.check_circle_outline_rounded,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (ctx, i) {
            final p = products[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red),
                title: Text(p.name),
                subtitle: Text('Min: ${p.minStockLevel} ${p.unit}'),
                trailing: Text(
                  '${p.stockQuantity} ${p.unit}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.red),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StockHistoryTab extends ConsumerWidget {
  const _StockHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<StockLog>>(
      stream: StockRepositoryImpl(db).watchStockLogs(),
      builder: (ctx, snap) {
        final logs = snap.data ?? [];
        if (logs.isEmpty) {
          return const EmptyStateWidget(
            title: 'Belum ada riwayat stok',
            icon: Icons.history_rounded,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (ctx, i) {
            final log = logs[i];
            final isPositive = log.quantityChange > 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                title: Text(log.movementType.label),
                subtitle: Text(DateFormatter.formatDateTime(log.createdAt)),
                trailing: Text(
                  '${isPositive ? '+' : ''}${log.quantityChange}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
