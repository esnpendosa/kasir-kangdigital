import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/database/app_database.dart' as appdb;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._db);
  final appdb.AppDatabase _db;

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? query,
    int? categoryId,
    String? sortBy,
    bool? lowStockOnly,
  }) async {
    try {
      var q = _db.select(_db.products)
        ..where((p) => p.isActive.equals(true));

      if (categoryId != null) {
        q = q..where((p) => p.categoryId.equals(categoryId));
      }

      final rows = await q.get();
      var results = rows.map(_toEntity).toList();

      if (query != null && query.isNotEmpty) {
        final lq = query.toLowerCase();
        results = results
            .where((p) =>
                p.name.toLowerCase().contains(lq) ||
                p.sku.toLowerCase().contains(lq) ||
                (p.barcode?.contains(query) ?? false))
            .toList();
      }

      if (lowStockOnly == true) {
        results = results.where((p) => p.isLowStock).toList();
      }

      // Sort
      switch (sortBy) {
        case 'name':
          results.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'price':
          results.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
          break;
        case 'stock':
          results
              .sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
          break;
        case 'date':
          results.sort((a, b) =>
              (b.createdAt ?? DateTime(0))
                  .compareTo(a.createdAt ?? DateTime(0)));
          break;
        default:
          results.sort((a, b) => a.name.compareTo(b.name));
      }

      return right(results);
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil produk: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(int id) async {
    try {
      final row = await (_db.select(_db.products)
            ..where((p) => p.id.equals(id)))
          .getSingleOrNull();
      if (row == null) {
        return left(const NotFoundFailure('Produk tidak ditemukan'));
      }
      return right(_toEntity(row));
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil produk: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(
      String barcode) async {
    try {
      final row = await (_db.select(_db.products)
            ..where((p) => p.barcode.equals(barcode)))
          .getSingleOrNull();
      if (row == null) {
        return left(NotFoundFailure('Produk dengan barcode $barcode tidak ditemukan'));
      }
      return right(_toEntity(row));
    } catch (e) {
      return left(DatabaseFailure('Gagal mencari produk: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createProduct(Product product) async {
    final errors = _validate(product);
    if (errors.isNotEmpty) {
      return left(ValidationFailure('Data produk tidak valid', fieldErrors: errors));
    }
    try {
      final id = await _db.into(_db.products).insert(
            appdb.ProductsCompanion.insert(
              name: product.name,
              sku: Value(product.sku),
              barcode: Value(product.barcode),
              description: Value(product.description),
              imagePath: Value(product.imagePath),
              categoryId: Value(product.categoryId),
              price: Value(product.sellingPrice),
              cost: Value(product.costPrice),
              stock: Value(product.stockQuantity.toDouble()),
              minStock: Value(product.minStockLevel.toDouble()),
              unit: Value(product.unit),
              isActive: Value(product.isActive),
            ),
          );
      return right(id);
    } catch (e) {
      return left(DatabaseFailure('Gagal membuat produk: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    final errors = _validate(product);
    if (errors.isNotEmpty) {
      return left(ValidationFailure('Data produk tidak valid', fieldErrors: errors));
    }
    try {
      await (_db.update(_db.products)
            ..where((p) => p.id.equals(product.id!)))
          .write(appdb.ProductsCompanion(
        name: Value(product.name),
        sku: Value(product.sku),
        barcode: Value(product.barcode),
        description: Value(product.description),
        imagePath: Value(product.imagePath),
        categoryId: Value(product.categoryId),
        price: Value(product.sellingPrice),
        cost: Value(product.costPrice),
        stock: Value(product.stockQuantity.toDouble()),
        minStock: Value(product.minStockLevel.toDouble()),
        unit: Value(product.unit),
        isActive: Value(product.isActive),
        updatedAt: Value(DateTime.now()),
      ));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal memperbarui produk: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      // Check if product is in any transactions
      final items = await (_db.select(_db.transactionItems)
            ..where((i) => i.productId.equals(id)))
          .get();
      if (items.isNotEmpty) {
        return left(const ValidationFailure(
          'Produk tidak dapat dihapus karena sudah ada dalam transaksi',
        ));
      }
      // Soft delete
      await (_db.update(_db.products)..where((p) => p.id.equals(id)))
          .write(const appdb.ProductsCompanion(isActive: Value(false)));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menghapus produk: $e'));
    }
  }

  @override
  Stream<List<Product>> watchProducts({String? query, int? categoryId}) {
    return (_db.select(_db.products)
          ..where((p) => p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .watch()
        .map((rows) {
      var results = rows.map(_toEntity).toList();
      if (categoryId != null) {
        results = results.where((p) => p.categoryId == categoryId).toList();
      }
      if (query != null && query.isNotEmpty) {
        final lq = query.toLowerCase();
        results = results
            .where((p) =>
                p.name.toLowerCase().contains(lq) ||
                p.sku.toLowerCase().contains(lq))
            .toList();
      }
      return results;
    });
  }

  @override
  Stream<List<Product>> watchLowStockProducts() {
    return (_db.select(_db.products)
          ..where((p) => p.isActive.equals(true)))
        .watch()
        .map((rows) => rows
            .map(_toEntity)
            .where((p) => p.isLowStock)
            .toList());
  }

  Map<String, String> _validate(Product p) {
    final errors = <String, String>{};
    if (!Validators.isNotBlank(p.name)) {
      errors['name'] = 'Nama produk tidak boleh kosong';
    }
    if (!Validators.isNonNegative(p.sellingPrice)) {
      errors['sellingPrice'] = 'Harga jual tidak boleh negatif';
    }
    if (!Validators.isNonNegative(p.costPrice)) {
      errors['costPrice'] = 'Harga beli tidak boleh negatif';
    }
    return errors;
  }

  Product _toEntity(appdb.Product row) {
    return Product(
      id: row.id,
      name: row.name,
      sku: row.sku ?? '',
      description: row.description,
      barcode: row.barcode,
      imagePath: row.imagePath,
      categoryId: row.categoryId,
      sellingPrice: row.price,
      costPrice: row.cost,
      stockQuantity: row.stock.toInt(),
      minStockLevel: row.minStock.toInt(),
      unit: row.unit,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
