import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/license.dart';

const _keyJwt = 'license_jwt';
const _keyLicenseKey = 'license_key';

/// Local data source: reads/writes license from Drift DB + JWT from secure storage.
class LicenseLocalDatasource {
  const LicenseLocalDatasource(this._db, this._storage);

  final db.AppDatabase _db;
  final FlutterSecureStorage _storage;

  /// Returns the locally stored license or throws [LicenseException] if none.
  Future<License> getLicense() async {
    final rows = await _db.select(_db.licenses).get();
    if (rows.isEmpty) throw const LicenseException('Tidak ada lisensi lokal');
    final row = rows.last;
    return _rowToEntity(row);
  }

  /// Persists a license entity to DB and JWT to secure storage.
  Future<void> saveLicense(License license) async {
    await _storage.write(key: _keyJwt, value: license.jwtToken);
    await _storage.write(key: _keyLicenseKey, value: license.licenseKey);

    await _db.into(_db.licenses).insertOnConflictUpdate(
          db.LicensesCompanion(
            id: license.id == 0 ? const Value.absent() : Value(license.id),
            licenseKey: Value(license.licenseKey),
            jwtToken: Value(license.jwtToken),
            status: Value(license.status.toString()),
            deviceId: Value(license.deviceId),
            activatedAt: Value(license.activatedAt),
            expiresAt: Value(license.expiresAt),
            lastCheckedAt: Value(license.lastVerifiedAt),
          ),
        );
  }

  /// Deletes all license data locally.
  Future<void> deleteLicense() async {
    await _storage.deleteAll();
    await _db.delete(_db.licenses).go();
  }

  /// Returns the stored JWT token, or null if none.
  Future<String?> getJwtToken() => _storage.read(key: _keyJwt);

  /// Updates only the lastCheckedAt timestamp.
  Future<void> updateLastVerified(DateTime when) async {
    await (_db.update(_db.licenses))
        .write(db.LicensesCompanion(lastCheckedAt: Value(when)));
  }

  License _rowToEntity(db.License row) {
    return License(
      id: row.id,
      licenseKey: row.licenseKey,
      jwtToken: row.jwtToken ?? '',
      licenseType: 'standard',
      deviceId: row.deviceId ?? '',
      activatedAt: row.activatedAt ?? DateTime.now(),
      lastVerifiedAt: row.lastCheckedAt ?? DateTime.now(),
      status: int.tryParse(row.status) ?? 0,
      expiresAt: row.expiresAt,
    );
  }
}
