import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/result.dart';
import 'license_api_service.dart';
import 'license_model.dart';

/// Status of the app license.
enum LicenseStatus {
  valid,
  expired,
  notFound,
  unknown,
}

/// Manager that orchestrates local license validation and online re-checks.
///
/// Startup flow:
///   1. Load JWT from secure storage.
///   2. Validate locally (expiry, device ID).
///   3. If last online check > 30 days ago → re-check online.
///   4. If no license found → [LicenseStatus.notFound].
class LicenseManager {
  LicenseManager(this._db, this._api)
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final AppDatabase _db;
  final LicenseApiService _api;
  final FlutterSecureStorage _storage;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Check local license. Returns current status.
  Future<LicenseStatus> checkLocalLicense() async {
    final token = await _storage.read(key: AppConfig.keyLicenseToken);
    if (token == null || token.isEmpty) return LicenseStatus.notFound;

    // Load from DB
    final rows = await _db.select(_db.licenses).get();
    if (rows.isEmpty) return LicenseStatus.notFound;

    final license = rows.last;
    if (license.status != 'active') return LicenseStatus.expired;

    // Check expiry date
    final expires = license.expiresAt;
    if (expires != null && expires.isBefore(DateTime.now())) {
      return LicenseStatus.expired;
    }

    // Check if online re-check is needed
    final lastCheck = license.lastCheckedAt;
    if (lastCheck == null ||
        DateTime.now().difference(lastCheck).inDays >=
            AppConfig.licenseCheckIntervalDays) {
      // Attempt background re-check (silently, don't block app)
      _reCheckOnline(token);
    }

    return LicenseStatus.valid;
  }

  /// Activate a new license key online and persist it.
  Future<Result<LicenseModel>> activate(String licenseKey) async {
    final result = await _api.activate(licenseKey);
    if (result.isSuccess) {
      final model = result.dataOrNull!;
      await _persistLicense(model);
    }
    return result;
  }

  /// Deactivate current license.
  Future<Result<bool>> deactivate() async {
    final token = await _storage.read(key: AppConfig.keyLicenseToken) ?? '';
    final result = await _api.deactivate(token);
    if (result.isSuccess) {
      await _storage.deleteAll();
      await (_db.delete(_db.licenses)).go();
    }
    return result;
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Future<void> _persistLicense(LicenseModel model) async {
    await _storage.write(key: AppConfig.keyLicenseToken, value: model.jwtToken);
    await _storage.write(key: AppConfig.keyLicenseKey, value: model.licenseKey);

    await _db.into(_db.licenses).insertOnConflictUpdate(
          LicensesCompanion.insert(
            licenseKey: model.licenseKey,
            jwtToken: Value(model.jwtToken),
            status: Value(model.status),
            deviceId: Value(model.deviceId),
            activatedAt: Value(model.activatedAt),
            expiresAt: Value(model.expiresAt),
            lastCheckedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> _reCheckOnline(String token) async {
    final result = await _api.check(token);
    if (result.isSuccess) {
      final model = result.dataOrNull!;
      await _persistLicense(model);
    } else {
      // If check fails due to network, keep existing license valid
      // Only mark expired if server explicitly says so
      if (result is Failure<LicenseModel> && result.message.contains('invalid')) {
        await _db.update(_db.licenses)
            .write(const LicensesCompanion(status: Value('expired')));
      }
    }
  }
}

final licenseManagerProvider = Provider<LicenseManager>((ref) {
  return LicenseManager(
    ref.watch(databaseProvider),
    ref.watch(licenseApiServiceProvider),
  );
});

/// Async provider to check license status at app startup.
final licenseStatusProvider = FutureProvider<LicenseStatus>((ref) async {
  final manager = ref.watch(licenseManagerProvider);
  return manager.checkLocalLicense();
});
