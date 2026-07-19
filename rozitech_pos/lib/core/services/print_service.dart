import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import '../../features/sales/domain/entities/transaction.dart';
import '../utils/extensions.dart';
import '../utils/local_file_helper.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class BluetoothDeviceModel {
  final String name;
  final String address;
  final bool isPrinter; // heuristic: contains 'printer', 'thermal', 'POS', etc.

  const BluetoothDeviceModel({
    required this.name,
    required this.address,
    this.isPrinter = false,
  });

  /// Returns true if the device name suggests it is a thermal printer.
  static bool _looksLikePrinter(String name) {
    const keywords = [
      'printer', 'print', 'thermal', 'pos', 'receipt',
      'rp', 'xp', 'gp', 'pt', 'hm', 'mp', 'mtp',
      'zj', 'bt', 'btp', 'ppt', 'esc', 'epson', 'star',
      'citizen', 'sewoo', 'bixolon', 'datecs', 'woosim',
      'blueprint', 'cashino', 'gprinter', 'rongta',
    ];
    final lower = name.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }

  factory BluetoothDeviceModel.fromInfo(BluetoothInfo info) {
    return BluetoothDeviceModel(
      name: info.name.isNotEmpty ? info.name : 'Unknown (${info.macAdress})',
      address: info.macAdress,
      isPrinter: _looksLikePrinter(info.name),
    );
  }
}

// ─── State ───────────────────────────────────────────────────────────────────

class PrinterState {
  final bool isConnected;
  final bool isScanning;
  final bool isConnecting;
  final String? connectedMac;
  final String? connectedName;
  final String? errorMessage;

  const PrinterState({
    this.isConnected = false,
    this.isScanning = false,
    this.isConnecting = false,
    this.connectedMac,
    this.connectedName,
    this.errorMessage,
  });

  PrinterState copyWith({
    bool? isConnected,
    bool? isScanning,
    bool? isConnecting,
    String? connectedMac,
    String? connectedName,
    String? errorMessage,
    bool clearError = false,
    bool clearDevice = false,
  }) {
    return PrinterState(
      isConnected: isConnected ?? this.isConnected,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      connectedMac: clearDevice ? null : (connectedMac ?? this.connectedMac),
      connectedName: clearDevice ? null : (connectedName ?? this.connectedName),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

class PrintService extends StateNotifier<PrinterState> {
  PrintService() : super(const PrinterState()) {
    _autoReconnect();
  }

  static const _keyMac = 'printer_mac';
  static const _keyName = 'printer_name';

  /// Auto-reconnect ke printer terakhir yang tersimpan
  Future<void> _autoReconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mac = prefs.getString(_keyMac);
      final name = prefs.getString(_keyName) ?? 'Printer';
      if (mac == null || mac.isEmpty) return;

      state = state.copyWith(isConnecting: true, connectedName: name, connectedMac: mac, clearError: true);

      final isOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isOn) {
        state = state.copyWith(isConnecting: false, errorMessage: 'Bluetooth tidak aktif');
        return;
      }

      final ok = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      state = state.copyWith(
        isConnecting: false,
        isConnected: ok,
        connectedMac: ok ? mac : null,
        connectedName: ok ? name : null,
        clearDevice: !ok,
        errorMessage: ok ? null : 'Gagal reconnect ke $name',
      );
    } catch (e) {
      state = state.copyWith(isConnecting: false, errorMessage: e.toString());
    }
  }

  /// Scan semua perangkat Bluetooth yang sudah dipasangkan (paired)
  Future<List<BluetoothDeviceModel>> getPairedDevices() async {
    try {
      state = state.copyWith(isScanning: true, clearError: true);

      if (Platform.isAndroid) {
        // Request Bluetooth permissions dynamically
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();
      }

      final isOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isOn) {
        state = state.copyWith(isScanning: false, errorMessage: 'Aktifkan Bluetooth terlebih dahulu');
        return [];
      }

      final isGranted = await PrintBluetoothThermal.isPermissionBluetoothGranted;
      if (!isGranted) {
        state = state.copyWith(isScanning: false, errorMessage: 'Izin Bluetooth diperlukan');
        return [];
      }

      final List<BluetoothInfo> list = await PrintBluetoothThermal.pairedBluetooths;
      final devices = list.map(BluetoothDeviceModel.fromInfo).toList();

      // Sort: printer-like devices first
      devices.sort((a, b) {
        if (a.isPrinter && !b.isPrinter) return -1;
        if (!a.isPrinter && b.isPrinter) return 1;
        return a.name.compareTo(b.name);
      });

      state = state.copyWith(isScanning: false);
      return devices;
    } catch (e) {
      state = state.copyWith(isScanning: false, errorMessage: 'Error: ${e.toString()}');
      return [];
    }
  }

  /// Connect ke perangkat berdasarkan MAC address
  Future<bool> connect(String macAddress, {String name = 'Printer'}) async {
    try {
      state = state.copyWith(isConnecting: true, clearError: true);

      final ok = await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);

      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyMac, macAddress);
        await prefs.setString(_keyName, name);

        state = state.copyWith(
          isConnecting: false,
          isConnected: true,
          connectedMac: macAddress,
          connectedName: name,
          clearError: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isConnecting: false,
          isConnected: false,
          errorMessage: 'Tidak dapat terhubung ke $name',
          clearDevice: true,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        errorMessage: e.toString(),
        clearDevice: true,
      );
      return false;
    }
  }

  /// Disconnect dari printer
  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyMac);
      await prefs.remove(_keyName);
      state = const PrinterState();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Check apakah masih terhubung secara live
  Future<bool> checkConnection() async {
    final ok = await PrintBluetoothThermal.connectionStatus;
    if (!ok && state.isConnected) {
      state = state.copyWith(isConnected: false, clearDevice: true);
    }
    return ok;
  }

  // ─── Printing ─────────────────────────────────────────────────────────────

  Future<bool> _ensureConnected() async {
    final ok = await PrintBluetoothThermal.connectionStatus;
    if (!ok) {
      // Try reconnect once
      final prefs = await SharedPreferences.getInstance();
      final mac = prefs.getString(_keyMac);
      if (mac != null && mac.isNotEmpty) {
        final reconnected = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        if (reconnected) {
          state = state.copyWith(isConnected: true);
          return true;
        }
      }
      state = state.copyWith(isConnected: false, clearDevice: true);
      return false;
    }
    return true;
  }

  Future<bool> printReceipt({
    required SalesTransaction transaction,
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required String receiptFooter,
    required String paperWidth,
    bool printLogo = false,
    String? storeLogoPath,
  }) async {
    if (!await _ensureConnected()) return false;

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = paperWidth == '80' ? PaperSize.mm80 : PaperSize.mm58;
      final generator = Generator(paperSize, profile);
      final int maxChars = paperWidth == '80' ? 48 : 32;
      List<int> bytes = [];

      // Cash Drawer Kick (ESC p)
      bytes += [27, 112, 0, 25, 250];

      // Logo
      if (printLogo && storeLogoPath != null && storeLogoPath.isNotEmpty) {
        final logoFile = await LocalFileHelper.getFile(storeLogoPath);
        if (await logoFile.exists()) {
          try {
            final logoBytes = await logoFile.readAsBytes();
            final image = img.decodeImage(logoBytes);
            if (image != null) {
              final resized = img.copyResize(image, width: paperWidth == '80' ? 320 : 200);
              bytes += generator.imageRaster(resized, align: PosAlign.center);
              bytes += generator.feed(1);
            }
          } catch (e) {
            debugPrint('Logo error: $e');
          }
        }
      }

      // Store Header
      bytes += generator.text(
        storeName,
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
      );
      if (storeAddress.isNotEmpty) {
        bytes += generator.text(storeAddress, styles: const PosStyles(align: PosAlign.center));
      }
      if (storePhone.isNotEmpty) {
        bytes += generator.text('Telp: $storePhone', styles: const PosStyles(align: PosAlign.center));
      }
      bytes += generator.hr(ch: '=');

      // Invoice Info
      bytes += generator.text('No: ${transaction.transactionNumber}', styles: const PosStyles(bold: true));
      bytes += generator.text('Tgl: ${transaction.createdAt.toDateTimeString()}');
      if (transaction.userId != null) {
        bytes += generator.text('Kasir: #${transaction.userId}');
      }
      bytes += generator.hr(ch: '-');

      // Items
      for (final item in transaction.items) {
        bytes += generator.text(item.productName, styles: const PosStyles(bold: true));
        final qtyStr = '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} x ${item.sellingPrice.toCurrency()}';
        final totalStr = item.lineTotal.toCurrency();
        final spaces = maxChars - qtyStr.length - totalStr.length;
        bytes += generator.text(qtyStr + ' ' * (spaces > 0 ? spaces : 1) + totalStr);
        if (item.discountAmount > 0) {
          bytes += generator.text('  Diskon: -${item.discountAmount.toCurrency()}', styles: const PosStyles(align: PosAlign.left));
        }
      }
      bytes += generator.hr(ch: '-');

      // Totals
      bytes += _rightLine('Subtotal:', transaction.subtotal.toCurrency(), maxChars, generator);
      if (transaction.discountAmount > 0) {
        bytes += _rightLine('Diskon:', '-${transaction.discountAmount.toCurrency()}', maxChars, generator);
      }
      if (transaction.taxAmount > 0) {
        bytes += _rightLine('Pajak:', transaction.taxAmount.toCurrency(), maxChars, generator);
      }
      bytes += generator.hr(ch: '=');
      bytes += _rightLine('TOTAL:', transaction.total.toCurrency(), maxChars, generator, bold: true);
      bytes += _rightLine('Bayar:', transaction.paymentAmount.toCurrency(), maxChars, generator);
      bytes += _rightLine('Kembali:', transaction.changeAmount.toCurrency(), maxChars, generator);
      bytes += generator.hr(ch: '-');

      // Footer
      final footer = receiptFooter.isNotEmpty ? receiptFooter : 'Terima kasih atas kunjungan Anda!';
      bytes += generator.text(footer, styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('- CASIR POS -', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(3);
      if (paperWidth == '80') {
        bytes += generator.cut();
      }

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Print error: $e');
      return false;
    }
  }

  Future<bool> printShippingLabel({
    required String courierName,
    required String trackingNumber,
    required String senderName,
    required String senderPhone,
    required String senderAddress,
    required String recipientName,
    required String recipientPhone,
    required String recipientAddress,
    required String weight,
    required String notes,
    required String paperWidth,
  }) async {
    if (!await _ensureConnected()) return false;

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = paperWidth == '80' ? PaperSize.mm80 : PaperSize.mm58;
      final generator = Generator(paperSize, profile);
      List<int> bytes = [];

      bytes += generator.text(
        'RESI PENGIRIMAN',
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
      );
      bytes += generator.hr(ch: '=');
      bytes += generator.text('Kurir: $courierName', styles: const PosStyles(bold: true));
      bytes += generator.text('No. Resi: $trackingNumber', styles: const PosStyles(bold: true));
      if (weight.isNotEmpty) bytes += generator.text('Berat: $weight Kg');
      bytes += generator.hr(ch: '-');

      bytes += generator.text('PENGIRIM:', styles: const PosStyles(bold: true));
      bytes += generator.text(senderName);
      if (senderPhone.isNotEmpty) bytes += generator.text('HP: $senderPhone');
      if (senderAddress.isNotEmpty) bytes += generator.text(senderAddress);
      bytes += generator.hr(ch: '-');

      bytes += generator.text('PENERIMA:', styles: const PosStyles(bold: true));
      bytes += generator.text(recipientName);
      if (recipientPhone.isNotEmpty) bytes += generator.text('HP: $recipientPhone');
      if (recipientAddress.isNotEmpty) bytes += generator.text(recipientAddress);

      if (notes.isNotEmpty) {
        bytes += generator.hr(ch: '-');
        bytes += generator.text('Catatan: $notes');
      }

      bytes += generator.hr(ch: '=');
      bytes += generator.text('Dibuat via CASIR POS', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(3);
      if (paperWidth == '80') {
        bytes += generator.cut();
      }

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Shipping label error: $e');
      return false;
    }
  }

  Future<bool> openCashDrawer() async {
    try {
      if (!await _ensureConnected()) return false;
      return await PrintBluetoothThermal.writeBytes([27, 112, 0, 25, 250]);
    } catch (e) {
      debugPrint('Cash drawer error: $e');
      return false;
    }
  }

  Future<bool> printTestPage({String paperWidth = '58'}) async {
    if (!await _ensureConnected()) return false;

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = paperWidth == '80' ? PaperSize.mm80 : PaperSize.mm58;
      final generator = Generator(paperSize, profile);
      List<int> bytes = [];

      bytes += generator.text('--- TEST PRINT ---', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.hr();
      bytes += generator.text('CASIR POS', styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2));
      bytes += generator.hr();
      bytes += generator.text('Normal text');
      bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
      bytes += generator.text('Italic text', styles: const PosStyles());
      bytes += generator.text('Large text', styles: const PosStyles(height: PosTextSize.size2, width: PosTextSize.size2));
      bytes += generator.hr();
      bytes += generator.text('Printer berfungsi dengan baik!', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Koneksi Bluetooth OK ✓', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.hr();
      bytes += generator.feed(2);
      if (paperWidth == '80') {
        bytes += generator.cut();
      }

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Test print error: $e');
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  List<int> _rightLine(String label, String value, int maxChars, Generator gen, {bool bold = false}) {
    final spaces = maxChars - label.length - value.length;
    final line = label + ' ' * (spaces > 0 ? spaces : 1) + value;
    return gen.text(line, styles: PosStyles(bold: bold));
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final printServiceProvider = StateNotifierProvider<PrintService, PrinterState>((ref) {
  return PrintService();
});
