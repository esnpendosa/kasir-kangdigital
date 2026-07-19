import 'package:equatable/equatable.dart';
import 'transaction_item.dart';

/// Payment method options.
enum PaymentMethod { cash, card, transfer }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.card:
        return 'Kartu';
      case PaymentMethod.transfer:
        return 'Transfer';
    }
  }
  String get value => name;
}

/// Transaction domain entity.
class SalesTransaction extends Equatable {
  const SalesTransaction({
    this.id,
    required this.transactionNumber,
    required this.subtotal,
    required this.total,
    required this.paymentAmount,
    required this.changeAmount,
    required this.createdAt,
    required this.userId,
    this.items = const [],
    this.customerId,
    this.cashDrawerId,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.paymentMethod = PaymentMethod.cash,
    this.status = 'completed',
    this.notes,
  });

  final int? id;
  final String transactionNumber;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final double paymentAmount;
  final double changeAmount;
  final PaymentMethod paymentMethod;
  final String status;
  final String? notes;
  final int? customerId;
  final int userId;
  final int? cashDrawerId;
  final List<TransactionItem> items;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, transactionNumber, total, createdAt, userId];
}
