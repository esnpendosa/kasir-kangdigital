import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/cash_drawer_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/extensions.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../sales/data/repositories/cart_repository.dart';
import '../../../sales/presentation/widgets/pos_numpad.dart';
import '../../domain/entities/payment_method_config.dart';
import 'payment_method_selector.dart';
import 'qris_payment_dialog.dart';

/// Bottom sheet that handles the payment flow for all payment methods.
/// 
/// Call [PaymentProcessingSheet.show] as a convenience.
class PaymentProcessingSheet extends ConsumerStatefulWidget {
  const PaymentProcessingSheet({super.key});

  /// Convenience helper to open the sheet from any context.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PaymentProcessingSheet(),
    );
  }

  @override
  ConsumerState<PaymentProcessingSheet> createState() =>
      _PaymentProcessingSheetState();
}

class _PaymentProcessingSheetState
    extends ConsumerState<PaymentProcessingSheet> {
  PaymentType _selectedType = PaymentType.cash;
  final _cashCtrl = TextEditingController();
  bool _showNumpad = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  double get _cashAmount => double.tryParse(_cashCtrl.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cart = ref.watch(cartProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                'Proses Pembayaran',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${cart.total.toCurrency()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Payment method selector
              Text('Metode Pembayaran',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              PaymentMethodSelector(
                selected: _selectedType,
                onSelected: (t) {
                  setState(() {
                    _selectedType = t;
                    _cashCtrl.clear();
                    _showNumpad = false;
                  });
                  ref.read(cartProvider.notifier)
                      .setPaymentMethod(t.dbValue);
                },
              ),
              const SizedBox(height: 16),

              // Payment-specific UI
              _buildPaymentBody(cs, cart),

              const SizedBox(height: 20),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _canConfirm(cart) && !_isProcessing
                      ? () => _confirm(cart)
                      : null,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: const Text('Konfirmasi Pembayaran'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canConfirm(CartState cart) {
    if (_selectedType == PaymentType.cash) {
      return cart.items.isNotEmpty && _cashAmount >= cart.total;
    }
    return cart.items.isNotEmpty;
  }

  Widget _buildPaymentBody(ColorScheme cs, CartState cart) {
    switch (_selectedType) {
      case PaymentType.cash:
        return _buildCashBody(cs, cart);
      case PaymentType.bankTransfer:
        return _buildTransferBody(cs);
      case PaymentType.qrisDynamic:
      case PaymentType.midtrans:
      case PaymentType.qopay:
      case PaymentType.shopee:
        return _buildQrisBody(cs);
    }
  }

  Widget _buildCashBody(ColorScheme cs, CartState cart) {
    final change = _cashAmount - cart.total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cashCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Tunai',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_rounded),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => setState(() => _showNumpad = !_showNumpad),
              icon: const Icon(Icons.dialpad_rounded),
              tooltip: 'Numpad',
            ),
          ],
        ),
        if (_cashAmount >= cart.total && _cashAmount > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.change_circle_rounded,
                    color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Kembalian: ${change.toCurrency()}',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        if (_showNumpad) ...[
          const SizedBox(height: 8),
          PosNumpad(
            onKey: (key) {
              if (key == '⌫') {
                final t = _cashCtrl.text;
                if (t.isNotEmpty) {
                  _cashCtrl.text = t.substring(0, t.length - 1);
                }
              } else if (key == '✓') {
                setState(() => _showNumpad = false);
              } else {
                _cashCtrl.text += key;
              }
              setState(() {});
              ref
                  .read(cartProvider.notifier)
                  .setCashAmount(double.tryParse(_cashCtrl.text) ?? 0);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTransferBody(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_rounded, color: cs.primary),
              const SizedBox(width: 8),
              const Text(
                'Info Rekening Transfer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _InfoRow(label: 'Bank', value: 'BCA'),
          const _InfoRow(label: 'No. Rekening', value: '8730129031'),
          const _InfoRow(label: 'A/N', value: 'Kasir Kita'),
          const SizedBox(height: 8),
          const Text(
            'Konfirmasi pembayaran setelah transfer berhasil.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQrisBody(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.06),
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
                const Text(
                  'QRIS / E-Wallet Dinamis',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tekan "Konfirmasi" untuk menampilkan QR Code',
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(CartState cart) async {
    setState(() => _isProcessing = true);

    // For QRIS/gateway payments, show the QR dialog first
    if (_selectedType == PaymentType.qrisDynamic ||
        _selectedType == PaymentType.midtrans ||
        _selectedType == PaymentType.qopay ||
        _selectedType == PaymentType.shopee) {
      final mockPayload =
          'https://qris.id/0002ID.CO.KASIRKITA.CASIR01189360000'
          '12345601303AMOUNT${cart.total.toInt()}';
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => QrisPaymentDialog(
          qrString: mockPayload,
          amount: cart.total,
        ),
      );
      if (confirmed != true) {
        setState(() => _isProcessing = false);
        return;
      }
    }

    // For cash, sync cash amount
    if (_selectedType == PaymentType.cash) {
      ref.read(cartProvider.notifier).setCashAmount(_cashAmount);
    }

    // Save transaction
    final db = ref.read(databaseProvider);
    final productRepo = ref.read(productRepositoryProvider);
    final result =
        await ref.read(cartProvider.notifier).checkout(db, productRepo);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    result.fold(
      onSuccess: (txId) async {
        // Send notification
        await NotificationService.instance.showPaymentNotification(
          'Pembayaran Berhasil',
          'Transaksi ${cart.total.toCurrency()} telah berhasil.',
        );

        // Open cash drawer only for cash payments
        if (_selectedType == PaymentType.cash) {
          await NotificationService.instance.showCashDrawerOpenNotification();
          await CashDrawerService.openCashDrawer();
        }

        if (mounted) {
          Navigator.of(context).pop(); // close sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi #$txId berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onFailure: (msg, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey)),
          ),
          Text(': $value',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
