import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/supplier.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<Supplier>>> getSuppliers({String? query});
  Future<Either<Failure, Supplier>> getSupplierById(int id);
  Future<Either<Failure, int>> createSupplier(Supplier supplier);
  Future<Either<Failure, void>> updateSupplier(Supplier supplier);
  Future<Either<Failure, void>> deleteSupplier(int id);
  Stream<List<Supplier>> watchSuppliers();
}
