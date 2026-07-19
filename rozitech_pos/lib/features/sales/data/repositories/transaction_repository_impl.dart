import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../inventory/domain/entities/stock_adjustment.dart';
import '../../../inventory/domain/entities/stock_log.dart';
import '../../../inventory/data/repositories/stock_repository_impl.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._db);
  final db.AppDatabase _db;

  @override
  Future<Either<Failure, List<SalesTransaction>>> getTransactions({
    DateRange? range,
    String? query,
    String? paymentMethod,
  }) async {
    try {
      final queryBuilder = _db.select(_db.transactions);

      if (query != null && query.isNotEmpty) {
        queryBuilder.where((t) => t.invoiceNumber.lower().like('%${query.toLowerCase()}%'));
      }

      if (range != null) {
        queryBuilder.where((t) => 
            t.createdAt.isBiggerOrEqualValue(range.start) & 
            t.createdAt.isSmallerOrEqualValue(range.end));
      }

      if (paymentMethod != null) {
        queryBuilder.where((t) => t.paymentMethod.equals(paymentMethod));
      }

      queryBuilder.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

      final rows = await queryBuilder.get();

      if (rows.isEmpty) {
        return right([]);
      }

      final txIds = rows.map((r) => r.id).toList();

      // Fetch all items in a single query
      final allItems = await (_db.select(_db.transactionItems)
            ..where((i) => i.transactionId.isIn(txIds)))
          .get();

      // Group items by transactionId
      final Map<int, List<TransactionItem>> itemsMap = {};
      for (final row in allItems) {
        final item = TransactionItem(
          id: row.id,
          transactionId: row.transactionId,
          productId: row.productId,
          productName: row.productName,
          sellingPrice: row.price,
          costPrice: row.cost,
          quantity: row.quantity.toInt(),
          discountAmount: row.discount,
          lineTotal: row.subtotal,
        );
        itemsMap.putIfAbsent(row.transactionId, () => []).add(item);
      }

      final results = rows.map((row) {
        final items = itemsMap[row.id] ?? [];
        return _toEntity(row, items);
      }).toList();

      return right(results);
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil transaksi: $e'));
    }
  }

  @override
  Future<Either<Failure, SalesTransaction>> getTransactionById(int id) async {
    try {
      final row = await (_db.select(_db.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) {
        return left(const NotFoundFailure('Transaksi tidak ditemukan'));
      }
      final items = await _getItemsForTransaction(id);
      return right(_toEntity(row, items));
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil transaksi: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createTransaction(
    SalesTransaction transaction,
    List<TransactionItem> items,
  ) async {
    try {
      int transactionId = -1;
      await _db.transaction(() async {
        final txNumber = await _generateTransactionNumber(transaction.createdAt);

        transactionId = await _db.into(_db.transactions).insert(
              db.TransactionsCompanion.insert(
                invoiceNumber: txNumber,
                customerId: Value(transaction.customerId),
                userId: Value(transaction.userId),
                status: Value(transaction.status),
                subtotal: Value(transaction.subtotal),
                discountAmount: Value(transaction.discountAmount),
                taxAmount: Value(transaction.taxAmount),
                total: Value(transaction.total),
                cashAmount: Value(transaction.paymentAmount),
                changeAmount: Value(transaction.changeAmount),
                paymentMethod: Value(transaction.paymentMethod.value),
                notes: Value(transaction.notes),
                createdAt: Value(transaction.createdAt),
              ),
            );

        // Insert line items + deduct stock
        final stockRepo = StockRepositoryImpl(_db);
        for (final item in items) {
          await _db.into(_db.transactionItems).insert(
                db.TransactionItemsCompanion.insert(
                  transactionId: transactionId,
                  productId: item.productId,
                  productName: item.productName,
                  productSku: const Value(null),
                  price: item.sellingPrice,
                  cost: Value(item.costPrice),
                  quantity: item.quantity.toDouble(),
                  discount: Value(item.discountAmount),
                  subtotal: item.lineTotal,
                ),
              );

          await stockRepo.adjustStock(StockAdjustment(
            productId: item.productId,
            quantityChange: -item.quantity,
            movementType: StockMovementType.sale,
            transactionId: transactionId,
          ));
        }
      });
      return right(transactionId);
    } catch (e) {
      return left(DatabaseFailure('Gagal membuat transaksi: $e'));
    }
  }

  @override
  Stream<List<SalesTransaction>> watchTodayTransactions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.transactions)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(startOfDay) &
              t.createdAt.isSmallerThanValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .asyncMap((rows) async {
      if (rows.isEmpty) return [];

      final txIds = rows.map((r) => r.id).toList();
      final allItems = await (_db.select(_db.transactionItems)
            ..where((i) => i.transactionId.isIn(txIds)))
          .get();

      final Map<int, List<TransactionItem>> itemsMap = {};
      for (final row in allItems) {
        final item = TransactionItem(
          id: row.id,
          transactionId: row.transactionId,
          productId: row.productId,
          productName: row.productName,
          sellingPrice: row.price,
          costPrice: row.cost,
          quantity: row.quantity.toInt(),
          discountAmount: row.discount,
          lineTotal: row.subtotal,
        );
        itemsMap.putIfAbsent(row.transactionId, () => []).add(item);
      }

      return rows.map((row) {
        final items = itemsMap[row.id] ?? [];
        return _toEntity(row, items);
      }).toList();
    });
  }

  @override
  Future<Either<Failure, int>> getDailySequence(DateTime date) async {
    try {
      final dateStr = DateFormatter.formatDbDate(date);
      final rows = await (_db.select(_db.transactions)
            ..where((t) => t.invoiceNumber.like('TRX-$dateStr-%')))
          .get();
      return right(rows.length + 1);
    } catch (e) {
      return left(DatabaseFailure('Gagal mendapatkan nomor urut: $e'));
    }
  }

  Future<String> _generateTransactionNumber(DateTime date) async {
    final dateStr = DateFormatter.formatDbDate(date);
    final seqResult = await getDailySequence(date);
    final seq = seqResult.getOrElse((_) => 1);
    return 'TRX-$dateStr-${seq.toString().padLeft(4, '0')}';
  }

  Future<List<TransactionItem>> _getItemsForTransaction(int txId) async {
    final rows = await (_db.select(_db.transactionItems)
          ..where((i) => i.transactionId.equals(txId)))
        .get();
    return rows.map((row) => TransactionItem(
          id: row.id,
          transactionId: row.transactionId,
          productId: row.productId,
          productName: row.productName,
          sellingPrice: row.price,
          costPrice: row.cost,
          quantity: row.quantity.toInt(),
          discountAmount: row.discount,
          lineTotal: row.subtotal,
        )).toList();
  }

  SalesTransaction _toEntity(
      db.Transaction row, List<TransactionItem> items) {
    return SalesTransaction(
      id: row.id,
      transactionNumber: row.invoiceNumber,
      subtotal: row.subtotal,
      discountAmount: row.discountAmount,
      taxAmount: row.taxAmount,
      total: row.total,
      paymentAmount: row.cashAmount,
      changeAmount: row.changeAmount,
      paymentMethod: _parsePaymentMethod(row.paymentMethod),
      status: row.status,
      notes: row.notes,
      customerId: row.customerId,
      userId: row.userId ?? 0,
      items: items,
      createdAt: row.createdAt,
    );
  }

  PaymentMethod _parsePaymentMethod(String value) {
    return PaymentMethod.values.firstWhere(
      (m) => m.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  @override
  Future<Either<Failure, Unit>> voidTransaction(int transactionId) async {
    try {
      final txResult = await getTransactionById(transactionId);
      await txResult.fold(
        (failure) => throw Exception(failure.message),
        (transaction) async {
          if (transaction.status == 'void') {
            throw Exception('Transaksi sudah dibatalkan/void.');
          }

          await _db.transaction(() async {
            // 1. Update status
            await (_db.update(_db.transactions)
                  ..where((t) => t.id.equals(transactionId)))
                .write(const db.TransactionsCompanion(status: Value('void')));

            // 2. Return/Restore stock
            final stockRepo = StockRepositoryImpl(_db);
            for (final item in transaction.items) {
              await stockRepo.adjustStock(StockAdjustment(
                productId: item.productId,
                quantityChange: item.quantity, // Add back stock
                movementType: StockMovementType.adjustment,
                transactionId: transactionId,
              ));
            }
          });
        },
      );
      return right(unit);
    } catch (e) {
      return left(DatabaseFailure('Gagal melakukan void transaksi: $e'));
    }
  }
}
