import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/receipt_pdf_generator.dart';
import '../../../../core/services/print_service.dart';
import '../../../settings/data/repositories/settings_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../widgets/shipping_label_dialog.dart';

final _transactionRepoProvider = Provider<TransactionRepositoryImpl>((ref) {
  return TransactionRepositoryImpl(ref.watch(appDatabaseProvider));
});

class TransactionFilter {
  final DateTimeRange? dateRange;
  final String? paymentMethod;

  const TransactionFilter({
    this.dateRange,
    this.paymentMethod,
  });

  TransactionFilter copyWith({
    DateTimeRange? dateRange,
    String? paymentMethod,
    bool clearDate = false,
    bool clearPayment = false,
  }) {
    return TransactionFilter(
      dateRange: clearDate ? null : (dateRange ?? this.dateRange),
      paymentMethod: clearPayment ? null : (paymentMethod ?? this.paymentMethod),
    );
  }
}

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(const TransactionFilter());

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range, clearDate: range == null);
  }

  void setPaymentMethod(String? method) {
    state = state.copyWith(paymentMethod: method, clearPayment: method == null);
  }

  void reset() {
    state = const TransactionFilter();
  }
}

final _filterProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
  return TransactionFilterNotifier();
});

final _transactionsProvider =
    FutureProvider.family<List<SalesTransaction>, String>(
        (ref, query) async {
  final repo = ref.watch(_transactionRepoProvider);
  final filter = ref.watch(_filterProvider);

  DateRange? repoRange;
  if (filter.dateRange != null) {
    repoRange = DateRange(
      start: filter.dateRange!.start,
      end: DateTime(
        filter.dateRange!.end.year,
        filter.dateRange!.end.month,
        filter.dateRange!.end.day,
        23,
        59,
        59,
        999,
      ),
    );
  }

  final result = await repo.getTransactions(
    query: query.isEmpty ? null : query,
    range: repoRange,
    paymentMethod: filter.paymentMethod,
  );
  return result.getOrElse((_) => []);
});

/// Transaction history page with real DB data.
class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState
    extends ConsumerState<TransactionHistoryPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(_transactionsProvider(_query));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nomor invoice...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: txAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64,
                            color: cs.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty
                              ? 'Belum ada transaksi'
                              : 'Transaksi tidak ditemukan',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    return _TransactionTile(tx: transactions[i])
                        .animate()
                        .fadeIn(delay: (i * 20).ms);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final filter = ref.watch(_filterProvider);
            final notifier = ref.read(_filterProvider.notifier);
            final cs = Theme.of(context).colorScheme;

            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Transaksi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () {
                          notifier.reset();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date range selector
                  const Text('Rentang Tanggal',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final selected = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: filter.dateRange,
                      );
                      if (selected != null) {
                        notifier.setDateRange(selected);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: cs.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              filter.dateRange == null
                                  ? 'Pilih tanggal...'
                                  : '${filter.dateRange!.start.toDateString()} - ${filter.dateRange!.end.toDateString()}',
                              style: TextStyle(
                                color: filter.dateRange == null ? cs.onSurface.withValues(alpha: 0.5) : cs.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (filter.dateRange != null)
                            GestureDetector(
                              onTap: () => notifier.setDateRange(null),
                              child: Icon(Icons.clear_rounded, color: cs.onSurface.withValues(alpha: 0.5), size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment method selector
                  const Text('Metode Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPaymentChip(ref, notifier, null, 'Semua', cs),
                      const SizedBox(width: 8),
                      _buildPaymentChip(ref, notifier, 'cash', 'Tunai', cs),
                      const SizedBox(width: 8),
                      _buildPaymentChip(ref, notifier, 'card', 'Kartu', cs),
                      const SizedBox(width: 8),
                      _buildPaymentChip(ref, notifier, 'transfer', 'Transfer', cs),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Terapkan Filter'),
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

  Widget _buildPaymentChip(
    WidgetRef ref,
    TransactionFilterNotifier notifier,
    String? value,
    String label,
    ColorScheme cs,
  ) {
    final filter = ref.watch(_filterProvider);
    final isSelected = filter.paymentMethod == value;

    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (selected) {
          if (selected) {
            notifier.setPaymentMethod(value);
          }
        },
      ),
    );
  }
}
class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.tx});
  final SalesTransaction tx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isVoid = tx.status == 'void';

    return InkWell(
      onTap: () => _showTransactionDetails(context, ref, tx),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isVoid
                    ? Colors.red.withValues(alpha: 0.1)
                    : cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVoid ? Icons.cancel_rounded : Icons.receipt_long_rounded,
                color: isVoid ? Colors.red : cs.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.transactionNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(
                    '${tx.items.length} item · ${tx.paymentMethod.label}',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tx.total.toCurrency(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isVoid
                        ? cs.onSurface.withValues(alpha: 0.4)
                        : cs.onSurface,
                    decoration: isVoid ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(tx.createdAt.toDateTimeString(),
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.4))),
                if (isVoid)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('VOID',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

void _showTransactionDetails(BuildContext context, WidgetRef ref, SalesTransaction tx) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final isVoid = tx.status == 'void';

      return Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tx.transactionNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVoid ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isVoid ? 'VOID' : 'BERHASIL',
                      style: TextStyle(
                        color: isVoid ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tx.createdAt.toDateTimeString(),
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12),
              ),
              const Divider(height: 24),
              
              // Items List
              const Text(
                'Daftar Produk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tx.items.length,
                  itemBuilder: (context, idx) {
                    final item = tx.items[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} (${item.quantity.toStringAsFixed(0)}x)',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            item.lineTotal.toCurrency(),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 24),

              // Summary
              _detailRow('Subtotal', tx.subtotal.toCurrency()),
              if (tx.discountAmount > 0)
                _detailRow('Diskon', '-${tx.discountAmount.toCurrency()}', color: Colors.green),
              if (tx.taxAmount > 0)
                _detailRow('Pajak', tx.taxAmount.toCurrency()),
              const Divider(),
              _detailRow('TOTAL', tx.total.toCurrency(), isBold: true, fontSize: 16),
              _detailRow('Bayar', tx.paymentAmount.toCurrency()),
              _detailRow('Kembalian', tx.changeAmount.toCurrency()),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _printReceipt(context, ref, tx),
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Cetak Struk'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareReceipt(context, ref, tx, isPdf: true),
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('PDF Struk'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareReceipt(context, ref, tx, isPdf: false),
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Teks Struk'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => ShippingLabelDialog(transaction: tx),
                        );
                      },
                      icon: const Icon(Icons.local_shipping_rounded),
                      label: const Text('Cetak Resi Pengiriman'),
                    ),
                  ),
                  if (!isVoid) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () => _voidTransaction(context, ref, tx),
                        icon: const Icon(Icons.cancel_rounded),
                        label: const Text('Void'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _detailRow(String label, String value, {bool isBold = false, double fontSize = 13, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Future<void> _printReceipt(BuildContext context, WidgetRef ref, SalesTransaction tx) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final printNotifier = ref.read(printServiceProvider.notifier);
  final printerState = ref.read(printServiceProvider);

  if (!printerState.isConnected) {
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Printer belum terhubung! Sambungkan di menu Pengaturan.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final db = ref.read(databaseProvider);
  final settingsRepo = SettingsRepositoryImpl(db);
  final profile = await settingsRepo.getStoreProfile();

  scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Mencetak struk...')));
  final ok = await printNotifier.printReceipt(
    transaction: tx,
    storeName: profile['store_name'] ?? 'Toko Saya',
    storeAddress: profile['store_address'] ?? '',
    storePhone: profile['store_phone'] ?? '',
    receiptFooter: profile['receipt_footer'] ?? 'Terima kasih!',
    paperWidth: profile['printer_paper_width'] ?? '58',
    printLogo: profile['print_logo'] == 'true',
    storeLogoPath: profile['store_logo'],
  );
  if (!ok) {
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Gagal mencetak struk!'), backgroundColor: Colors.red),
    );
  }
}

Future<void> _shareReceipt(BuildContext context, WidgetRef ref, SalesTransaction tx, {required bool isPdf}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final db = ref.read(databaseProvider);
  final settingsRepo = SettingsRepositoryImpl(db);
  final profile = await settingsRepo.getStoreProfile();

  final storeName = profile['store_name'] ?? 'Toko Saya';
  final storeAddress = profile['store_address'] ?? '';
  final storePhone = profile['store_phone'] ?? '';
  final footer = profile['receipt_footer'] ?? 'Terima kasih!';

  if (isPdf) {
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Menyiapkan file PDF struk...')));
    final pdfBytes = await ReceiptPdfGenerator.generate(
      tx,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      receiptFooter: footer,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'struk_${tx.transactionNumber}.pdf',
    );
  } else {
    final buffer = StringBuffer();
    buffer.writeln('===================================');
    buffer.writeln('       ${storeName.toUpperCase()}       ');
    if (storeAddress.isNotEmpty) buffer.writeln(storeAddress);
    if (storePhone.isNotEmpty) buffer.writeln('Telp: $storePhone');
    buffer.writeln('===================================');
    buffer.writeln('No. Invoice: ${tx.transactionNumber}');
    buffer.writeln('Tanggal: ${tx.createdAt.toDateTimeString()}');
    buffer.writeln('-----------------------------------');
    for (final item in tx.items) {
      buffer.writeln(item.productName);
      buffer.writeln('  ${item.quantity.toStringAsFixed(0)} x ${item.sellingPrice.toCurrency()} = ${item.lineTotal.toCurrency()}');
    }
    buffer.writeln('-----------------------------------');
    buffer.writeln('Subtotal: ${tx.subtotal.toCurrency()}');
    if (tx.discountAmount > 0) {
      buffer.writeln('Diskon: -${tx.discountAmount.toCurrency()}');
    }
    if (tx.taxAmount > 0) {
      buffer.writeln('Pajak: ${tx.taxAmount.toCurrency()}');
    }
    buffer.writeln('TOTAL: ${tx.total.toCurrency()}');
    buffer.writeln('Bayar: ${tx.paymentAmount.toCurrency()}');
    buffer.writeln('Kembalian: ${tx.changeAmount.toCurrency()}');
    buffer.writeln('===================================');
    buffer.writeln(footer);
    buffer.writeln('===================================');
    buffer.writeln('Dibuat via CASIR POS');

    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }
}

Future<void> _voidTransaction(BuildContext context, WidgetRef ref, SalesTransaction tx) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final repo = ref.read(_transactionRepoProvider);

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Void Transaksi'),
      content: const Text('Apakah Anda yakin ingin membatalkan transaksi ini? Stok produk akan dikembalikan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Ya, Void'),
        ),
      ],
    ),
  );
  if (ok == true) {
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Memproses void...')));
    final result = await repo.voidTransaction(tx.id!);
    result.fold(
      (failure) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Gagal: ${failure.message}'), backgroundColor: Colors.red),
        );
      },
      (_) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil di-void!')),
        );
        ref.invalidate(_transactionsProvider);
        Navigator.pop(context); // Close details sheet
      },
    );
  }
}

