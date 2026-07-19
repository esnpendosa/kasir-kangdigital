import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Stock movement types.
enum StockMovementType { sale, adjustment, stockIn, stockOut, initial }

extension StockMovementTypeX on StockMovementType {
  String get value {
    switch (this) {
      case StockMovementType.sale:
        return 'sale';
      case StockMovementType.adjustment:
        return 'adjustment';
      case StockMovementType.stockIn:
        return 'stock_in';
      case StockMovementType.stockOut:
        return 'stock_out';
      case StockMovementType.initial:
        return 'initial';
    }
  }

  String get label {
    switch (this) {
      case StockMovementType.sale:
        return 'Penjualan';
      case StockMovementType.adjustment:
        return 'Penyesuaian';
      case StockMovementType.stockIn:
        return 'Stok Masuk';
      case StockMovementType.stockOut:
        return 'Stok Keluar';
      case StockMovementType.initial:
        return 'Stok Awal';
    }
  }

  bool get isPositive =>
      this == StockMovementType.stockIn || this == StockMovementType.initial;

  IconData get icon {
    switch (this) {
      case StockMovementType.sale:
        return Icons.shopping_cart_rounded;
      case StockMovementType.adjustment:
        return Icons.tune_rounded;
      case StockMovementType.stockIn:
        return Icons.arrow_downward_rounded;
      case StockMovementType.stockOut:
        return Icons.arrow_upward_rounded;
      case StockMovementType.initial:
        return Icons.fiber_new_rounded;
    }
  }
}

/// Stock log domain entity.
class StockLog extends Equatable {
  const StockLog({
    this.id,
    required this.productId,
    required this.movementType,
    required this.quantityBefore,
    required this.quantityChange,
    required this.quantityAfter,
    required this.createdAt,
    this.userId,
    this.transactionId,
    this.reason,
  });

  final int? id;
  final int productId;
  final StockMovementType movementType;
  final int quantityBefore;
  final int quantityChange; // positive = in, negative = out
  final int quantityAfter;
  final int? userId;
  final int? transactionId;
  final String? reason;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, productId, movementType, quantityChange, createdAt];
}
