import 'package:equatable/equatable.dart';

/// A line item belonging to a completed transaction (snapshot at time of sale).
class TransactionItem extends Equatable {
  const TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.sellingPrice,
    required this.costPrice,
    required this.quantity,
    required this.lineTotal,
    this.discountAmount = 0.0,
  });

  final int? id;
  final int transactionId;
  final int productId;
  final String productName;
  final double sellingPrice;
  final double costPrice;
  final int quantity;
  final double discountAmount;
  final double lineTotal;

  double get profit => (sellingPrice - costPrice) * quantity - discountAmount;

  @override
  List<Object?> get props =>
      [id, transactionId, productId, quantity, lineTotal];
}
