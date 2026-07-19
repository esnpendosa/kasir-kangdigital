import 'package:intl/intl.dart';

/// Date and time formatters for Casir POS (Indonesian locale).
class DateFormatter {
  DateFormatter._();

  static final _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTimeFormatter = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
  static final _timeFormatter = DateFormat('HH:mm', 'id_ID');
  static final _shortDateFormatter = DateFormat('dd/MM/yyyy', 'id_ID');
  static final _monthYearFormatter = DateFormat('MMMM yyyy', 'id_ID');
  static final _dbDateFormatter = DateFormat('yyyyMMdd');
  static final _isoFormatter = DateFormat('yyyy-MM-dd');

  /// Formats date as "15 Jan 2024"
  static String formatDate(DateTime date) => _dateFormatter.format(date);

  /// Formats date+time as "15 Jan 2024 14:30"
  static String formatDateTime(DateTime date) =>
      _dateTimeFormatter.format(date);

  /// Formats time only as "14:30"
  static String formatTime(DateTime date) => _timeFormatter.format(date);

  /// Formats date as "15/01/2024"
  static String formatShortDate(DateTime date) =>
      _shortDateFormatter.format(date);

  /// Formats as "Januari 2024"
  static String formatMonthYear(DateTime date) =>
      _monthYearFormatter.format(date);

  /// Formats as "20240115" — used in transaction numbers and DB keys
  static String formatDbDate(DateTime date) => _dbDateFormatter.format(date);

  /// Formats as ISO date "2024-01-15"
  static String formatIso(DateTime date) => _isoFormatter.format(date);

  /// Returns a relative label: "Hari ini", "Kemarin", or the formatted date.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return formatDate(date);
  }
}
