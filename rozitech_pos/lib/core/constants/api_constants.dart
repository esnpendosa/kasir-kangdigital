/// API endpoint constants for Kang Digital backend.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://kangdigital.web.id/api/';

  // ─── License endpoints ──────────────────────────────────────────────────
  static const String licenseActivate = 'license/activate';
  static const String licenseDeactivate = 'license/deactivate';
  static const String licenseRefresh = 'license/refresh';
  static const String licenseCheck = 'license/check';

  // ─── Version & Member ───────────────────────────────────────────────────
  static const String versionCheck = 'version';
  static const String memberSync = 'users';

  // ─── Store Management ───────────────────────────────────────────────────
  static const String stores = 'stores';
  static String storeUpdate(int id) => 'stores/$id';
  static String storeSyncPing(int id) => 'stores/$id/sync-ping';

  // ─── Data Sync (push & pull) ────────────────────────────────────────────
  static String syncCategories(int storeId) => 'sync/$storeId/categories';
  static String syncProducts(int storeId) => 'sync/$storeId/products';
  static String syncCustomers(int storeId) => 'sync/$storeId/customers';
  static String syncTransactions(int storeId) => 'sync/$storeId/transactions';
  static String syncExpenses(int storeId) => 'sync/$storeId/expenses';
  static String syncSuppliers(int storeId) => 'sync/$storeId/suppliers';
  static String syncPull(int storeId) => 'sync/$storeId/pull';
  static String syncReport(int storeId) => 'sync/$storeId/report';

  // ─── Cloud Backup ───────────────────────────────────────────────────────
  static String backupUpload(int storeId) => 'backup/$storeId/upload';
  static String backupList(int storeId) => 'backup/$storeId/list';
  static String backupDownload(int storeId, int backupId) => 'backup/$storeId/download/$backupId';
  static String backupDelete(int storeId, int backupId) => 'backup/$storeId/$backupId';

  // ─── Timeouts ───────────────────────────────────────────────────────────
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetries = 2;

  // ─── License Policy ─────────────────────────────────────────────────────
  static const int licenseReverifyDays = 30;
  static const int licenseReadOnlyDays = 60;

  // ─── Sync Settings ──────────────────────────────────────────────────────
  static const int syncBatchSize = 100; // max items per batch push
  static const int maxBackupFiles = 5;  // max cloud backup tersimpan
}
