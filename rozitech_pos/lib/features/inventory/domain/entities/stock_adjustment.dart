import 'stock_log.dart';

/// Parameters for a stock adjustment operation.
class StockAdjustment {
  const StockAdjustment({
    required this.productId,
    required this.quantityChange,
    required this.movementType,
    this.userId,
    this.transactionId,
    this.reason,
  });

  final int productId;
  final int quantityChange; // positive = in, negative = out
  final StockMovementType movementType;
  final int? userId;
  final int? transactionId;
  final String? reason;
}
