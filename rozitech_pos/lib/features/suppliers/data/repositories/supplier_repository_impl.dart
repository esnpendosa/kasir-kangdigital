import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/failures.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  const SupplierRepositoryImpl(this._db);
  final db.AppDatabase _db;

  @override
  Future<Either<Failure, List<Supplier>>> getSuppliers(
      {String? query}) async {
    try {
      final rows = await (_db.select(_db.suppliers)
            ..orderBy([(s) => OrderingTerm(expression: s.name)]))
          .get();
      final all = rows.map(_toEntity).toList();
      if (query == null || query.isEmpty) return right(all);
      final q = query.toLowerCase();
      return right(all
          .where((s) => s.name.toLowerCase().contains(q))
          .toList());
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil supplier: $e'));
    }
  }

  @override
  Stream<List<Supplier>> watchSuppliers() {
    return (_db.select(_db.suppliers)
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Either<Failure, Supplier>> getSupplierById(int id) async {
    try {
      final row = await (_db.select(_db.suppliers)
            ..where((s) => s.id.equals(id)))
          .getSingleOrNull();
      if (row == null) {
        return left(const NotFoundFailure('Supplier tidak ditemukan'));
      }
      return right(_toEntity(row));
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil supplier: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createSupplier(Supplier supplier) async {
    try {
      final id = await _db.into(_db.suppliers).insert(
            db.SuppliersCompanion.insert(
              name: supplier.name,
              contactPerson: Value(supplier.contactPerson),
              phone: Value(supplier.phone),
              email: Value(supplier.email),
              address: Value(supplier.address),
              notes: Value(supplier.notes),
            ),
          );
      return right(id);
    } catch (e) {
      return left(DatabaseFailure('Gagal membuat supplier: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSupplier(Supplier supplier) async {
    try {
      await (_db.update(_db.suppliers)
            ..where((s) => s.id.equals(supplier.id!)))
          .write(db.SuppliersCompanion(
        name: Value(supplier.name),
        contactPerson: Value(supplier.contactPerson),
        phone: Value(supplier.phone),
        email: Value(supplier.email),
        address: Value(supplier.address),
        notes: Value(supplier.notes),
        updatedAt: Value(DateTime.now()),
      ));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal memperbarui supplier: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(int id) async {
    try {
      await (_db.delete(_db.suppliers)..where((s) => s.id.equals(id))).go();
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menghapus supplier: $e'));
    }
  }

  Supplier _toEntity(db.Supplier row) {
    return Supplier(
      id: row.id,
      name: row.name,
      contactPerson: row.contactPerson,
      phone: row.phone,
      email: row.email,
      address: row.address,
      notes: row.notes,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
