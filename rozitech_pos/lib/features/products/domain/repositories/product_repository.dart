import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    String? query,
    int? categoryId,
    String? sortBy,
    bool? lowStockOnly,
  });
  Future<Either<Failure, Product>> getProductById(int id);
  Future<Either<Failure, Product>> getProductByBarcode(String barcode);
  Future<Either<Failure, int>> createProduct(Product product);
  Future<Either<Failure, void>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(int id);
  Stream<List<Product>> watchProducts({String? query, int? categoryId});
  Stream<List<Product>> watchLowStockProducts();
}
