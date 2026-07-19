import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as appdb;

class SalesReportData {
  const SalesReportData({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.avgTransactionValue,
    required this.totalCogs,
    required this.grossProfit,
    required this.topProducts,
    required this.dailyBreakdown,
  });
  final double totalRevenue;
  final int totalTransactions;
  final double avgTransactionValue;
  final double totalCogs;
  final double grossProfit;
  final List<ProductSalesRow> topProducts;
  final List<DailyReportRow> dailyBreakdown;
}

class ProductSalesRow {
  const ProductSalesRow({
    required this.productName,
    required this.qtySold,
    required this.revenue,
    required this.cogs,
  });
  final String productName;
  final double qtySold;
  final double revenue;
  final double cogs;

  double get profit => revenue - cogs;
}

class DailyReportRow {
  const DailyReportRow({
    required this.date,
    required this.revenue,
    required this.transactions,
  });
  final DateTime date;
  final double revenue;
  final int transactions;
}

class ReportRepository {
  const ReportRepository(this._db);
  final appdb.AppDatabase _db;

  Future<SalesReportData> getSalesReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final endInclusive = to.add(const Duration(days: 1));

    final txns = await (_db.select(_db.transactions)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(from) &
              t.createdAt.isSmallerThanValue(endInclusive) &
              t.status.equals('completed'))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();

    final txnIds = txns.map((t) => t.id).toList();

    double totalRevenue = 0;
    double totalCogs = 0;
    final Map<String, ProductSalesRow> productMap = {};

    if (txnIds.isNotEmpty) {
      final allItems = await (_db.select(_db.transactionItems)
            ..where((i) => i.transactionId.isIn(txnIds)))
          .get();

      for (final item in allItems) {
        totalRevenue += item.subtotal;
        totalCogs += item.cost * item.quantity;

        final existing = productMap[item.productName];
        if (existing != null) {
          productMap[item.productName] = ProductSalesRow(
            productName: item.productName,
            qtySold: existing.qtySold + item.quantity,
            revenue: existing.revenue + item.subtotal,
            cogs: existing.cogs + (item.cost * item.quantity),
          );
        } else {
          productMap[item.productName] = ProductSalesRow(
            productName: item.productName,
            qtySold: item.quantity,
            revenue: item.subtotal,
            cogs: item.cost * item.quantity,
          );
        }
      }
    }

    final topProducts = productMap.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Daily breakdown
    final dailyMap = <String, DailyReportRow>{};
    for (final txn in txns) {
      final dateKey =
          '${txn.createdAt.year}-${txn.createdAt.month.toString().padLeft(2, '0')}-${txn.createdAt.day.toString().padLeft(2, '0')}';
      final existing = dailyMap[dateKey];
      if (existing != null) {
        dailyMap[dateKey] = DailyReportRow(
          date: existing.date,
          revenue: existing.revenue + txn.total,
          transactions: existing.transactions + 1,
        );
      } else {
        dailyMap[dateKey] = DailyReportRow(
          date: DateTime(
              txn.createdAt.year,
              txn.createdAt.month,
              txn.createdAt.day),
          revenue: txn.total,
          transactions: 1,
        );
      }
    }

    final dailyList = dailyMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return SalesReportData(
      totalRevenue: totalRevenue,
      totalTransactions: txns.length,
      avgTransactionValue:
          txns.isEmpty ? 0 : totalRevenue / txns.length,
      totalCogs: totalCogs,
      grossProfit: totalRevenue - totalCogs,
      topProducts: topProducts.take(10).toList(),
      dailyBreakdown: dailyList,
    );
  }

  Future<double> getTotalExpenses({
    required DateTime from,
    required DateTime to,
  }) async {
    final endInclusive = to.add(const Duration(days: 1));
    final rows = await (_db.select(_db.expenses)
          ..where((e) =>
              e.expenseDate.isBiggerOrEqualValue(from) &
              e.expenseDate.isSmallerThanValue(endInclusive)))
        .get();
    return rows.fold<double>(0, (s, e) => s + e.amount);
  }
}
