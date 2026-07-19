import 'package:equatable/equatable.dart';
import 'cart_item.dart';

/// Shopping cart with computed totals.
class Cart extends Equatable {
  const Cart({
    this.items = const [],
    this.discountAmount = 0.0,
    this.discountPercent = 0.0,
    this.taxRate = 0.0,
    this.customerId,
    this.notes,
  });

  final List<CartItem> items;
  final double discountAmount;
  final double discountPercent;
  final double taxRate;
  final int? customerId;
  final String? notes;

  bool get isEmpty => items.isEmpty;
  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  /// Sum of all line totals (after item discounts).
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Cart-level discount (fixed amount takes priority over percent).
  double get totalDiscount => discountAmount > 0
      ? discountAmount
      : subtotal * (discountPercent / 100);

  /// Amount subject to tax.
  double get taxableAmount => subtotal - totalDiscount;

  /// Tax amount.
  double get taxAmount => taxableAmount * (taxRate / 100);

  /// Grand total.
  double get total => taxableAmount + taxAmount;

  /// Gross profit on this cart.
  double get grossProfit =>
      items.fold(0.0, (sum, item) => sum + item.lineCost) - subtotal;

  Cart copyWith({
    List<CartItem>? items,
    double? discountAmount,
    double? discountPercent,
    double? taxRate,
    int? customerId,
    String? notes,
  }) {
    return Cart(
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      taxRate: taxRate ?? this.taxRate,
      customerId: customerId ?? this.customerId,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        items,
        discountAmount,
        discountPercent,
        taxRate,
        customerId,
      ];
}
