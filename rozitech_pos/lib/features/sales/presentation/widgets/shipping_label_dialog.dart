import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/database/database_provider.dart';
import '../../../settings/data/repositories/settings_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import 'package:share_plus/share_plus.dart';

class ShippingLabelDialog extends ConsumerStatefulWidget {
  const ShippingLabelDialog({super.key, required this.transaction});
  final SalesTransaction transaction;

  @override
  ConsumerState<ShippingLabelDialog> createState() => _ShippingLabelDialogState();
}

class _ShippingLabelDialogState extends ConsumerState<ShippingLabelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courierCtrl = TextEditingController(text: 'J&T Express');
  final _resiCtrl = TextEditingController();
  final _senderNameCtrl = TextEditingController();
  final _senderPhoneCtrl = TextEditingController();
  final _senderAddressCtrl = TextEditingController();
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _recipientAddressCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '1.0');
  final _notesCtrl = TextEditingController();

  bool _isLoadingProfile = true;
  String _paperWidth = '58';

  @override
  void initState() {
    super.initState();
    _loadStoreProfile();
  }

  Future<void> _loadStoreProfile() async {
    final db = ref.read(databaseProvider);
    final settingsRepo = SettingsRepositoryImpl(db);
    final profile = await settingsRepo.getStoreProfile();
    setState(() {
      _senderNameCtrl.text = profile['store_name'] ?? '';
      _senderPhoneCtrl.text = profile['store_phone'] ?? '';
      _senderAddressCtrl.text = profile['store_address'] ?? '';
      _paperWidth = profile['printer_paper_width'] ?? '58';
      _isLoadingProfile = false;
    });
  }

  @override
  void dispose() {
    _courierCtrl.dispose();
    _resiCtrl.dispose();
    _senderNameCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _senderAddressCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _recipientAddressCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cetak Resi Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _isLoadingProfile
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _courierCtrl,
                      decoration: const InputDecoration(labelText: 'Kurir / Ekspedisi'),
                      validator: (v) => v == null || v.isEmpty ? 'Kurir harus diisi' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _resiCtrl,
                      decoration: const InputDecoration(labelText: 'No. Resi / AWB'),
                      validator: (v) => v == null || v.isEmpty ? 'No. Resi harus diisi' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _weightCtrl,
                      decoration: const InputDecoration(labelText: 'Berat Paket (Kg)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Data Pengirim:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _senderNameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama Pengirim'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _senderPhoneCtrl,
                      decoration: const InputDecoration(labelText: 'No. HP Pengirim'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _senderAddressCtrl,
                      decoration: const InputDecoration(labelText: 'Alamat Pengirim'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Data Penerima:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recipientNameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama Penerima'),
                      validator: (v) => v == null || v.isEmpty ? 'Nama penerima harus diisi' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recipientPhoneCtrl,
                      decoration: const InputDecoration(labelText: 'No. HP Penerima'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recipientAddressCtrl,
                      decoration: const InputDecoration(labelText: 'Alamat Penerima'),
                      maxLines: 2,
                      validator: (v) => v == null || v.isEmpty ? 'Alamat penerima harus diisi' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(labelText: 'Catatan Pengiriman (COD/Fragile/dll)'),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          tooltip: 'Bagikan Teks Resi',
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final text = '''
*RESI PENGIRIMAN*
Ekspedisi: ${_courierCtrl.text}
No. Resi: ${_resiCtrl.text}
Berat: ${_weightCtrl.text} Kg

*PENGIRIM:*
${_senderNameCtrl.text} (${_senderPhoneCtrl.text})
${_senderAddressCtrl.text}

*PENERIMA:*
${_recipientNameCtrl.text} (${_recipientPhoneCtrl.text})
${_recipientAddressCtrl.text}

Catatan: ${_notesCtrl.text}
''';
              SharePlus.instance.share(ShareParams(text: text));
            }
          },
        ),
        ElevatedButton.icon(
          onPressed: _printLabel,
          icon: const Icon(Icons.print_rounded),
          label: const Text('Cetak'),
        ),
      ],
    );
  }

  Future<void> _printLabel() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final printNotifier = ref.read(printServiceProvider.notifier);
    final printerState = ref.read(printServiceProvider);
    if (!printerState.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer belum terhubung! Sambungkan di menu Pengaturan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ok = await printNotifier.printShippingLabel(
      courierName: _courierCtrl.text,
      trackingNumber: _resiCtrl.text,
      senderName: _senderNameCtrl.text,
      senderPhone: _senderPhoneCtrl.text,
      senderAddress: _senderAddressCtrl.text,
      recipientName: _recipientNameCtrl.text,
      recipientPhone: _recipientPhoneCtrl.text,
      recipientAddress: _recipientAddressCtrl.text,
      weight: _weightCtrl.text,
      notes: _notesCtrl.text,
      paperWidth: _paperWidth,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mencetak resi pengiriman!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mencetak resi! Periksa koneksi printer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
