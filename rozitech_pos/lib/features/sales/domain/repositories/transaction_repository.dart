import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/transaction_item.dart';

/// Date range helper.
class DateRange {
  const DateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}
abstract class TransactionRepository {
  Future<Either<Failure, List<SalesTransaction>>> getTransactions({
    DateRange? range,
    String? query,
    String? paymentMethod,
  });
  Future<Either<Failure, SalesTransaction>> getTransactionById(int id);
  Future<Either<Failure, int>> createTransaction(
    SalesTransaction transaction,
    List<TransactionItem> items,
  );
  Stream<List<SalesTransaction>> watchTodayTransactions();
  Future<Either<Failure, int>> getDailySequence(DateTime date);
  Future<Either<Failure, Unit>> voidTransaction(int transactionId);
}
