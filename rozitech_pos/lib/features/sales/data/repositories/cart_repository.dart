import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/invoice_generator.dart';
import '../../../../core/utils/result.dart';
import '../../../products/data/repositories/product_repository.dart';

// ─── Cart Item model ─────────────────────────────────────────────────────────

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
    this.discount = 0,
  });

  final Product product;
  double quantity;
  double discount; // percentage 0-100

  double get unitPrice => product.price;
  double get discountAmount => unitPrice * quantity * (discount / 100);
  double get subtotal => (unitPrice * quantity) - discountAmount;

  CartItem copyWith({double? quantity, double? discount}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}

// ─── Cart State ───────────────────────────────────────────────────────────────

class CartState {
  const CartState({
    this.items = const [],
    this.customerId,
    this.globalDiscount = 0,
    this.taxRate = 0,
    this.cashAmount = 0,
    this.paymentMethod = 'cash',
    this.notes = '',
  });

  final List<CartItem> items;
  final int? customerId;
  final double globalDiscount;
  final double taxRate;
  final double cashAmount;
  final String paymentMethod;
  final String notes;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double get globalDiscountAmount => subtotal * (globalDiscount / 100);

  double get taxableAmount => subtotal - globalDiscountAmount;

  double get taxAmount => taxableAmount * (taxRate / 100);

  double get total => taxableAmount + taxAmount;

  double get change => paymentMethod == 'cash' ? (cashAmount - total) : 0;

  bool get canCheckout => items.isNotEmpty && (paymentMethod != 'cash' || cashAmount >= total);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity.toInt());

  CartState copyWith({
    List<CartItem>? items,
    int? customerId,
    double? globalDiscount,
    double? taxRate,
    double? cashAmount,
    String? paymentMethod,
    String? notes,
  }) {
    return CartState(
      items: items ?? this.items,
      customerId: customerId ?? this.customerId,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      taxRate: taxRate ?? this.taxRate,
      cashAmount: cashAmount ?? this.cashAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}

// ─── Cart Notifier ────────────────────────────────────────────────────────────

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void addProduct(Product product) {
    final items = List<CartItem>.from(state.items);
    final existingIndex =
        items.indexWhere((i) => i.product.id == product.id);

    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex]
          .copyWith(quantity: items[existingIndex].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    state = state.copyWith(items: items);
  }

  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(int productId, double quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: quantity);
      state = state.copyWith(items: items);
    }
  }

  void updateItemDiscount(int productId, double discount) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(discount: discount);
      state = state.copyWith(items: items);
    }
  }

  void setGlobalDiscount(double pct) =>
      state = state.copyWith(globalDiscount: pct.clamp(0, 100));

  void setTaxRate(double pct) =>
      state = state.copyWith(taxRate: pct.clamp(0, 100));

  void setCashAmount(double amount) =>
      state = state.copyWith(cashAmount: amount);

  void setPaymentMethod(String method) =>
      state = state.copyWith(paymentMethod: method);

  void setCustomer(int? id) => state = state.copyWith(customerId: id);

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  void clearCart() => state = const CartState();

  /// Save transaction to database and adjust stock.
  Future<Result<int>> checkout(AppDatabase db, ProductRepository productRepo) async {
    if (!state.canCheckout) {
      return const Failure('Jumlah tunai tidak mencukupi');
    }

    try {
      late int txId;

      await db.transaction(() async {
        // Get next sequence number using custom COUNT query to avoid reading all rows
        final countRow = await db.customSelect('SELECT COUNT(*) as c FROM transactions').getSingle();
        final seq = (countRow.read<int>('c')) + 1;

        // Insert transaction header
        txId = await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                invoiceNumber: InvoiceGenerator.generate(sequence: seq),
                customerId: Value(state.customerId),
                subtotal: Value(state.subtotal),
                discountAmount: Value(state.globalDiscountAmount),
                taxAmount: Value(state.taxAmount),
                total: Value(state.total),
                cashAmount: Value(state.paymentMethod == 'cash' ? state.cashAmount : state.total),
                changeAmount: Value(state.change),
                paymentMethod: Value(state.paymentMethod),
                notes: Value(state.notes),
              ),
            );

        // Insert line items + adjust stock
        for (final item in state.items) {
          await db.into(db.transactionItems).insert(
                TransactionItemsCompanion.insert(
                  transactionId: txId,
                  productId: item.product.id,
                  productName: item.product.name,
                  productSku: Value(item.product.sku),
                  price: item.unitPrice,
                  cost: Value(item.product.cost),
                  quantity: item.quantity,
                  discount: Value(item.discount),
                  tax: Value(item.product.tax),
                  subtotal: item.subtotal,
                ),
              );

          // Deduct stock
          if (item.product.trackStock) {
            await productRepo.adjustStock(
              productId: item.product.id,
              quantity: item.quantity,
              type: 'out',
              reference: 'INV-$txId',
            );
          }
        }

        // Add loyalty points to member customer (1 point per 10.000 IDR)
        if (state.customerId != null) {
          final pointsToEarn = (state.total / 10000).floorToDouble();
          if (pointsToEarn > 0) {
            await db.customStatement(
              'UPDATE customers SET loyalty_points = loyalty_points + ? WHERE id = ?',
              [pointsToEarn, state.customerId],
            );
          }
        }
      });

      clearCart();
      return Success(txId);
    } catch (e) {
      return Failure('Gagal menyimpan transaksi: $e', e);
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

/// Provider for the POS product search query.
final posSearchProvider = StateProvider<String>((ref) => '');
