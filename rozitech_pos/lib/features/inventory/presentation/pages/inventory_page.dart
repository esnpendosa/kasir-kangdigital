import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/stock_log.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/domain/entities/product.dart';

final _stockRepoProvider = Provider<StockRepositoryImpl>((ref) {
  return StockRepositoryImpl(ref.watch(appDatabaseProvider));
});

final _productRepoProvider2 = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(ref.watch(appDatabaseProvider));
});

final _stockLogsProvider = StreamProvider<List<StockLog>>((ref) {
  return ref.watch(_stockRepoProvider).watchStockLogs();
});

final _allProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(_productRepoProvider2).watchProducts();
});

/// Inventory management page — real data from Drift.
class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_downward_rounded), text: 'Masuk'),
            Tab(icon: Icon(Icons.arrow_upward_rounded), text: 'Keluar'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StockInTab(),
          _StockOutTab(),
          _StockLogTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStockDialog(isIn: true),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Stok Masuk'),
      ),
    );
  }

  Future<void> _showStockDialog({required bool isIn}) async {
    final allProductsAsync = ref.read(_allProductsProvider);
    final products = allProductsAsync.valueOrNull ?? [];

    Product? selectedProduct;
    final quantityCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(isIn ? 'Stok Masuk' : 'Stok Keluar',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Product>(
                  value: selectedProduct,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Produk',
                    prefixIcon: Icon(Icons.inventory_2_rounded),
                  ),
                  items: products
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                                '${p.name} (stok: ${p.stockQuantity.toString()})',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (p) => setStateLocal(() => selectedProduct = p),
                  validator: (v) => v == null ? 'Pilih produk' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Masukkan jumlah';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Jumlah harus positif';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final qty = double.parse(quantityCtrl.text);
                      final adjustment = StockAdjustment(
                        productId: selectedProduct!.id!,
                        quantityChange:
                            isIn ? qty.toInt() : -qty.toInt(),
                        movementType: isIn
                            ? StockMovementType.stockIn
                            : StockMovementType.stockOut,
                        reason: notesCtrl.text.isEmpty
                            ? null
                            : notesCtrl.text,
                      );
                      final result = await ref
                          .read(_stockRepoProvider)
                          .adjustStock(adjustment);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        result.fold(
                          (f) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(f.message),
                                backgroundColor: Colors.red),
                          ),
                          (_) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isIn
                                  ? 'Stok masuk berhasil dicatat'
                                  : 'Stok keluar berhasil dicatat'),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                        isIn ? 'Simpan Stok Masuk' : 'Simpan Stok Keluar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tabs ──────────────────────────────────────────────────────────────────

class _StockInTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StockList(type: StockMovementType.stockIn, ref: ref);
  }
}

class _StockOutTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StockList(type: StockMovementType.stockOut, ref: ref);
  }
}

class _StockList extends StatelessWidget {
  const _StockList({required this.type, required this.ref});
  final StockMovementType type;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(_stockLogsProvider);
    final cs = Theme.of(context).colorScheme;
    final isIn = type == StockMovementType.stockIn;
    final color = isIn ? Colors.green : Colors.red;

    return logsAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (logs) {
        final filtered = logs
            .where((l) =>
                l.movementType == type ||
                (isIn && l.movementType == StockMovementType.initial))
            .toList();

        if (filtered.isEmpty) {
          return EmptyStateWidget(
            title: isIn ? 'Belum ada stok masuk' : 'Belum ada stok keluar',
            subtitle: isIn
                ? 'Gunakan tombol "Stok Masuk" untuk menambah stok'
                : 'Stok keluar tercatat saat terjadi penjualan',
            icon: isIn
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final log = filtered[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIn ? Icons.add_rounded : Icons.remove_rounded,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Produk #${log.productId}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        Text(
                          '${log.createdAt.toDateTimeString()}${log.reason != null ? ' · ${log.reason}' : ''}',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                        Text(
                          '${log.quantityBefore} → ${log.quantityAfter}',
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIn ? '+' : ''}${log.quantityChange}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (i * 20).ms);
          },
        );
      },
    );
  }
}

class _StockLogTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(_stockLogsProvider);
    final cs = Theme.of(context).colorScheme;

    return logsAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (logs) {
        if (logs.isEmpty) {
          return const EmptyStateWidget(
            title: 'Belum ada log stok',
            subtitle: 'Riwayat pergerakan stok akan muncul di sini',
            icon: Icons.history_rounded,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final log = logs[i];
            final isPositive = log.quantityChange >= 0;
            final color = isPositive ? Colors.green : Colors.orange;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      log.movementType.icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.movementType.label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(
                          'Produk #${log.productId} · ${log.createdAt.toDateTimeString()}',
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                        if (log.reason != null)
                          Text(log.reason!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}${log.quantityChange}',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 15),
                      ),
                      Text(
                        '${log.quantityBefore}→${log.quantityAfter}',
                        style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (i * 15).ms);
          },
        );
      },
    );
  }
}
