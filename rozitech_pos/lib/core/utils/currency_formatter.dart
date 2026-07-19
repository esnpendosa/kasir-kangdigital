import 'package:intl/intl.dart';

/// Currency formatter for Indonesian Rupiah and custom formats.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _idrCompactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  static final _numberFormatter = NumberFormat('#,###', 'id_ID');

  /// Formats [amount] as IDR, e.g. "Rp 150.000"
  static String format(double amount) => _idrFormatter.format(amount);

  /// Formats as compact, e.g. "Rp 1,5Jt"
  static String formatCompact(double amount) =>
      _idrCompactFormatter.format(amount);

  /// Formats number only without currency symbol, e.g. "150.000"
  static String formatNumber(double amount) => _numberFormatter.format(amount);

  /// Parses a formatted IDR string back to double.
  static double? parse(String value) {
    final cleaned = value
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned);
  }

  /// Custom format with specified symbol and decimals.
  static String formatCustom(
    double amount, {
    String symbol = 'Rp ',
    int decimalDigits = 0,
    String locale = 'id_ID',
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }
}
