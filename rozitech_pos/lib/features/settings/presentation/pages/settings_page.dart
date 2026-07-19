import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/db_constants.dart' as dbc;

import '../../../../routes/app_router.dart';
import '../../../../core/providers/role_providers.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/presentation/providers/user_session_notifier.dart';
import '../../../users/presentation/screens/user_management_screen.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/utils/local_file_helper.dart';
import 'package:image_picker/image_picker.dart';

final _settingsRepoProvider = settingsRepositoryProvider;
final _storeProfileProvider = storeProfileProvider;

/// Application settings page with DB persistence.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_storeProfileProvider);
    final role = ref.watch(currentRoleProvider) ?? UserRole.cashier;
    final isManagerOrAbove = role.isManagerOrAbove;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => ListView(
          children: [
            // ── Store Profile ────────────────────────────────────────
            _SectionHeader(title: 'Profil Toko'),
            _SettingsTile(
              icon: Icons.store_rounded,
              title: 'Nama Toko',
              subtitle: profile['store_name'] ?? 'Belum diisi',
              onTap: isManagerOrAbove
                  ? () => _showEditDialog(
                        context,
                        ref,
                        field: 'Nama Toko',
                        settingKey: dbc.DbConstants.keyStoreName,
                        currentValue: profile['store_name'] ?? '',
                      )
                  : null, // Disabled for Cashier
            ),
            _SettingsTile(
              icon: Icons.location_on_rounded,
              title: 'Alamat Toko',
              subtitle: profile['store_address'] ?? 'Belum diisi',
              onTap: isManagerOrAbove
                  ? () => _showEditDialog(
                        context,
                        ref,
                        field: 'Alamat Toko',
                        settingKey: dbc.DbConstants.keyStoreAddress,
                        currentValue: profile['store_address'] ?? '',
                        maxLines: 3,
                      )
                  : null, // Disabled for Cashier
            ),
            _SettingsTile(
              icon: Icons.phone_rounded,
              title: 'Telepon',
              subtitle: profile['store_phone']?.isEmpty ?? true
                  ? 'Belum diisi'
                  : profile['store_phone']!,
              onTap: isManagerOrAbove
                  ? () => _showEditDialog(
                        context,
                        ref,
                        field: 'Telepon',
                        settingKey: dbc.DbConstants.keyStorePhone,
                        currentValue: profile['store_phone'] ?? '',
                        inputType: TextInputType.phone,
                      )
                  : null, // Disabled for Cashier
            ),
            _SettingsTile(
              icon: Icons.email_rounded,
              title: 'Email',
              subtitle: profile['store_email']?.isEmpty ?? true
                  ? 'Belum diisi'
                  : profile['store_email']!,
              onTap: isManagerOrAbove
                  ? () => _showEditDialog(
                        context,
                        ref,
                        field: 'Email',
                        settingKey: 'store_email',
                        currentValue: profile['store_email'] ?? '',
                        inputType: TextInputType.emailAddress,
                      )
                  : null, // Disabled for Cashier
            ),

            // ── Receipt ────────────────────────────────────────────
            _SectionHeader(title: 'Struk'),
            _SettingsTile(
              icon: Icons.receipt_long_rounded,
              title: 'Pesan Kaki Struk',
              subtitle: profile['receipt_footer'] ??
                  'Terima kasih atas kunjungan Anda!',
              onTap: isManagerOrAbove
                  ? () => _showEditDialog(
                        context,
                        ref,
                        field: 'Pesan Kaki Struk',
                        settingKey: dbc.DbConstants.keyReceiptFooter,
                        currentValue: profile['receipt_footer'] ?? '',
                        maxLines: 3,
                      )
                  : null, // Disabled for Cashier
            ),
            _SettingsTile(
              icon: Icons.print_rounded,
              title: 'Lebar Kertas',
              subtitle: '${profile['printer_paper_width'] ?? '58'} mm',
              onTap: isManagerOrAbove
                  ? () => _showWidthDialog(context, ref,
                      current: profile['printer_paper_width'] ?? '58')
                  : null, // Disabled for Cashier
            ),
            const _BluetoothPrinterSection(),
            _SettingsTile(
              icon: Icons.bluetooth_searching_rounded,
              title: 'Pengaturan Printer Lengkap',
              subtitle: 'Lihat semua printer, status koneksi, test print',
              onTap: () => context.push(AppRoutes.settingsPrinter),
            ),
            if (isManagerOrAbove) ...[
              SwitchListTile(
                value: profile['print_logo'] == 'true',
                onChanged: (v) async {
                  await ref.read(_settingsRepoProvider).set(dbc.DbConstants.keyPrintLogo, v.toString());
                  ref.invalidate(_storeProfileProvider);
                },
                secondary: Icon(
                  Icons.image_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Cetak Logo di Struk'),
                subtitle: Text(profile['print_logo'] == 'true' ? 'Aktif' : 'Nonaktif'),
              ),
              if (profile['print_logo'] == 'true')
                _SettingsTile(
                  icon: Icons.upload_file_rounded,
                  title: 'Logo Toko',
                  subtitle: profile['store_logo'] != null && profile['store_logo']!.isNotEmpty
                      ? 'Path: ${profile['store_logo']}'
                      : 'Belum diunggah',
                  onTap: () => _pickStoreLogo(context, ref),
                  trailing: profile['store_logo'] != null && profile['store_logo']!.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                              onPressed: () async {
                                await ref.read(_settingsRepoProvider).set(dbc.DbConstants.keyStoreLogo, null);
                                ref.invalidate(_storeProfileProvider);
                              },
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        )
                      : null,
                ),
            ],

            // ── Finance ────────────────────────────────────────────
            if (isManagerOrAbove) ...[
              _SectionHeader(title: 'Keuangan'),
              _SettingsTile(
                icon: Icons.attach_money_rounded,
                title: 'Simbol Mata Uang',
                subtitle: profile['currency_symbol'] ?? 'Rp',
                onTap: () => _showEditDialog(
                  context,
                  ref,
                  field: 'Simbol Mata Uang',
                  settingKey: dbc.DbConstants.keyCurrencySymbol,
                  currentValue: profile['currency_symbol'] ?? 'Rp',
                ),
              ),
              _SettingsTile(
                icon: Icons.percent_rounded,
                title: 'Tarif Pajak Default',
                subtitle: '${profile['tax_rate'] ?? '0'}%',
                onTap: () => _showEditDialog(
                  context,
                  ref,
                  field: 'Tarif Pajak (%)',
                  settingKey: dbc.DbConstants.keyTaxRate,
                  currentValue: profile['tax_rate'] ?? '0',
                  inputType: TextInputType.number,
                ),
              ),
            ],

            // ── Payment Methods ─────────────────────────────────────
            if (isManagerOrAbove) ...[
              _SectionHeader(title: 'Metode Pembayaran'),
              _SettingsTile(
                icon: Icons.account_balance_rounded,
                title: 'Nama Bank Transfer',
                subtitle: profile['payment_bank_name'] ?? 'BCA',
                onTap: () => _showEditDialog(
                  context,
                  ref,
                  field: 'Nama Bank Transfer',
                  settingKey: 'payment_bank_name',
                  currentValue: profile['payment_bank_name'] ?? 'BCA',
                ),
              ),
              _SettingsTile(
                icon: Icons.credit_card_rounded,
                title: 'No. Rekening Transfer',
                subtitle: profile['payment_bank_account'] ?? '8730129031',
                onTap: () => _showEditDialog(
                  context,
                  ref,
                  field: 'No. Rekening Transfer',
                  settingKey: 'payment_bank_account',
                  currentValue: profile['payment_bank_account'] ?? '8730129031',
                  inputType: TextInputType.number,
                ),
              ),
              _SettingsTile(
                icon: Icons.person_pin_rounded,
                title: 'Nama Penerima Rekening',
                subtitle: profile['payment_bank_recipient'] ?? 'Kasir Kita',
                onTap: () => _showEditDialog(
                  context,
                  ref,
                  field: 'Nama Penerima Rekening',
                  settingKey: 'payment_bank_recipient',
                  currentValue: profile['payment_bank_recipient'] ?? 'Kasir Kita',
                ),
              ),
              _SettingsTile(
                icon: Icons.qr_code_2_rounded,
                title: 'Nama Merchant QRIS',
                subtitle: profile['qris_merchant_name'] ?? 'Kasir Kita Gateway',
                onTap: () => _showEditDialog(
                  context,
                  ref,
                  field: 'Nama Merchant QRIS',
                  settingKey: 'qris_merchant_name',
                  currentValue: profile['qris_merchant_name'] ?? 'Kasir Kita Gateway',
                ),
              ),
              _SettingsTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'NMID QRIS',
                subtitle: profile['qris_nmid'] ?? 'ID1020304050',
                onTap: () => _showEditDialog(
                  context,
                  ref,
                  field: 'NMID QRIS',
                  settingKey: 'qris_nmid',
                  currentValue: profile['qris_nmid'] ?? 'ID1020304050',
                ),
              ),
              _SettingsTile(
                icon: Icons.payment_rounded,
                title: 'Payment Gateway',
                subtitle: 'Midtrans, QRIS Dinamis, Qopay, ShopeePay',
                onTap: () => context.push(AppRoutes.settingsPaymentGateway),
              ),
            ],

            // ── Account & Security ─────────────────────────────────
            _SectionHeader(title: 'Akun & Keamanan'),
            if (role.isOwner) // Only Owner can manage users/cashiers
              _SettingsTile(
                icon: Icons.people_rounded,
                title: 'Kelola Pengguna',
                subtitle: 'Tambah, edit, atau nonaktifkan kasir',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                ),
              ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Keluar (Log Out)',
              subtitle: 'Keluar dari sesi kasir saat ini',
              onTap: () {
                ref.read(userSessionProvider.notifier).logout();
                context.go(AppRoutes.login);
              },
            ),

            // ── About ──────────────────────────────────────────────
            _SectionHeader(title: 'Tentang'),
            const _SettingsTile(
              icon: Icons.info_rounded,
              title: 'Versi Aplikasi',
              subtitle: 'v1.0.0 (Build 1)',
            ),
            _SettingsTile(
              icon: Icons.phonelink_setup_rounded,
              title: 'Persyaratan Sistem',
              subtitle: 'Lihat spesifikasi & kompatibilitas printer',
              onTap: () => _showSystemRequirementsDialog(context),
            ),
            const _SettingsTile(
              icon: Icons.business_rounded,
              title: 'Developer',
              subtitle: 'Kang Digital',
            ),
            const _SettingsTile(
              icon: Icons.language_rounded,
              title: 'Website',
              subtitle: 'https://kangdigital.web.id',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSystemRequirementsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Persyaratan Sistem & Kompatibilitas', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spesifikasi Perangkat:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 6),
              Text('• Sistem Offline: Berjalan 100% lokal pada 1 perangkat.'),
              Text('• Sistem Operasi: Android v.10 (Q) atau lebih baru.'),
              Text('• Memori: Minimal RAM 4GB.'),
              Text('• Harmony OS: Harmony OS 2.0 atau lebih baru.'),
              Text('• Catatan Device: Perangkat merek Advan kurang direkomendasikan.'),
              SizedBox(height: 16),
              Text(
                'Kompatibilitas Printer:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 6),
              Text('• Konektivitas: Printer Thermal Bluetooth.'),
              Text('• Ukuran Kertas: Mendukung lebar kertas 58mm dan 80mm.'),
              Text('• Tipe/Merek: Kompatibel dengan semua printer thermal standar ESC/POS (misalnya VSC, EPPOS, dll.).'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _pickStoreLogo(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Sumber Logo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: cs.primary),
                title: const Text('Ambil Foto Kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: cs.primary),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );
    if (file != null) {
      final relativePath = await LocalFileHelper.saveImagePermanently(file.path, 'store_logo');
      await ref.read(_settingsRepoProvider).set(dbc.DbConstants.keyStoreLogo, relativePath);
      ref.invalidate(_storeProfileProvider);
    }
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref, {
    required String field,
    required String settingKey,
    required String currentValue,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: currentValue);
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(labelText: field),
            autofocus: true,
            keyboardType: inputType,
            maxLines: maxLines,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(_settingsRepoProvider)
                    .set(settingKey, ctrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ref.invalidate(_storeProfileProvider);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showWidthDialog(BuildContext context, WidgetRef ref,
      {required String current}) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Lebar Kertas'),
        children: ['58', '80'].map((w) {
          return SimpleDialogOption(
            onPressed: () async {
              await ref
                  .read(_settingsRepoProvider)
                  .set(dbc.DbConstants.keyReceiptPaperWidth, w);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ref.invalidate(_storeProfileProvider);
              }
            },
            child: Row(
              children: [
                if (current == w)
                  const Icon(Icons.check_rounded,
                      size: 18, color: Colors.green),
                if (current == w) const SizedBox(width: 8),
                Text('$w mm'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      onTap: onTap,
    );
  }
}

class _BluetoothPrinterSection extends ConsumerStatefulWidget {
  const _BluetoothPrinterSection();

  @override
  ConsumerState<_BluetoothPrinterSection> createState() => _BluetoothPrinterSectionState();
}

class _BluetoothPrinterSectionState extends ConsumerState<_BluetoothPrinterSection> {
  List<BluetoothDeviceModel> _devices = [];
  bool _isLoadingDevices = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final printerState = ref.watch(printServiceProvider);
    final notifier = ref.read(printServiceProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Printer Bluetooth'),

        // ── Status Card ──────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: printerState.isConnected
                ? Colors.green.withValues(alpha: 0.08)
                : printerState.isConnecting
                    ? cs.primary.withValues(alpha: 0.08)
                    : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: printerState.isConnected
                  ? Colors.green.withValues(alpha: 0.4)
                  : printerState.isConnecting
                      ? cs.primary.withValues(alpha: 0.3)
                      : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: printerState.isConnected
                      ? Colors.green.withValues(alpha: 0.15)
                      : cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: printerState.isConnecting
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        printerState.isConnected
                            ? Icons.print_rounded
                            : Icons.print_disabled_rounded,
                        color: printerState.isConnected ? Colors.green : cs.onSurfaceVariant,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      printerState.isConnecting
                          ? 'Menghubungkan...'
                          : printerState.isConnected
                              ? printerState.connectedName ?? 'Printer Terhubung'
                              : 'Belum ada printer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: printerState.isConnected ? Colors.green.shade700 : cs.onSurface,
                      ),
                    ),
                    if (printerState.connectedMac != null)
                      Text(
                        printerState.connectedMac!,
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      )
                    else if (printerState.errorMessage != null)
                      Text(
                        printerState.errorMessage!,
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      )
                    else
                      Text(
                        'Tap tombol Scan untuk mencari printer',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              if (printerState.isConnected)
                Column(
                  children: [
                    // Test print button
                    IconButton(
                      icon: const Icon(Icons.print_rounded, color: Colors.green),
                      tooltip: 'Test Print',
                      onPressed: () => _testPrint(context, notifier, printerState),
                    ),
                    // Disconnect button
                    IconButton(
                      icon: const Icon(Icons.bluetooth_disabled_rounded, color: Colors.red, size: 20),
                      tooltip: 'Putuskan',
                      onPressed: () => _disconnect(context, notifier),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // ── Error message ─────────────────────────────────────────────────
        if (printerState.errorMessage != null && !printerState.isConnected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    printerState.errorMessage!,
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),

        // ── Scan Button ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: _isLoadingDevices
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.bluetooth_searching_rounded, size: 18),
                  label: Text(_isLoadingDevices ? 'Scanning...' : 'Scan Printer Bluetooth'),
                  onPressed: _isLoadingDevices ? null : () => _scanDevices(notifier),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Device List ──────────────────────────────────────────────────
        if (_devices.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              'Perangkat Tersedia (${_devices.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          ...List.generate(_devices.length, (i) {
            final dev = _devices[i];
            final isCurrentlyConnected =
                printerState.isConnected && printerState.connectedMac == dev.address;

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              decoration: BoxDecoration(
                color: isCurrentlyConnected
                    ? Colors.green.withValues(alpha: 0.06)
                    : cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentlyConnected
                      ? Colors.green.withValues(alpha: 0.4)
                      : cs.outlineVariant,
                ),
              ),
              child: ListTile(
                dense: true,
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      dev.isPrinter
                          ? Icons.print_rounded
                          : Icons.bluetooth_rounded,
                      color: isCurrentlyConnected ? Colors.green : cs.primary,
                    ),
                    if (dev.isPrinter)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  dev.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isCurrentlyConnected ? Colors.green.shade700 : cs.onSurface,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(dev.address, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                    if (dev.isPrinter) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRINTER',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: isCurrentlyConnected
                    ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                    : printerState.isConnecting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.link_rounded, color: cs.primary, size: 20),
                onTap: isCurrentlyConnected || printerState.isConnecting
                    ? null
                    : () => _connectToDevice(context, notifier, dev),
              ),
            );
          }),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '● Dot hijau = terdeteksi sebagai printer thermal\n● Jika printer tidak muncul, pasangkan dulu di Pengaturan Bluetooth HP',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _scanDevices(PrintService notifier) async {
    setState(() {
      _devices = [];
      _isLoadingDevices = true;
    });
    final list = await notifier.getPairedDevices();
    if (mounted) {
      setState(() {
        _devices = list;
        _isLoadingDevices = false;
      });
    }
  }

  Future<void> _connectToDevice(BuildContext context, PrintService notifier, BluetoothDeviceModel dev) async {
    final ok = await notifier.connect(dev.address, name: dev.name);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? '✓ Berhasil terhubung ke ${dev.name}'
              : '✗ Gagal terhubung ke ${dev.name}'),
          backgroundColor: ok ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testPrint(BuildContext context, PrintService notifier, PrinterState state) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mencetak halaman test...'), behavior: SnackBarBehavior.floating),
    );
    final ok = await notifier.printTestPage();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '✓ Test print berhasil!' : '✗ Test print gagal'),
          backgroundColor: ok ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _disconnect(BuildContext context, PrintService notifier) async {
    await notifier.disconnect();
    setState(() => _devices = []);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer terputus'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
