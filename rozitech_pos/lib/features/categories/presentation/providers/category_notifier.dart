import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

final _categoryRepoProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Stream of all categories.
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(_categoryRepoProvider).watchCategories();
});

/// Async notifier for category CRUD operations.
class CategoryNotifier extends AsyncNotifier<List<Category>> {
  late CategoryRepository _repo;

  @override
  Future<List<Category>> build() async {
    _repo = ref.watch(_categoryRepoProvider);
    final result = await _repo.getCategories();
    return result.getOrElse((_) => []);
  }

  Future<bool> createCategory(Category category) async {
    final result = await _repo.createCategory(category);
    return result.fold((_) => false, (_) {
      ref.invalidateSelf();
      return true;
    });
  }

  Future<bool> updateCategory(Category category) async {
    final result = await _repo.updateCategory(category);
    return result.fold((_) => false, (_) {
      ref.invalidateSelf();
      return true;
    });
  }

  Future<({bool success, String? error})> deleteCategory(
      int id, {bool reassign = false}) async {
    final result = await _repo.deleteCategory(id, reassign: reassign);
    return result.fold(
      (failure) => (success: false, error: failure.message),
      (_) {
        ref.invalidateSelf();
        return (success: true, error: null);
      },
    );
  }

  Future<int> getProductCount(int categoryId) =>
      _repo.getProductCountForCategory(categoryId);
}

final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
  CategoryNotifier.new,
);
