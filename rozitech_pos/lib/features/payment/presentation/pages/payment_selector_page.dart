import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/cash_drawer_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/invoice_generator.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../sales/data/repositories/cart_repository.dart';
import '../../../sales/data/repositories/transaction_repository_impl.dart';
import '../../../settings/data/repositories/settings_repository_impl.dart';
import '../../domain/entities/payment_method_config.dart';
import '../providers/payment_provider.dart';
import '../widgets/qris_payment_dialog.dart';
import '../../../../core/utils/qris_dynamic_converter.dart';
import '../../../sales/presentation/widgets/pos_numpad.dart';

/// Full-screen payment selector page.
/// Navigates here from the cart when the user taps "Bayar Sekarang".
class PaymentSelectorPage extends ConsumerStatefulWidget {
  const PaymentSelectorPage({
    super.key,
    required this.totalAmount,
  });

  final double totalAmount;

  @override
  ConsumerState<PaymentSelectorPage> createState() =>
      _PaymentSelectorPageState();
}

class _PaymentSelectorPageState extends ConsumerState<PaymentSelectorPage> {
  PaymentType _selected = PaymentType.cash;
  final _cashCtrl = TextEditingController();
  bool _showNumpad = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  double get _cashAmount => double.tryParse(_cashCtrl.text) ?? 0;
  double get _change => (_cashAmount - widget.totalAmount).clamp(0, double.infinity);

  bool get _canPay {
    if (_selected == PaymentType.cash) {
      return _cashAmount >= widget.totalAmount;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabledMethods = ref.watch(enabledPaymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Metode Pembayaran'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Total header ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: cs.primaryContainer,
            child: Column(
              children: [
                Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.totalAmount.toCurrency(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Payment method grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: enabledMethods.length,
                    itemBuilder: (ctx, i) {
                      final method = enabledMethods[i];
                      final isSelected = _selected == method;
                      return _PaymentMethodCard(
                        type: method,
                        isSelected: isSelected,
                        onTap: () => setState(() {
                          _selected = method;
                          if (method != PaymentType.cash) {
                            _cashCtrl.clear();
                          }
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Payment-specific panel
                  _buildPaymentPanel(cs),

                  const SizedBox(height: 80), // space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(cs),
    );
  }

  Widget _buildPaymentPanel(ColorScheme cs) {
    switch (_selected) {
      case PaymentType.cash:
        return _buildCashPanel(cs);
      case PaymentType.bankTransfer:
        return _buildTransferPanel(cs);
      case PaymentType.qrisDynamic:
      case PaymentType.qopay:
      case PaymentType.shopee:
        return _buildQrisInfoPanel(cs);
      case PaymentType.midtrans:
        return _buildMidtransInfoPanel(cs);
    }
  }

  Widget _buildCashPanel(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jumlah Uang Diterima',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cashCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Tunai',
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
        // Quick amount buttons
        const SizedBox(height: 8),
        _QuickAmountRow(
          total: widget.totalAmount,
          onSelect: (amt) {
            _cashCtrl.text = amt.toStringAsFixed(0);
            setState(() {});
          },
        ),
        if (_cashAmount >= widget.totalAmount && _cashAmount > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.change_circle_rounded,
                        color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Kembalian:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  _change.toCurrency(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_showNumpad) ...[
          const SizedBox(height: 12),
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
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTransferPanel(ColorScheme cs) {
    final profileAsync = ref.watch(storeProfileProvider);
    final profile = profileAsync.value ?? const {};
    final bankName = profile['payment_bank_name'] ?? 'BCA';
    final bankAccount = profile['payment_bank_account'] ?? '8730129031';
    final bankRecipient = profile['payment_bank_recipient'] ?? 'Toko Saya';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Bank', value: bankName),
          _InfoRow(label: 'No. Rekening', value: bankAccount),
          _InfoRow(label: 'A/N', value: bankRecipient),
          const SizedBox(height: 12),
          Text(
            'Konfirmasi pembayaran setelah transfer berhasil.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildQrisInfoPanel(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2_rounded, color: Colors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selected.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tekan "Bayar" untuk menampilkan QR Code pembayaran.',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMidtransInfoPanel(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card_rounded, color: Colors.blue, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Midtrans SNAP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tekan "Bayar" untuk membuka halaman pembayaran Midtrans.',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _canPay && !_isProcessing ? _processPayment : null,
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_rounded),
          label: Text(
            _isProcessing ? 'Memproses...' : 'Bayar ${widget.totalAmount.toCurrency()}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _canPay ? Colors.green : cs.surfaceContainerHighest,
            foregroundColor: _canPay ? Colors.white : cs.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // For QRIS-type payments, show QR dialog first
      if (_selected == PaymentType.qrisDynamic ||
          _selected == PaymentType.qopay ||
          _selected == PaymentType.shopee) {
        final profile = await ref.read(settingsRepositoryProvider).getStoreProfile();
        // qris_nmid stores the full static QRIS string (NMID from QRIS provider)
        final qrisNmid = profile['qris_nmid'] ?? '';

        String qrPayload;
        if (qrisNmid.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NMID QRIS belum diisi. Silakan atur di Pengaturan → NMID QRIS.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isProcessing = false);
          return;
        }

        try {
          // Convert static NMID → dynamic QRIS with the actual transaction amount
          qrPayload = QrisDynamicConverter.convert(qrisNmid, widget.totalAmount);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('NMID QRIS tidak valid: $e\n'
                  'Pastikan nilai NMID adalah kode QRIS lengkap dari provider Anda.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
            ),
          );
          setState(() => _isProcessing = false);
          return;
        }

        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => QrisPaymentDialog(
            qrString: qrPayload,
            amount: widget.totalAmount,
          ),
        );

        if (confirmed != true) {
          setState(() => _isProcessing = false);
          return;
        }
      }

      // For Midtrans, show redirect URL info
      if (_selected == PaymentType.midtrans) {
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Midtrans SNAP'),
            content: const Text(
              'Dalam mode demo, pembayaran Midtrans akan dikonfirmasi langsung.\n\n'
              'Di produksi, ini akan membuka halaman SNAP Midtrans.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Konfirmasi'),
              ),
            ],
          ),
        );
        if (confirmed != true) {
          setState(() => _isProcessing = false);
          return;
        }
      }

      // Update cart with payment info
      final cartNotifier = ref.read(cartProvider.notifier);
      cartNotifier.setPaymentMethod(_selected.dbValue);
      if (_selected == PaymentType.cash) {
        cartNotifier.setCashAmount(_cashAmount);
      }

      // Save transaction
      final db = ref.read(databaseProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final result = await cartNotifier.checkout(db, productRepo);

      if (!mounted) return;

      result.fold(
        onSuccess: (txId) async {
          // Show success notification
          final invoiceNo = InvoiceGenerator.generate(sequence: txId);

          // Show success notification
          await NotificationService.instance.showPaymentSuccess(
            invoiceNo,
            widget.totalAmount,
          );

          // Open cash drawer for cash payments
          if (_selected == PaymentType.cash) {
            await CashDrawerService.openCashDrawer();
          }

          // Auto-print receipt if printer is configured
          try {
            final prefs = await SharedPreferences.getInstance();
            final mac = prefs.getString('printer_mac');
            if (mac != null && mac.isNotEmpty) {
              final txRepo = TransactionRepositoryImpl(db);
              final settingsRepo = SettingsRepositoryImpl(db);
              final txResult = await txRepo.getTransactionById(txId);
              final profile = await settingsRepo.getStoreProfile();

              await txResult.fold(
                (failure) async =>
                    debugPrint('Gagal mengambil transaksi untuk auto-print: $failure'),
                (transaction) async {
                  final printService = ref.read(printServiceProvider.notifier);
                  final storeName = profile['store_name'] ?? 'Toko Saya';
                  final storeAddress = profile['store_address'] ?? '';
                  final storePhone = profile['store_phone'] ?? '';
                  final footer = profile['receipt_footer'] ?? 'Terima kasih!';
                  final paperWidth = profile['printer_paper_width'] ?? '58';
                  final printLogo = profile['print_logo'] == 'true';
                  final storeLogoPath = profile['store_logo'];

                  await printService.printReceipt(
                    transaction: transaction,
                    storeName: storeName,
                    storeAddress: storeAddress,
                    storePhone: storePhone,
                    receiptFooter: footer,
                    paperWidth: paperWidth,
                    printLogo: printLogo,
                    storeLogoPath: storeLogoPath,
                  );
                },
              );
            }
          } catch (e) {
            debugPrint('Auto-print error: $e');
          }

          if (mounted) {
            _showSuccessDialog(txId, invoiceNo);
          }
        },
        onFailure: (msg, _) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(int txId, String invoiceNo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PaymentSuccessDialog(
        txId: txId,
        total: widget.totalAmount,
        change: _change,
        invoiceNo: invoiceNo,
        paymentType: _selected,
      ),
    ).then((_) {
      if (mounted) {
        Navigator.of(context).pop(true); // return true to caller
      }
    });
  }
}

// ── Payment Method Card ───────────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : cs.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Amount Row ──────────────────────────────────────────────────────────

class _QuickAmountRow extends StatelessWidget {
  const _QuickAmountRow({required this.total, required this.onSelect});
  final double total;
  final ValueChanged<double> onSelect;

  List<double> get _amounts {
    // Round up to nearest 1k, 5k, 10k, 50k, 100k
    final amounts = <double>[];
    for (final round in [1000.0, 5000.0, 10000.0, 50000.0, 100000.0]) {
      final a = (total / round).ceil() * round;
      if (!amounts.contains(a)) amounts.add(a);
      if (amounts.length >= 4) break;
    }
    return amounts;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      children: _amounts.map((amt) {
        return ActionChip(
          label: Text(
            amt >= 1000
                ? '${(amt / 1000).toStringAsFixed(0)}rb'
                : amt.toStringAsFixed(0),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: cs.primary.withValues(alpha: 0.1),
          onPressed: () => onSelect(amt),
        );
      }).toList(),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Text(
            ': $value',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Success Dialog ────────────────────────────────────────────────────────────

class _PaymentSuccessDialog extends ConsumerWidget {
  const _PaymentSuccessDialog({
    required this.txId,
    required this.total,
    required this.change,
    required this.invoiceNo,
    required this.paymentType,
  });

  final int txId;
  final double total;
  final double change;
  final String invoiceNo;
  final PaymentType paymentType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding:
          const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 80),
          const SizedBox(height: 12),
          const Text(
            'Pembayaran Berhasil!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            total.toCurrency(),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'via ${paymentType.label}',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Invoice: #$invoiceNo',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (change > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    change.toCurrency(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Mencetak struk...'), behavior: SnackBarBehavior.floating),
                  );

                  try {
                    final db = ref.read(databaseProvider);
                    final txRepo = TransactionRepositoryImpl(db);
                    final settingsRepo = SettingsRepositoryImpl(db);
                    final txResult = await txRepo.getTransactionById(txId);
                    final profile = await settingsRepo.getStoreProfile();

                    await txResult.fold(
                      (failure) async {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Gagal mengambil data: ${failure.message}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                        );
                      },
                      (transaction) async {
                        final printService = ref.read(printServiceProvider.notifier);
                        final storeName = profile['store_name'] ?? 'Toko Saya';
                        final storeAddress = profile['store_address'] ?? '';
                        final storePhone = profile['store_phone'] ?? '';
                        final footer = profile['receipt_footer'] ?? 'Terima kasih!';
                        final paperWidth = profile['printer_paper_width'] ?? '58';
                        final printLogo = profile['print_logo'] == 'true';
                        final storeLogoPath = profile['store_logo'];

                        final ok = await printService.printReceipt(
                          transaction: transaction,
                          storeName: storeName,
                          storeAddress: storeAddress,
                          storePhone: storePhone,
                          receiptFooter: footer,
                          paperWidth: paperWidth,
                          printLogo: printLogo,
                          storeLogoPath: storeLogoPath,
                        );

                        if (!ok) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Gagal mencetak! Cek koneksi printer.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                          );
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Struk berhasil dicetak!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                          );
                        }
                      },
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                icon: const Icon(Icons.print_rounded),
                label: const Text('Cetak Struk', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Transaksi Baru',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
