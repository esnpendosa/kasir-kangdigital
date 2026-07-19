import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/database/app_database.dart' as appdb;
import '../../../../core/error/failures.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/stock_log.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../../sales/domain/repositories/transaction_repository.dart';

class StockRepositoryImpl implements StockRepository {
  const StockRepositoryImpl(this._db);
  final appdb.AppDatabase _db;

  @override
  Future<Either<Failure, List<StockLog>>> getStockLogs({
    int? productId,
    DateRange? range,
  }) async {
    try {
      var q = _db.select(_db.stockLogs)
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);

      if (productId != null) {
        q = q..where((s) => s.productId.equals(productId));
      }

      final rows = await q.get();
      return right(rows.map(_toEntity).toList());
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil log stok: $e'));
    }
  }

  @override
  Stream<List<StockLog>> watchStockLogs({int? productId}) {
    var q = _db.select(_db.stockLogs)
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);

    if (productId != null) {
      q = q..where((s) => s.productId.equals(productId));
    }

    return q
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Either<Failure, void>> adjustStock(
      StockAdjustment adjustment) async {
    try {
      await _db.transaction(() async {
        // Get current product stock
        final product = await (_db.select(_db.products)
              ..where((p) => p.id.equals(adjustment.productId)))
            .getSingleOrNull();

        if (product == null) {
          throw Exception('Produk tidak ditemukan');
        }

        final before = product.stock.toInt();
        final after = before + adjustment.quantityChange;

        // Update product stock
        await (_db.update(_db.products)
              ..where((p) => p.id.equals(adjustment.productId)))
            .write(appdb.ProductsCompanion(
          stock: Value(after.toDouble()),
          updatedAt: Value(DateTime.now()),
        ));

        // Insert stock log
        await _db.into(_db.stockLogs).insert(appdb.StockLogsCompanion.insert(
              productId: adjustment.productId,
              type: adjustment.movementType.value,
              quantity: adjustment.quantityChange.toDouble(),
              quantityBefore: before.toDouble(),
              quantityAfter: after.toDouble(),
              reference: Value(adjustment.transactionId?.toString()),
              notes: Value(adjustment.reason),
            ));
      });
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menyesuaikan stok: $e'));
    }
  }

  StockLog _toEntity(appdb.StockLog row) {
    return StockLog(
      id: row.id,
      productId: row.productId,
      movementType: _parseMovementType(row.type),
      quantityBefore: row.quantityBefore.toInt(),
      quantityChange: row.quantity.toInt(),
      quantityAfter: row.quantityAfter.toInt(),
      reason: row.notes,
      createdAt: row.createdAt,
    );
  }

  StockMovementType _parseMovementType(String type) {
    switch (type) {
      case 'sale':
        return StockMovementType.sale;
      case 'adjustment':
        return StockMovementType.adjustment;
      case 'stock_in':
        return StockMovementType.stockIn;
      case 'stock_out':
        return StockMovementType.stockOut;
      default:
        return StockMovementType.initial;
    }
  }
}
