import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers({String? query});
  Future<Either<Failure, Customer>> getCustomerById(int id);
  Future<Either<Failure, int>> createCustomer(Customer customer);
  Future<Either<Failure, void>> updateCustomer(Customer customer);
  Future<Either<Failure, void>> deleteCustomer(int id);
  Stream<List<Customer>> watchCustomers({String? query});
}
