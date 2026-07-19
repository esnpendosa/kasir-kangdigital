import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as appdb;

/// Dashboard metrics data class
class DashboardMetrics {
  const DashboardMetrics({
    required this.todaySales,
    required this.todayTransactionCount,
    required this.todayProfit,
    required this.totalProducts,
    required this.lowStockCount,
    required this.monthSales,
    required this.recentTransactions,
    required this.topProducts,
    required this.weeklySales,
  });

  final double todaySales;
  final int todayTransactionCount;
  final double todayProfit;
  final int totalProducts;
  final int lowStockCount;
  final double monthSales;
  final List<RecentTransactionData> recentTransactions;
  final List<TopProductData> topProducts;
  final List<DailySalesData> weeklySales;
}

class RecentTransactionData {
  const RecentTransactionData({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    required this.createdAt,
    required this.status,
    this.customerName,
  });
  final int id;
  final String invoiceNumber;
  final double total;
  final DateTime createdAt;
  final String status;
  final String? customerName;
}

class TopProductData {
  const TopProductData({
    required this.productName,
    required this.totalSold,
    required this.revenue,
  });
  final String productName;
  final double totalSold;
  final double revenue;
}

class DailySalesData {
  const DailySalesData({
    required this.date,
    required this.sales,
    required this.transactions,
  });
  final DateTime date;
  final double sales;
  final int transactions;
}

/// Repository for dashboard aggregated queries.
class DashboardRepository {
  const DashboardRepository(this._db);
  final appdb.AppDatabase _db;

  Future<DashboardMetrics> getDashboardMetrics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Today's transactions
    final todayTxns = await (_db.select(_db.transactions)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(startOfDay) &
              t.createdAt.isSmallerThanValue(endOfDay) &
              t.status.equals('completed')))
        .get();

    final todaySales = todayTxns.fold<double>(0, (s, t) => s + t.total);
    final todayCount = todayTxns.length;

    // Today's profit (need items for COGS)
    double todayProfit = 0;
    if (todayTxns.isNotEmpty) {
      final todayTxnIds = todayTxns.map((t) => t.id).toList();
      final todayItems = await (_db.select(_db.transactionItems)
            ..where((i) => i.transactionId.isIn(todayTxnIds)))
          .get();
      
      final Map<int, double> cogsMap = {};
      for (final item in todayItems) {
        cogsMap[item.transactionId] = (cogsMap[item.transactionId] ?? 0.0) + (item.cost * item.quantity);
      }
      
      for (final txn in todayTxns) {
        final cogs = cogsMap[txn.id] ?? 0.0;
        todayProfit += txn.total - cogs;
      }
    }

    // Month sales
    final monthTxns = await (_db.select(_db.transactions)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(startOfMonth) &
              t.status.equals('completed')))
        .get();
    final monthSales = monthTxns.fold<double>(0, (s, t) => s + t.total);

    // Products
    final allProducts = await _db.select(_db.products).get();
    final totalProducts = allProducts.where((p) => p.isActive).length;
    final lowStockCount = allProducts
        .where((p) => p.isActive && p.trackStock && p.stock <= p.minStock)
        .length;

    // Recent transactions (last 5)
    final recentRows = await (_db.select(_db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(5))
        .get();

    final recentTransactions = <RecentTransactionData>[];
    for (final row in recentRows) {
      String? customerName;
      if (row.customerId != null) {
        final customer = await (_db.select(_db.customers)
              ..where((c) => c.id.equals(row.customerId!)))
            .getSingleOrNull();
        customerName = customer?.name;
      }
      recentTransactions.add(RecentTransactionData(
        id: row.id,
        invoiceNumber: row.invoiceNumber,
        total: row.total,
        createdAt: row.createdAt,
        status: row.status,
        customerName: customerName,
      ));
    }

    // Top products (last 30 days)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentTxnIds = (await (_db.select(_db.transactions)
              ..where((t) =>
                  t.createdAt.isBiggerOrEqualValue(thirtyDaysAgo) &
                  t.status.equals('completed')))
            .get())
        .map((t) => t.id)
        .toList();

    final Map<String, ({double qty, double revenue})> productSales = {};
    if (recentTxnIds.isNotEmpty) {
      final allItems = await (_db.select(_db.transactionItems)
            ..where((i) => i.transactionId.isIn(recentTxnIds)))
          .get();
      for (final item in allItems) {
        final existing = productSales[item.productName];
        if (existing != null) {
          productSales[item.productName] = (
            qty: existing.qty + item.quantity,
            revenue: existing.revenue + item.subtotal
          );
        } else {
          productSales[item.productName] = (
            qty: item.quantity,
            revenue: item.subtotal
          );
        }
      }
    }

    final topProducts = productSales.entries
        .map((e) => TopProductData(
              productName: e.key,
              totalSold: e.value.qty,
              revenue: e.value.revenue,
            ))
        .toList()
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

    // Weekly sales (last 7 days in a single query)
    final sevenDaysAgo = DateTime(now.year, now.month, now.day - 6);
    final weeklyTxns = await (_db.select(_db.transactions)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(sevenDaysAgo) &
              t.status.equals('completed')))
        .get();

    final weeklySales = <DailySalesData>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayEnd = day.add(const Duration(days: 1));
      
      final dayTxns = weeklyTxns.where((t) => 
          (t.createdAt.isAfter(day) || t.createdAt.isAtSameMomentAs(day)) && 
          t.createdAt.isBefore(dayEnd)
      ).toList();

      weeklySales.add(DailySalesData(
        date: day,
        sales: dayTxns.fold(0, (s, t) => s + t.total),
        transactions: dayTxns.length,
      ));
    }

    return DashboardMetrics(
      todaySales: todaySales,
      todayTransactionCount: todayCount,
      todayProfit: todayProfit,
      totalProducts: totalProducts,
      lowStockCount: lowStockCount,
      monthSales: monthSales,
      recentTransactions: recentTransactions,
      topProducts: topProducts.take(5).toList(),
      weeklySales: weeklySales,
    );
  }
}
