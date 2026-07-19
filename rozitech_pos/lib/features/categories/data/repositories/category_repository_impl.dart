import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/database/app_database.dart' as appdb;
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._db);
  final appdb.AppDatabase _db;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final rows = await _db.select(_db.categories).get();
      return right(rows.map(_toEntity).toList());
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil kategori: $e'));
    }
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _db.select(_db.categories).watch().map(
          (rows) => rows.map(_toEntity).toList(),
        );
  }

  @override
  Future<Either<Failure, int>> createCategory(Category category) async {
    try {
      final id = await _db.into(_db.categories).insert(
            appdb.CategoriesCompanion.insert(
              name: category.name,
              description: Value(category.description),
              color: Value(category.colorHex),
              icon: Value(category.iconName),
            ),
          );
      return right(id);
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        return left(const ValidationFailure(
            'Nama kategori sudah digunakan',
            fieldErrors: {'name': 'Nama kategori harus unik'}));
      }
      return left(DatabaseFailure('Gagal membuat kategori: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) async {
    try {
      await (_db.update(_db.categories)
            ..where((c) => c.id.equals(category.id!)))
          .write(appdb.CategoriesCompanion(
        name: Value(category.name),
        description: Value(category.description),
        color: Value(category.colorHex),
        icon: Value(category.iconName),
        updatedAt: Value(DateTime.now()),
      ));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal memperbarui kategori: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(
      int id, {bool reassign = false}) async {
    try {
      final count = await getProductCountForCategory(id);
      if (count > 0 && !reassign) {
        return left(ValidationFailure(
          'Kategori memiliki $count produk. Pilih untuk memindahkan ke Uncategorized.',
        ));
      }
      if (count > 0 && reassign) {
        // Nullify categoryId for all products in this category
        await (_db.update(_db.products)
              ..where((p) => p.categoryId.equals(id)))
            .write(const appdb.ProductsCompanion(categoryId: Value(null)));
      }
      await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menghapus kategori: $e'));
    }
  }

  @override
  Future<int> getProductCountForCategory(int categoryId) async {
    final rows = await (_db.select(_db.products)
          ..where((p) => p.categoryId.equals(categoryId)))
        .get();
    return rows.length;
  }

  Category _toEntity(appdb.Category row) {
    return Category(
      id: row.id,
      name: row.name,
      description: row.description,
      colorHex: row.color,
      iconName: row.icon,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
