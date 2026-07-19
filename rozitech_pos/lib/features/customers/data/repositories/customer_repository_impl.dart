import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/database/app_database.dart' as appdb;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl(this._db);
  final appdb.AppDatabase _db;

  @override
  Future<Either<Failure, List<Customer>>> getCustomers(
      {String? query}) async {
    try {
      final rows = await (_db.select(_db.customers)
            ..orderBy([(c) => OrderingTerm(expression: c.name)]))
          .get();
      final all = rows.map(_toEntity).toList();
      if (query == null || query.isEmpty) return right(all);
      final q = query.toLowerCase();
      return right(all
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              (c.phone?.contains(q) ?? false))
          .toList());
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil pelanggan: $e'));
    }
  }

  @override
  Stream<List<Customer>> watchCustomers({String? query}) {
    return (_db.select(_db.customers)
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .watch()
        .map((rows) {
      final all = rows.map(_toEntity).toList();
      if (query == null || query.isEmpty) return all;
      final q = query.toLowerCase();
      return all
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              (c.phone?.contains(q) ?? false))
          .toList();
    });
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(int id) async {
    try {
      final row = await (_db.select(_db.customers)
            ..where((c) => c.id.equals(id)))
          .getSingleOrNull();
      if (row == null) {
        return left(const NotFoundFailure('Pelanggan tidak ditemukan'));
      }
      return right(_toEntity(row));
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil pelanggan: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createCustomer(Customer customer) async {
    // Validate
    final errors = <String, String>{};
    if (customer.phone != null &&
        customer.phone!.isNotEmpty &&
        !Validators.isValidPhone(customer.phone)) {
      errors['phone'] = 'Format nomor telepon tidak valid';
    }
    if (customer.email != null &&
        customer.email!.isNotEmpty &&
        !Validators.isValidEmail(customer.email)) {
      errors['email'] = 'Format email tidak valid';
    }
    if (errors.isNotEmpty) {
      return left(ValidationFailure('Data tidak valid', fieldErrors: errors));
    }

    try {
      final id = await _db.into(_db.customers).insert(
            appdb.CustomersCompanion.insert(
              name: customer.name,
              phone: Value(customer.phone),
              email: Value(customer.email),
              address: Value(customer.address),
            ),
          );
      return right(id);
    } catch (e) {
      return left(DatabaseFailure('Gagal membuat pelanggan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomer(Customer customer) async {
    try {
      await (_db.update(_db.customers)
            ..where((c) => c.id.equals(customer.id!)))
          .write(appdb.CustomersCompanion(
        name: Value(customer.name),
        phone: Value(customer.phone),
        email: Value(customer.email),
        address: Value(customer.address),
        updatedAt: Value(DateTime.now()),
      ));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal memperbarui pelanggan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(int id) async {
    try {
      await (_db.delete(_db.customers)..where((c) => c.id.equals(id))).go();
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menghapus pelanggan: $e'));
    }
  }

  Customer _toEntity(appdb.Customer row) {
    return Customer(
      id: row.id,
      name: row.name,
      phone: row.phone,
      email: row.email,
      address: row.address,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
