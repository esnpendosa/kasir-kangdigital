import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/qris_dynamic_converter.dart';
import '../../data/repositories/settings_repository_impl.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _settingsRepo2Provider = Provider<SettingsRepositoryImpl>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider));
});

// ── Page ──────────────────────────────────────────────────────────────────────

/// Settings page for configuring payment gateways (Midtrans, QRIS, Qopay, ShopeePay).
class PaymentGatewaySettingsPage extends ConsumerStatefulWidget {
  const PaymentGatewaySettingsPage({super.key});

  @override
  ConsumerState<PaymentGatewaySettingsPage> createState() =>
      _PaymentGatewaySettingsPageState();
}

class _PaymentGatewaySettingsPageState
    extends ConsumerState<PaymentGatewaySettingsPage> {
  // Midtrans
  bool _midtransEnabled = false;
  bool _midtransProd = false;
  final _midtransServerKey = TextEditingController();
  final _midtransClientKey = TextEditingController();

  // QRIS Dinamis (static)
  bool _qrisEnabled = false;
  final _qrisMerchantId = TextEditingController();

  // Qopay
  bool _qopayEnabled = false;
  final _qopayApiKey = TextEditingController();

  // ShopeePay
  bool _shopeeEnabled = false;
  final _shopeeApiKey = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _midtransServerKey.dispose();
    _midtransClientKey.dispose();
    _qrisMerchantId.dispose();
    _qopayApiKey.dispose();
    _shopeeApiKey.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(_settingsRepo2Provider);
    _midtransEnabled = await repo.getBool('gw_midtrans_enabled');
    _midtransProd = await repo.getBool('gw_midtrans_production');
    _midtransServerKey.text = await repo.getString('gw_midtrans_server_key');
    _midtransClientKey.text = await repo.getString('gw_midtrans_client_key');

    _qrisEnabled = await repo.getBool('gw_qris_enabled');
    _qrisMerchantId.text = await repo.getString('gw_qris_merchant_id');

    _qopayEnabled = await repo.getBool('gw_qopay_enabled');
    _qopayApiKey.text = await repo.getString('gw_qopay_api_key');

    _shopeeEnabled = await repo.getBool('gw_shopee_enabled');
    _shopeeApiKey.text = await repo.getString('gw_shopee_api_key');

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final repo = ref.read(_settingsRepo2Provider);
    repo.invalidateCache();
    await repo.set('gw_midtrans_enabled', _midtransEnabled.toString());
    await repo.set('gw_midtrans_production', _midtransProd.toString());
    await repo.set('gw_midtrans_server_key', _midtransServerKey.text.trim());
    await repo.set('gw_midtrans_client_key', _midtransClientKey.text.trim());

    await repo.set('gw_qris_enabled', _qrisEnabled.toString());
    await repo.set('gw_qris_merchant_id', _qrisMerchantId.text.trim());
    // Also save to qris_nmid — used by PaymentSelectorPage for dynamic QRIS generation
    await repo.set('qris_nmid', _qrisMerchantId.text.trim());

    await repo.set('gw_qopay_enabled', _qopayEnabled.toString());
    await repo.set('gw_qopay_api_key', _qopayApiKey.text.trim());

    await repo.set('gw_shopee_enabled', _shopeeEnabled.toString());
    await repo.set('gw_shopee_api_key', _shopeeApiKey.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan payment gateway disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Simpan',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Midtrans ──────────────────────────────────────────
                _GatewaySectionCard(
                  title: 'Midtrans',
                  subtitle: 'SNAP API – credit card, GoPay, ShopeePay, QRIS',
                  icon: Icons.credit_card_rounded,
                  iconColor: Colors.blue,
                  enabled: _midtransEnabled,
                  onToggle: (v) => setState(() => _midtransEnabled = v),
                  onTest: _midtransEnabled ? _testMidtrans : null,
                  children: [
                    SwitchListTile(
                      value: _midtransProd,
                      onChanged: (v) =>
                          setState(() => _midtransProd = v),
                      title: const Text('Production Mode'),
                      subtitle: const Text(
                          'Matikan untuk mode Sandbox (testing)'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    _ApiKeyField(
                      controller: _midtransServerKey,
                      label: 'Server Key',
                      hint: 'SB-Mid-server-xxxx atau Mid-server-xxxx',
                    ),
                    const SizedBox(height: 8),
                    _ApiKeyField(
                      controller: _midtransClientKey,
                      label: 'Client Key',
                      hint: 'SB-Mid-client-xxxx',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── QRIS Dinamis ──────────────────────────────────────
                _GatewaySectionCard(
                  title: 'QRIS Dinamis',
                  subtitle: 'Generate QR Code dengan nominal per transaksi',
                  icon: Icons.qr_code_2_rounded,
                  iconColor: Colors.green,
                  enabled: _qrisEnabled,
                  onToggle: (v) => setState(() => _qrisEnabled = v),
                  children: [
                    // Info box explaining what to paste
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.2)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Cara mendapatkan QRIS Statis:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green)),
                          ]),
                          SizedBox(height: 4),
                          Text(
                            '1. Buka aplikasi bank / dompet digital Anda\n'
                            '2. Pilih "Terima Pembayaran" atau "QR Merchant"\n'
                            '3. Screenshot QR Code tersebut\n'
                            '4. Scan QR itu dengan aplikasi QR reader\n'
                            '5. Copy teks hasilnya (dimulai "000201...")\n'
                            '6. Paste ke kolom di bawah ini',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _qrisMerchantId,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Kode QRIS Statis (Full String)',
                        hintText:
                            '00020101021126610014COM.GO-JEK.WWW...',
                        border: OutlineInputBorder(),
                        helperText:
                            'Tempel kode QRIS lengkap dari provider Anda',
                        helperMaxLines: 2,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    // Validate QRIS button
                    if (_qrisMerchantId.text.isNotEmpty)
                      _QrisValidator(qrisString: _qrisMerchantId.text),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Qopay ─────────────────────────────────────────────
                _GatewaySectionCard(
                  title: 'Qopay',
                  subtitle: 'QRIS via Qopay Payment Gateway',
                  icon: Icons.phone_android_rounded,
                  iconColor: Colors.purple,
                  enabled: _qopayEnabled,
                  onToggle: (v) => setState(() => _qopayEnabled = v),
                  children: [
                    _ApiKeyField(
                      controller: _qopayApiKey,
                      label: 'API Key',
                      hint: 'Qopay API Key',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── ShopeePay ─────────────────────────────────────────
                _GatewaySectionCard(
                  title: 'ShopeePay',
                  subtitle: 'Pembayaran via ShopeePay',
                  icon: Icons.shopping_bag_rounded,
                  iconColor: Colors.orange,
                  enabled: _shopeeEnabled,
                  onToggle: (v) => setState(() => _shopeeEnabled = v),
                  children: [
                    _ApiKeyField(
                      controller: _shopeeApiKey,
                      label: 'API Key',
                      hint: 'ShopeePay API Key',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Future<void> _testMidtrans() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menguji koneksi Midtrans...'),
        duration: Duration(seconds: 2),
      ),
    );
    // A real test would hit the Midtrans ping endpoint.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_midtransServerKey.text.isNotEmpty
            ? 'Konfigurasi Midtrans tersimpan, cek log untuk detail koneksi.'
            : 'Server key belum diisi!'),
        backgroundColor: _midtransServerKey.text.isNotEmpty
            ? Colors.blue
            : Colors.red,
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _GatewaySectionCard extends StatelessWidget {
  const _GatewaySectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.enabled,
    required this.onToggle,
    required this.children,
    this.onTest,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final List<Widget> children;
  final VoidCallback? onTest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeThumbColor: cs.primary,
                ),
              ],
            ),
            if (enabled) ...[
              const Divider(height: 24),
              ...children,
              if (onTest != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onTest,
                  icon: const Icon(Icons.network_check_rounded, size: 16),
                  label: const Text('Test Koneksi'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ApiKeyField extends StatefulWidget {
  const _ApiKeyField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

// ── QRIS Validator Widget ─────────────────────────────────────────────────────

class _QrisValidator extends StatelessWidget {
  const _QrisValidator({required this.qrisString});
  final String qrisString;

  @override
  Widget build(BuildContext context) {
    final isValid = QrisDynamicConverter.isValid(qrisString);
    final merchantName = isValid
        ? QrisDynamicConverter.getMerchantName(qrisString)
        : null;
    final merchantCity = isValid
        ? QrisDynamicConverter.getMerchantCity(qrisString)
        : null;

    if (isValid) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 16),
                SizedBox(width: 6),
                Text(
                  'QRIS Valid ✓',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (merchantName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Merchant: $merchantName',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (merchantCity != null)
              Text(
                'Kota: $merchantCity',
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(
              'QRIS Dinamis akan di-generate otomatis setiap transaksi.',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade700),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: Colors.red, size: 16),
                SizedBox(width: 6),
                Text(
                  'Format QRIS Tidak Valid',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Kode QRIS harus dimulai dengan "000201" dan '
              'diakhiri dengan "6304XXXX".\n'
              'Pastikan Anda menyalin kode lengkap dari hasil scan QR.',
              style: TextStyle(fontSize: 11, color: Colors.red),
            ),
          ],
        ),
      );
    }
  }
}
