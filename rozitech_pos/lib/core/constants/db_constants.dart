/// Database key constants for the settings key-value table.
class DbConstants {
  DbConstants._();

  // Settings keys
  static const String keyStoreName = 'store_name';
  static const String keyStoreAddress = 'store_address';
  static const String keyStorePhone = 'store_phone';
  static const String keyStoreEmail = 'store_email';
  static const String keyTaxId = 'tax_id';
  static const String keyTaxRate = 'tax_rate';
  static const String keyTaxEnabled = 'tax_enabled';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyCurrencyFormat = 'currency_format';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyReceiptHeader = 'receipt_header';
  static const String keyReceiptFooter = 'receipt_footer';
  static const String keyReceiptPaperWidth = 'receipt_paper_width';
  static const String keyPrintLogo = 'print_logo';
  static const String keyStoreLogo = 'store_logo';
  static const String keyLastVersionCheck = 'last_version_check';
  static const String keyBackupSchedule = 'backup_schedule';
  static const String keyReceiptThankYou = 'receipt_thank_you';
  
  // Payment gateway & bank settings
  static const String keyPaymentBankName = 'payment_bank_name';
  static const String keyPaymentBankAccount = 'payment_bank_account';
  static const String keyPaymentBankRecipient = 'payment_bank_recipient';
  static const String keyQrisMerchantName = 'qris_merchant_name';
  static const String keyQrisNmid = 'qris_nmid';

  // Default values
  static const String defaultCurrencySymbol = 'Rp';
  static const String defaultPaperWidth = '80';
  static const double defaultTaxRate = 11.0;
  static const String defaultLanguage = 'id';
  static const int dashboardCacheTtlMinutes = 5;
  static const int reportsCacheTtlHours = 1;

  // Report types
  static const String reportDailySales = 'daily_sales';
  static const String reportMonthlySales = 'monthly_sales';
  static const String reportProfit = 'profit';
  static const String reportProduct = 'product';
}
