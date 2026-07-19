import 'package:intl/intl.dart';

/// Collection of format helpers used across the app.
extension CurrencyFormat on double {
  /// Format as IDR, e.g. "Rp 1.500.000"
  String toCurrency({String symbol = 'Rp', String locale = 'id_ID'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$symbol ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  /// Format as percentage, e.g. "12.5%"
  String toPercent({int decimals = 1}) => '${toStringAsFixed(decimals)}%';

  /// Compact number, e.g. 1500000 → "1.5 Jt"
  String toCompact({String locale = 'id_ID'}) {
    return NumberFormat.compact(locale: locale).format(this);
  }
}

extension DateTimeFormat on DateTime {
  String toDateString() => DateFormat('dd MMM yyyy', 'id_ID').format(this);
  String toDateTimeString() =>
      DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(this);
  String toTimeString() => DateFormat('HH:mm', 'id_ID').format(this);
  String toMonthYear() => DateFormat('MMMM yyyy', 'id_ID').format(this);
  String toInvoiceDate() => DateFormat('yyyyMMddHHmmss').format(this);
}

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$').hasMatch(this);
  }
}

extension DoubleExtension on double {
  /// Round to N decimal places.
  double roundTo(int places) {
    final factor = 10.0 * places;
    return (this * factor).roundToDouble() / factor;
  }
}
