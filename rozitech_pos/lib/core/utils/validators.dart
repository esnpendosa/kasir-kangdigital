/// Reusable validators for Casir POS.
class Validators {
  Validators._();

  /// Returns true if [value] is not null and not blank.
  static bool isNotBlank(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Returns true if [value] is >= 0.
  static bool isNonNegative(num? value) => value != null && value >= 0;

  /// Validates Indonesian phone numbers.
  /// Accepts: 08xx, +628xx, 628xx — 10 to 14 digits.
  static bool isValidPhone(String? value) {
    if (value == null || value.isEmpty) return false;
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,10}$').hasMatch(cleaned);
  }

  /// Validates email with a standard RFC 5322-like pattern.
  static bool isValidEmail(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value);
  }

  /// Returns error string if [value] is blank, null otherwise.
  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (!isNotBlank(value)) return '$fieldName tidak boleh kosong';
    return null;
  }

  /// Returns error string if price text is invalid/negative.
  static String? nonNegativePrice(String? value) {
    if (value == null || value.isEmpty) return 'Harga tidak boleh kosong';
    final num? parsed = num.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Harga harus berupa angka';
    if (!isNonNegative(parsed)) return 'Harga tidak boleh negatif';
    return null;
  }

  /// Returns error string if [value] is not a positive integer.
  static String? positiveInteger(String? value, {String fieldName = 'Jumlah'}) {
    if (value == null || value.isEmpty) return '$fieldName tidak boleh kosong';
    final int? parsed = int.tryParse(value);
    if (parsed == null) return '$fieldName harus berupa bilangan bulat';
    if (parsed < 0) return '$fieldName tidak boleh negatif';
    return null;
  }

  /// Validates SKU (alphanumeric, 3-50 chars).
  static bool isValidSku(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9\-_]{1,50}$').hasMatch(value.trim());
  }
}
