import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/print_service.dart';

/// Bluetooth Printer Settings Screen.
/// Lists all paired Bluetooth devices and allows connecting/disconnecting.
/// Supports ALL classic Bluetooth printers (not BLE).
class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState
    extends ConsumerState<PrinterSettingsScreen> {
  List<BluetoothDeviceModel> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _devices = [];
    });
    final notifier = ref.read(printServiceProvider.notifier);
    final devices = await notifier.getPairedDevices();
    if (mounted) {
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final printerState = ref.watch(printServiceProvider);
    final notifier = ref.read(printServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer Bluetooth'),
        actions: [
          IconButton(
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Scan ulang',
            onPressed: _isScanning ? null : _scanDevices,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Status card ─────────────────────────────────────────────────
          _StatusCard(
            printerState: printerState,
            onDisconnect: () => _disconnect(context, notifier),
            onTestPrint: () => _testPrint(context, notifier),
          ),
          const SizedBox(height: 20),

          // ── Info banner ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: cs.onSecondaryContainer, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hanya menampilkan printer yang sudah dipasangkan '
                    'di Pengaturan Bluetooth perangkat. '
                    'Mendukung semua printer Bluetooth Thermal standar ESC/POS '
                    '(58mm dan 80mm).',
                    style: TextStyle(
                        fontSize: 12, color: cs.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Device list header ─────────────────────────────────────────
          Row(
            children: [
              Text(
                'Perangkat Tersedia',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              if (_isScanning)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: cs.primary),
                )
              else if (_devices.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_devices.length}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: cs.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Device list ────────────────────────────────────────────────
          if (_isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Mencari printer Bluetooth...'),
                  ],
                ),
              ),
            )
          else if (_devices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.bluetooth_disabled_rounded,
                        size: 56,
                        color: cs.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada perangkat Bluetooth ditemukan',
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pasangkan printer di Pengaturan Bluetooth HP Anda',
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _scanDevices,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._devices.map((dev) => _DeviceTile(
                  device: dev,
                  printerState: printerState,
                  onConnect: () => _connectDevice(context, notifier, dev),
                )),

          if (_devices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '🟢 Titik hijau = terdeteksi sebagai printer thermal\n'
              '📱 Pastikan Bluetooth aktif dan printer sudah dipasangkan',
              style:
                  TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _connectDevice(
    BuildContext context,
    PrintService notifier,
    BluetoothDeviceModel dev,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menghubungkan ke ${dev.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    final ok = await notifier.connect(dev.address, name: dev.name);
    if (!context.mounted) return;
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

  Future<void> _disconnect(
      BuildContext context, PrintService notifier) async {
    await notifier.disconnect();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printer terputus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _testPrint(
      BuildContext context, PrintService notifier) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mencetak halaman test...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    final ok = await notifier.printTestPage();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '✓ Test print berhasil!' : '✗ Test print gagal'),
        backgroundColor: ok ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.printerState,
    required this.onDisconnect,
    required this.onTestPrint,
  });

  final PrinterState printerState;
  final VoidCallback onDisconnect;
  final VoidCallback onTestPrint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isConnected = printerState.isConnected;
    final isConnecting = printerState.isConnecting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withValues(alpha: 0.08)
            : isConnecting
                ? cs.primary.withValues(alpha: 0.08)
                : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected
              ? Colors.green.withValues(alpha: 0.4)
              : isConnecting
                  ? cs.primary.withValues(alpha: 0.3)
                  : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.green.withValues(alpha: 0.15)
                  : cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isConnecting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isConnected
                        ? Icons.print_rounded
                        : Icons.print_disabled_rounded,
                    color: isConnected ? Colors.green : cs.onSurfaceVariant,
                    size: 26,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnecting
                      ? 'Menghubungkan...'
                      : isConnected
                          ? printerState.connectedName ?? 'Printer Terhubung'
                          : 'Belum Ada Printer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isConnected
                        ? Colors.green.shade700
                        : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                // Status indicator
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected
                            ? Colors.green
                            : isConnecting
                                ? Colors.orange
                                : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected
                          ? '● Terhubung  ${printerState.connectedMac ?? ''}'
                          : isConnecting
                              ? '● Menghubungkan...'
                              : '● Tidak Terhubung',
                      style: TextStyle(
                        fontSize: 11,
                        color: isConnected
                            ? Colors.green
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (printerState.errorMessage != null &&
                    !isConnected) ...[
                  const SizedBox(height: 4),
                  Text(
                    printerState.errorMessage!,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          if (isConnected)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.print_rounded, color: Colors.green),
                  tooltip: 'Test Print',
                  onPressed: onTestPrint,
                ),
                IconButton(
                  icon: const Icon(Icons.bluetooth_disabled_rounded,
                      color: Colors.red, size: 20),
                  tooltip: 'Putuskan',
                  onPressed: onDisconnect,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Device Tile ───────────────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.printerState,
    required this.onConnect,
  });

  final BluetoothDeviceModel device;
  final PrinterState printerState;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCurrentDevice = printerState.isConnected &&
        printerState.connectedMac == device.address;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentDevice
            ? Colors.green.withValues(alpha: 0.06)
            : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentDevice
              ? Colors.green.withValues(alpha: 0.4)
              : cs.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              device.isPrinter
                  ? Icons.print_rounded
                  : Icons.bluetooth_rounded,
              color: isCurrentDevice ? Colors.green : cs.primary,
              size: 26,
            ),
            if (device.isPrinter)
              Positioned(
                right: -3,
                top: -3,
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
          device.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isCurrentDevice ? Colors.green.shade700 : cs.onSurface,
          ),
        ),
        subtitle: Text(
          device.address,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
        trailing: isCurrentDevice
            ? const Icon(Icons.check_circle_rounded, color: Colors.green)
            : printerState.isConnecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.link_rounded, color: cs.primary, size: 20),
        onTap: (isCurrentDevice || printerState.isConnecting)
            ? null
            : onConnect,
      ),
    );
  }
}
