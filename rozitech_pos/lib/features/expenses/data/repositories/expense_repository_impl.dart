import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/database/app_database.dart' as appdb;
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';

class ExpenseRepositoryImpl {
  const ExpenseRepositoryImpl(this._db);
  final appdb.AppDatabase _db;

  Future<Either<Failure, List<Expense>>> getExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
  }) async {
    try {
      final rows = await (_db.select(_db.expenses)
            ..orderBy([(e) => OrderingTerm.desc(e.expenseDate)]))
          .get();
      var results = rows.map(_toEntity).toList();

      if (category != null && category.isNotEmpty) {
        results = results.where((e) => e.category == category).toList();
      }
      if (from != null) {
        results = results
            .where((e) => e.expenseDate.isAfter(from) || e.expenseDate == from)
            .toList();
      }
      if (to != null) {
        results =
            results.where((e) => e.expenseDate.isBefore(to)).toList();
      }
      return right(results);
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil pengeluaran: $e'));
    }
  }

  Stream<List<Expense>> watchExpenses() {
    return (_db.select(_db.expenses)
          ..orderBy([(e) => OrderingTerm.desc(e.expenseDate)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  Future<Either<Failure, int>> createExpense(Expense expense) async {
    try {
      final id = await _db.into(_db.expenses).insert(
            appdb.ExpensesCompanion.insert(
              category: expense.category,
              description: expense.description,
              amount: expense.amount,
              expenseDate: expense.expenseDate,
            ),
          );
      return right(id);
    } catch (e) {
      return left(DatabaseFailure('Gagal membuat pengeluaran: $e'));
    }
  }

  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      await (_db.update(_db.expenses)
            ..where((e) => e.id.equals(expense.id!)))
          .write(appdb.ExpensesCompanion(
        category: Value(expense.category),
        description: Value(expense.description),
        amount: Value(expense.amount),
        expenseDate: Value(expense.expenseDate),
      ));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal memperbarui pengeluaran: $e'));
    }
  }

  Future<Either<Failure, void>> deleteExpense(int id) async {
    try {
      await (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menghapus pengeluaran: $e'));
    }
  }

  Expense _toEntity(appdb.Expense row) {
    return Expense(
      id: row.id,
      category: row.category,
      description: row.description,
      amount: row.amount,
      expenseDate: row.expenseDate,
      createdAt: row.createdAt,
    );
  }
}
