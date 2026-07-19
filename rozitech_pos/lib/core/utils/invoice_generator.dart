import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Generates unique invoice numbers and UUIDs.
class InvoiceGenerator {
  InvoiceGenerator._();

  static const _uuid = Uuid();

  /// Generate invoice number: INV-20240710-0001
  static String generate({String prefix = 'INV', int sequence = 1}) {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    final seq = sequence.toString().padLeft(4, '0');
    return '$prefix-$date-$seq';
  }

  /// Generate a random UUID v4.
  static String uuid() => _uuid.v4();

  /// Generate a compact random ID (8 chars uppercase).
  static String shortId() {
    return _uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase();
  }
}
