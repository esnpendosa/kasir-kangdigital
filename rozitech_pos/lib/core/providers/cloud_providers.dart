import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cloud_sync_service.dart';
import '../services/cloud_backup_service.dart';
import '../network/dio_client.dart';
import '../../features/license/data/datasources/license_local_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'database_provider.dart';

// ─── Shared Preferences ─────────────────────────────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

// ─── License Local Datasource ────────────────────────────────────────────────
final licenseLocalDatasourceProvider = Provider<LicenseLocalDatasource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final storage = ref.watch(secureStorageProvider);
  return LicenseLocalDatasource(database, storage);
});

// ─── Cloud Sync Service ──────────────────────────────────────────────────────
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final dio = ref.watch(dioProvider);
  final licenseLocal = ref.watch(licenseLocalDatasourceProvider);
  return CloudSyncService(dio: dio, licenseLocal: licenseLocal);
});

// ─── Cloud Backup Service ────────────────────────────────────────────────────
final cloudBackupServiceProvider = Provider<CloudBackupService>((ref) {
  final dio = ref.watch(dioProvider);
  final licenseLocal = ref.watch(licenseLocalDatasourceProvider);
  return CloudBackupService(dio: dio, licenseLocal: licenseLocal);
});

// ─── Stores List ─────────────────────────────────────────────────────────────
final storesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final syncService = ref.watch(cloudSyncServiceProvider);
  return syncService.getStores();
});

// ─── Active Store ID (persisted in SharedPreferences) ────────────────────────
final activeStoreIdProvider = StateProvider<int?>((ref) => null);

// ─── Backup List ─────────────────────────────────────────────────────────────
final backupListProvider = FutureProvider.family<List<BackupInfo>, int>((ref, storeId) async {
  final backupService = ref.watch(cloudBackupServiceProvider);
  return backupService.listBackups(storeId);
});

// ─── Sync State ──────────────────────────────────────────────────────────────
class SyncState {
  final bool isSyncing;
  final SyncResult? lastResult;
  final String? error;
  final DateTime? lastSyncedAt;

  const SyncState({
    this.isSyncing = false,
    this.lastResult,
    this.error,
    this.lastSyncedAt,
  });

  SyncState copyWith({
    bool? isSyncing,
    SyncResult? lastResult,
    String? error,
    DateTime? lastSyncedAt,
  }) =>
      SyncState(
        isSyncing: isSyncing ?? this.isSyncing,
        lastResult: lastResult ?? this.lastResult,
        error: error ?? this.error,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}

class SyncNotifier extends StateNotifier<SyncState> {
  final CloudSyncService _syncService;

  SyncNotifier(this._syncService) : super(const SyncState());

  Future<void> pushAll({
    required int storeId,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? customers,
    List<Map<String, dynamic>>? transactions,
    List<Map<String, dynamic>>? expenses,
    List<Map<String, dynamic>>? suppliers,
  }) async {
    state = state.copyWith(isSyncing: true, error: null);
    try {
      final result = await _syncService.pushBatch(
        storeId: storeId,
        categories: categories,
        products: products,
        customers: customers,
        transactions: transactions,
        expenses: expenses,
        suppliers: suppliers,
      );
      state = state.copyWith(
        isSyncing: false,
        lastResult: result,
        lastSyncedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  Future<PullResult?> pullAll(int storeId, {DateTime? since}) async {
    state = state.copyWith(isSyncing: true, error: null);
    try {
      final result = await _syncService.pullAll(storeId, since: since);
      state = state.copyWith(
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
      );
      return result;
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
      return null;
    }
  }
}

final syncNotifierProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref.watch(cloudSyncServiceProvider));
});

// ─── Backup Upload State ──────────────────────────────────────────────────────
class BackupUploadState {
  final bool isUploading;
  final double progress;
  final BackupUploadResult? lastResult;
  final String? error;

  const BackupUploadState({
    this.isUploading = false,
    this.progress = 0,
    this.lastResult,
    this.error,
  });

  BackupUploadState copyWith({
    bool? isUploading,
    double? progress,
    BackupUploadResult? lastResult,
    String? error,
  }) =>
      BackupUploadState(
        isUploading: isUploading ?? this.isUploading,
        progress: progress ?? this.progress,
        lastResult: lastResult ?? this.lastResult,
        error: error ?? this.error,
      );
}

class BackupNotifier extends StateNotifier<BackupUploadState> {
  final CloudBackupService _backupService;

  BackupNotifier(this._backupService) : super(const BackupUploadState());

  Future<void> upload({
    required int storeId,
    required String dbFilePath,
    String? appVersion,
    String? deviceId,
    String? notes,
  }) async {
    state = state.copyWith(isUploading: true, progress: 0, error: null);

    final result = await _backupService.uploadBackup(
      storeId: storeId,
      dbFilePath: dbFilePath,
      appVersion: appVersion,
      deviceId: deviceId,
      notes: notes,
      onProgress: (p) {
        state = state.copyWith(progress: p);
      },
    );

    state = state.copyWith(isUploading: false, progress: 1.0, lastResult: result);

    if (!result.success) {
      state = state.copyWith(error: result.error);
    }
  }
}

final backupNotifierProvider = StateNotifierProvider<BackupNotifier, BackupUploadState>((ref) {
  return BackupNotifier(ref.watch(cloudBackupServiceProvider));
});
