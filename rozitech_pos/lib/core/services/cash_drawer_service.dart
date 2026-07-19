import 'package:logger/logger.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

/// Service for opening the cash drawer via ESC/POS over Bluetooth.
class CashDrawerService {
  CashDrawerService._();

  static final _log = Logger();

  /// ESC/POS cash-drawer kick command: ESC p m t1 t2
  /// \x1B\x70\x00\x32\x32
  static const List<int> _kickCommand = [0x1B, 0x70, 0x00, 0x32, 0x32];

  /// Sends the cash-drawer kick command to the connected Bluetooth printer.
  /// Gracefully logs and ignores any error so the app never crashes.
  static Future<void> openCashDrawer() async {
    try {
      final connected = await PrintBluetoothThermal.connectionStatus;
      if (!connected) {
        _log.w('CashDrawerService: no printer connected, skipping drawer kick');
        return;
      }
      await PrintBluetoothThermal.writeBytes(_kickCommand);
      _log.i('CashDrawerService: cash drawer kick sent');
    } catch (e) {
      _log.w('CashDrawerService: failed to open cash drawer: $e');
    }
  }
}
