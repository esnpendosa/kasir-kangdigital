import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/result.dart';

/// Repository for all product CRUD operations.
/// Uses Drift ORM with stream-based reactive queries.
class ProductRepository {
  ProductRepository(this._db);
  final AppDatabase _db;

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Watch all active products, joined with category name.
  Stream<List<Product>> watchAll({String? search, int? categoryId}) {
    final query = _db.select(_db.products).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.products.categoryId),
      ),
    ]);

    query.where(_db.products.isActive.equals(true));

    if (search != null && search.isNotEmpty) {
      query.where(
        _db.products.name.contains(search) |
            _db.products.sku.contains(search) |
            _db.products.barcode.contains(search),
      );
    }

    if (categoryId != null) {
      query.where(_db.products.categoryId.equals(categoryId));
    }

    query.orderBy([OrderingTerm.desc(_db.products.createdAt)]);

    return query
        .map((row) => row.readTable(_db.products))
        .watch();
  }

  /// Get a single product by ID.
  Future<Product?> getById(int id) {
    return (_db.select(_db.products)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get product by barcode or SKU.
  Future<Product?> getByBarcode(String barcode) {
    return (_db.select(_db.products)
          ..where((t) =>
              t.barcode.equals(barcode) | t.sku.equals(barcode))
          ..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();
  }

  /// Count low-stock products (stock is 0 or less than minStock threshold=5).
  Future<int> countLowStock() async {
    final query = _db.select(_db.products)
      ..where((t) => t.stock.isSmallerOrEqualValue(5))
      ..where((t) => t.isActive.equals(true));
    final rows = await query.get();
    return rows.length;
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Insert a new product, auto-generating SKU if not provided.
  Future<Result<int>> create(ProductsCompanion companion) async {
    try {
      final id = await _db.into(_db.products).insert(companion);
      return Success(id);
    } catch (e) {
      return Failure('Gagal menyimpan produk: $e', e);
    }
  }

  /// Update an existing product.
  Future<Result<bool>> update(ProductsCompanion companion) async {
    try {
      final count =
          await (_db.update(_db.products)..where((t) => t.id.equals(companion.id.value)))
              .write(companion);
      return Success(count > 0);
    } catch (e) {
      return Failure('Gagal memperbarui produk: $e', e);
    }
  }

  /// Soft-delete — marks product as inactive.
  Future<Result<bool>> softDelete(int id) async {
    try {
      final count = await (_db.update(_db.products)
            ..where((t) => t.id.equals(id)))
          .write(const ProductsCompanion(isActive: Value(false)));
      return Success(count > 0);
    } catch (e) {
      return Failure('Gagal menghapus produk: $e', e);
    }
  }

  /// Adjust stock and log it.
  Future<Result<bool>> adjustStock({
    required int productId,
    required double quantity,
    required String type, // 'in' | 'out' | 'adjustment'
    String? reference,
    String? notes,
  }) async {
    try {
      final product = await getById(productId);
      if (product == null) return const Failure('Produk tidak ditemukan');

      final before = product.stock;
      final after = type == 'out' ? before - quantity : before + quantity;

      await _db.transaction(() async {
        // Update stock
        await (_db.update(_db.products)
              ..where((t) => t.id.equals(productId)))
            .write(ProductsCompanion(
          stock: Value(after),
          updatedAt: Value(DateTime.now()),
        ));

        // Log
        await _db.into(_db.stockLogs).insert(
              StockLogsCompanion.insert(
                productId: productId,
                type: type,
                quantity: quantity,
                quantityBefore: before,
                quantityAfter: after,
                reference: Value(reference),
                notes: Value(notes),
              ),
            );
      });

      return const Success(true);
    } catch (e) {
      return Failure('Gagal menyesuaikan stok: $e', e);
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(databaseProvider));
});

/// Stream provider for the product list (reactive).
final productsStreamProvider =
    StreamProvider.family<List<Product>, ({String? search, int? categoryId})>(
  (ref, params) {
    final repo = ref.watch(productRepositoryProvider);
    return repo.watchAll(
      search: params.search,
      categoryId: params.categoryId,
    );
  },
);

/// Provider for search query state.
final productSearchProvider = StateProvider<String>((ref) => '');
final productCategoryFilterProvider = StateProvider<int?>((ref) => null);
