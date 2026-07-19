import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Stream<List<Category>> watchCategories();
  Future<Either<Failure, int>> createCategory(Category category);
  Future<Either<Failure, void>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(int id, {bool reassign = false});
  Future<int> getProductCountForCategory(int categoryId);
}
