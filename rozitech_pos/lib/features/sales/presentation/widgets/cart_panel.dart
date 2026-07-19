import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm;

import '../../../../core/database/app_database.dart' as appdb;
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../routes/app_router.dart';
import '../../data/repositories/cart_repository.dart';
import 'pos_numpad.dart';
import '../../../settings/data/repositories/settings_repository_impl.dart';

/// Shopping cart panel — shown right side on tablet, bottom sheet on mobile.
class CartPanel extends ConsumerStatefulWidget {
  const CartPanel({super.key, required this.cartState});
  final CartState cartState;

  @override
  ConsumerState<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends ConsumerState<CartPanel> {
  bool _showNumpad = false;
  final _cashCtrl = TextEditingController();

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cart = widget.cartState;
    final profileAsync = ref.watch(storeProfileProvider);
    final profile = profileAsync.value ?? const {};

    final bankName = profile['payment_bank_name'] ?? 'BCA';
    final bankAccount = profile['payment_bank_account'] ?? '8730129031';
    final bankRecipient = profile['payment_bank_recipient'] ?? 'Kasir Kita';
    final qrisMerchant = profile['qris_merchant_name'] ?? 'Kasir Kita Gateway';
    final qrisNmid = profile['qris_nmid'] ?? 'ID1020304050';

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_rounded),
                const SizedBox(width: 8),
                Text(
                  'Keranjang',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (cart.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(cartProvider.notifier).clearCart(),
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Colors.red),
                    label: const Text('Kosongkan',
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
          ),

          // ── Cart Items ─────────────────────────────────────────────
          Expanded(
            child: cart.items.isEmpty
                ? _EmptyCart()
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: cs.outlineVariant),
                    itemBuilder: (context, i) =>
                        _CartItemTile(item: cart.items[i]),
                  ),
          ),

          // ── Summary ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            child: Column(
              children: [
                _buildMemberSelector(context, cs, cart),
                const SizedBox(height: 8),
                const Divider(height: 8),
                const SizedBox(height: 8),
                _summaryRow(context, 'Subtotal', cart.subtotal.toCurrency()),
                if (cart.globalDiscount > 0)
                  _summaryRow(context, 'Diskon (${cart.globalDiscount.toStringAsFixed(0)}%)',
                      '-${cart.globalDiscountAmount.toCurrency()}',
                      color: Colors.green),
                if (cart.taxRate > 0)
                  _summaryRow(context, 'Pajak (${cart.taxRate.toStringAsFixed(0)}%)',
                      cart.taxAmount.toCurrency()),
                const Divider(height: 16),
                _summaryRow(
                  context,
                  'TOTAL',
                  cart.total.toCurrency(),
                  isBold: true,
                  fontSize: 18,
                ),
                                // Payment Method Selector
                Row(
                  children: [
                    const Text('Metode:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPaymentMethodOption('cash', 'Tunai', Icons.payments_rounded),
                            const SizedBox(width: 4),
                            _buildPaymentMethodOption('transfer', 'Transfer', Icons.account_balance_rounded),
                            const SizedBox(width: 4),
                            _buildPaymentMethodOption('qris', 'QRIS/Gateway', Icons.qr_code_2_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Conditional Payment input/display
                if (cart.paymentMethod == 'cash') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cashCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tunai',
                            prefixText: 'Rp ',
                            prefixIcon: Icon(Icons.payments_rounded),
                          ),
                          onChanged: (v) {
                            final amount = double.tryParse(v) ?? 0;
                            ref
                                .read(cartProvider.notifier)
                                .setCashAmount(amount);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () =>
                            setState(() => _showNumpad = !_showNumpad),
                        icon: const Icon(Icons.dialpad_rounded),
                        tooltip: 'Numpad',
                      ),
                    ],
                  ),
                ] else if (cart.paymentMethod == 'transfer') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_rounded, color: cs.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Transfer Bank (Manual)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('$bankName: $bankAccount a/n $bankRecipient', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (cart.paymentMethod == 'qris') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('QRIS: $qrisMerchant', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                              const SizedBox(height: 2),
                              Text('NMID: $qrisNmid', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (cart.cashAmount > 0 && cart.cashAmount >= cart.total) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.change_circle_rounded,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text('Kembalian: ',
                            style: const TextStyle(fontSize: 13)),
                        Text(
                          cart.change.toCurrency(),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Numpad
                if (_showNumpad)
                  PosNumpad(
                    onKey: (key) {
                      if (key == '⌫') {
                        final text = _cashCtrl.text;
                        if (text.isNotEmpty) {
                          _cashCtrl.text =
                              text.substring(0, text.length - 1);
                        }
                      } else if (key == '✓') {
                        setState(() => _showNumpad = false);
                      } else {
                        _cashCtrl.text += key;
                      }
                      final amount =
                          double.tryParse(_cashCtrl.text) ?? 0;
                      ref
                          .read(cartProvider.notifier)
                          .setCashAmount(amount);
                    },
                  ),

                // Checkout button — opens full Payment Selector
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: cart.items.isNotEmpty
                        ? () => context.push(
                              '${AppRoutes.payment}?total=${cart.total.toStringAsFixed(0)}',
                            )
                        : null,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Bayar Sekarang'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: cart.items.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String method, String label, IconData icon) {
    final cart = widget.cartState;
    final isSelected = cart.paymentMethod == method;
    final cs = Theme.of(context).colorScheme;

    return ChoiceChip(
      iconTheme: IconThemeData(color: isSelected ? Colors.white : cs.onSurfaceVariant),
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(cartProvider.notifier).setPaymentMethod(method);
          if (method != 'cash') {
            _cashCtrl.clear();
            ref.read(cartProvider.notifier).setCashAmount(0);
          }
        }
      },
      selectedColor: cs.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : cs.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
    );
  }



  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 13,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w400,
                  color: color)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight:
                      isBold ? FontWeight.w800 : FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildMemberSelector(BuildContext context, ColorScheme cs, CartState cart) {
    if (cart.customerId == null) {
      return InkWell(
        onTap: () => _showMemberSelectionDialog(context, cs),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.person_add_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Pelanggan / Member',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    Text(
                      'Dapatkan diskon khusus & poin loyalitas',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.primary, size: 20),
            ],
          ),
        ),
      );
    }

    final db = ref.read(appDatabaseProvider);
    return StreamBuilder<appdb.Customer?>(
      stream: (db.select(db.customers)..where((c) => c.id.equals(cart.customerId!))).watchSingleOrNull(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final customer = snapshot.data!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MEMBER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        customer.phone ?? 'Tanpa nomor telepon',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                  onPressed: () {
                    ref.read(cartProvider.notifier).setCustomer(null);
                    ref.read(cartProvider.notifier).setGlobalDiscount(0);
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showMemberSelectionDialog(BuildContext context, ColorScheme cs) {
    final db = ref.read(appDatabaseProvider);
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Pelanggan / Member',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau nomor telepon...',
                      prefixIcon: Icon(Icons.search_rounded),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (v) {
                      setDialogState(() {
                        query = v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: StreamBuilder<List<appdb.Customer>>(
                      stream: (db.select(db.customers)
                            ..orderBy([(c) => OrderingTerm(expression: c.name)]))
                          .watch(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final all = snapshot.data ?? [];
                        final filtered = all.where((c) {
                          final q = query.toLowerCase();
                          return c.name.toLowerCase().contains(q) ||
                              (c.phone?.contains(q) ?? false);
                        }).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Pelanggan tidak ditemukan',
                                style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final c = filtered[idx];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: cs.primary.withValues(alpha: 0.1),
                                child: Text(
                                  c.name[0].toUpperCase(),
                                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text(c.phone ?? 'Tanpa nomor telepon', style: const TextStyle(fontSize: 12)),
                              trailing: Icon(Icons.check_circle_outline_rounded, color: cs.primary, size: 20),
                              onTap: () {
                                ref.read(cartProvider.notifier).setCustomer(c.id);
                                ref.read(cartProvider.notifier).setGlobalDiscount(10);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Member "${c.name}" terpilih! Diskon member 10% diterapkan.'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAddCustomerDialog(context, cs);
                      },
                      icon: const Icon(Icons.person_add_rounded),
                      label: const Text('Tambah Member Baru'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context, ColorScheme cs) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tambah Pelanggan Baru'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pelanggan*',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama diperlukan' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final db = ref.read(appDatabaseProvider);
                try {
                  final id = await db.into(db.customers).insert(
                        appdb.CustomersCompanion.insert(
                          name: nameCtrl.text.trim(),
                          phone: Value(phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()),
                          createdAt: Value(DateTime.now()),
                          updatedAt: Value(DateTime.now()),
                        ),
                      );
                  ref.read(cartProvider.notifier).setCustomer(id);
                  ref.read(cartProvider.notifier).setGlobalDiscount(10);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Member "${nameCtrl.text}" berhasil didaftarkan dan dipilih!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menambahkan pelanggan: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan & Pilih'),
            ),
          ],
        );
      },
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final cart = ref.read(cartProvider.notifier);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        item.product.name,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        item.unitPrice.toCurrency(),
        style:
            TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quantity control
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyButton(
                  icon: Icons.remove_rounded,
                  onPressed: () => cart.updateQuantity(
                      item.product.id, item.quantity - 1),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    item.quantity.toInt().toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add_rounded,
                  onPressed: () => cart.updateQuantity(
                      item.product.id, item.quantity + 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.subtotal.toCurrency(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(
            'Keranjang kosong',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih produk untuk memulai',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
          ),
        ],
      ),
    );
  }
}

