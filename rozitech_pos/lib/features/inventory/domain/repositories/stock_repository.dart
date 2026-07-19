import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_adjustment.dart';
import '../entities/stock_log.dart';
import '../../../sales/domain/repositories/transaction_repository.dart';

abstract class StockRepository {
  Future<Either<Failure, List<StockLog>>> getStockLogs({
    int? productId,
    DateRange? range,
  });
  Future<Either<Failure, void>> adjustStock(StockAdjustment adjustment);
  Stream<List<StockLog>> watchStockLogs({int? productId});
}
