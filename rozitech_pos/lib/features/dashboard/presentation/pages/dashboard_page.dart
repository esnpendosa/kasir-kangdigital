import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../routes/app_router.dart';
import '../../data/dashboard_repository.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/sales_chart.dart';

// Provider defined inline — no separate file needed
final _dashboardRepoProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(appDatabaseProvider));
});

final _dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  return ref.watch(_dashboardRepoProvider).getDashboardMetrics();
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(_dashboardMetricsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(_dashboardMetricsProvider.future),
          child: CustomScrollView(
            slivers: [
              // ─── App Bar ────────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                pinned: false,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang 👋',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                    Text(
                      'Dasbor',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.pos),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.point_of_sale_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Buka Kasir',
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              metricsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                ),
                data: (metrics) => SliverList(
                  delegate: SliverChildListDelegate([
                    _buildKpiCards(context, metrics),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SalesChartWithData(data: metrics.weeklySales),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _QuickActions(),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: _RecentTransactionsList(
                          transactions: metrics.recentTransactions),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCards(BuildContext context, DashboardMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          DashboardStatCard(
            label: 'Penjualan Hari Ini',
            value: metrics.todaySales.toCurrency(),
            change: '${metrics.todayTransactionCount} transaksi',
            isPositive: metrics.todaySales > 0,
            icon: Icons.trending_up_rounded,
            gradient: AppColors.salesGradient,
          ),
          DashboardStatCard(
            label: 'Laba Hari Ini',
            value: metrics.todayProfit.toCurrency(),
            change: 'kotor',
            isPositive: metrics.todayProfit > 0,
            icon: Icons.account_balance_wallet_rounded,
            gradient: AppColors.revenueGradient,
          ),
          DashboardStatCard(
            label: 'Penjualan Bulan Ini',
            value: metrics.monthSales.toCurrency(),
            change: 'bulan berjalan',
            isPositive: metrics.monthSales > 0,
            icon: Icons.receipt_long_rounded,
            gradient: AppColors.ordersGradient,
          ),
          DashboardStatCard(
            label: 'Total Produk',
            value: '${metrics.totalProducts}',
            change: metrics.lowStockCount > 0
                ? '${metrics.lowStockCount} stok menipis'
                : 'stok aman',
            isPositive: metrics.lowStockCount == 0,
            icon: Icons.inventory_2_rounded,
            gradient: AppColors.productsGradient,
          ),
        ],
      ),
    );
  }
}

// ─── Sales Chart with real data ────────────────────────────────────────────

class SalesChartWithData extends StatelessWidget {
  const SalesChartWithData({super.key, required this.data});
  final List<DailySalesData> data;

  @override
  Widget build(BuildContext context) {
    // Use the existing SalesChart but pass data via inheritance
    return SalesChart(weeklyData: data);
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final actions = [
      (Icons.add_shopping_cart_rounded, 'Transaksi Baru', AppRoutes.pos, cs.primary),
      (Icons.add_box_rounded, 'Tambah Produk', AppRoutes.productAdd, AppColors.success),
      (Icons.bar_chart_rounded, 'Laporan', AppRoutes.reports, AppColors.warning),
      (Icons.backup_rounded, 'Backup', AppRoutes.backup, AppColors.secondary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _QuickActionButton(
                  icon: a.$1,
                  label: a.$2,
                  route: a.$3,
                  color: a.$4,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recent Transactions ───────────────────────────────────────────────────

class _RecentTransactionsList extends StatelessWidget {
  const _RecentTransactionsList({required this.transactions});
  final List<RecentTransactionData> transactions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Terbaru',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.transactions),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 40, color: cs.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Text('Belum ada transaksi hari ini',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: cs.outlineVariant),
              itemBuilder: (context, i) {
                final t = transactions[i];
                final isVoid = t.status == 'void';
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isVoid
                          ? Colors.red.withValues(alpha: 0.1)
                          : cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isVoid
                          ? Icons.cancel_outlined
                          : Icons.receipt_long_rounded,
                      color: isVoid ? Colors.red : cs.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(t.invoiceNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(t.customerName ?? 'Pelanggan Umum',
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.5))),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        t.total.toCurrency(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isVoid
                              ? cs.onSurface.withValues(alpha: 0.4)
                              : cs.onSurface,
                          decoration:
                              isVoid ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(t.createdAt.toTimeString(),
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.4))),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
