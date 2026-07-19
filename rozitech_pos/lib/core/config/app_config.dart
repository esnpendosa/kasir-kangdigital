/// App-wide configuration constants.
/// This is the single source of truth for all config values.
class AppConfig {
  AppConfig._();

  // ─── App Identity ──────────────────────────────────────────────────────────
  static const String appName = 'Kasir UMKM';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String developer = 'Kang Digital';
  static const String website = 'https://kangdigital.web.id';

  // ─── REST API ───────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://kangdigital.web.id/api/';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── License ────────────────────────────────────────────────────────────────
  /// How often (in days) the license is re-validated online.
  static const int licenseCheckIntervalDays = 30;

  // ─── Database ───────────────────────────────────────────────────────────────
  static const String dbName = 'kasirkita_pos.db';
  static const int dbVersion = 1;

  // ─── Printer ────────────────────────────────────────────────────────────────
  static const int defaultPaperWidth58mm = 384; // dots
  static const int defaultPaperWidth80mm = 576; // dots

  // ─── Receipt ────────────────────────────────────────────────────────────────
  static const String defaultReceiptFooter = 'Terima kasih atas kunjungan Anda!';
  static const String defaultCurrency = 'IDR';
  static const String defaultCurrencySymbol = 'Rp';

  // ─── Pagination ─────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── Storage Keys ───────────────────────────────────────────────────────────
  static const String keyLicenseToken = 'license_token';
  static const String keyLicenseKey = 'license_key';
  static const String keyLicenseLastCheck = 'license_last_check';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboarded = 'onboarded';
}
