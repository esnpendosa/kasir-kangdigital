import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

final _productRepoProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Stream watching products with optional search/filter.
final productsStreamProvider = StreamProvider.family<List<Product>,
    ({String? query, int? categoryId})>((ref, params) {
  return ref
      .watch(_productRepoProvider)
      .watchProducts(query: params.query, categoryId: params.categoryId);
});

/// Low stock products stream.
final lowStockProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(_productRepoProvider).watchLowStockProducts();
});

class ProductListState {
  final String query;
  final int? categoryId;
  final String sortBy;
  final bool lowStockOnly;

  const ProductListState({
    this.query = '',
    this.categoryId,
    this.sortBy = 'name',
    this.lowStockOnly = false,
  });

  ProductListState copyWith({
    String? query,
    int? categoryId,
    String? sortBy,
    bool? lowStockOnly,
    bool clearCategory = false,
  }) {
    return ProductListState(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      sortBy: sortBy ?? this.sortBy,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
    );
  }
}

class ProductListNotifier extends Notifier<ProductListState> {
  @override
  ProductListState build() => const ProductListState();

  void search(String query) => state = state.copyWith(query: query);
  void filterByCategory(int? id) =>
      state = id == null ? state.copyWith(clearCategory: true) : state.copyWith(categoryId: id);
  void sortBy(String field) => state = state.copyWith(sortBy: field);
  void toggleLowStock() =>
      state = state.copyWith(lowStockOnly: !state.lowStockOnly);
  void reset() => state = const ProductListState();
}

final productListNotifierProvider =
    NotifierProvider<ProductListNotifier, ProductListState>(
  ProductListNotifier.new,
);
