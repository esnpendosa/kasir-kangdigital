import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product.dart';

/// A single item in the shopping cart.
class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    this.itemDiscountAmount = 0.0,
  });

  final Product product;
  final int quantity;
  final double itemDiscountAmount;

  /// Line total after item-level discount.
  double get lineTotal =>
      (product.sellingPrice * quantity) - itemDiscountAmount;

  /// Cost for this line (for margin calculation).
  double get lineCost => product.costPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? itemDiscountAmount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      itemDiscountAmount: itemDiscountAmount ?? this.itemDiscountAmount,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity, itemDiscountAmount];
}
