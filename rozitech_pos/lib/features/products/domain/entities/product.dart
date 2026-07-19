import 'package:equatable/equatable.dart';

/// Product domain entity with computed business properties.
class Product extends Equatable {
  const Product({
    this.id,
    required this.name,
    required this.sku,
    required this.sellingPrice,
    required this.costPrice,
    required this.stockQuantity,
    required this.minStockLevel,
    this.description,
    this.barcode,
    this.qrCode,
    this.imagePath,
    this.categoryId,
    this.unit = 'pcs',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String name;
  final String sku;
  final double sellingPrice;
  final double costPrice;
  final int stockQuantity;
  final int minStockLevel;
  final String? description;
  final String? barcode;
  final String? qrCode;
  final String? imagePath;
  final int? categoryId;
  final String unit;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// True when stock is at or below minimum level.
  bool get isLowStock => stockQuantity <= minStockLevel;

  /// Gross margin percentage (0–100).
  double get margin => sellingPrice > 0
      ? ((sellingPrice - costPrice) / sellingPrice) * 100
      : 0.0;

  /// Profit per unit.
  double get profitPerUnit => sellingPrice - costPrice;

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    double? sellingPrice,
    double? costPrice,
    int? stockQuantity,
    int? minStockLevel,
    String? description,
    String? barcode,
    String? qrCode,
    String? imagePath,
    int? categoryId,
    String? unit,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      imagePath: imagePath ?? this.imagePath,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        sellingPrice,
        costPrice,
        stockQuantity,
        minStockLevel,
        categoryId,
        isActive,
      ];
}
