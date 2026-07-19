import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/license.dart';
import '../../domain/repositories/license_repository.dart';
import '../datasources/license_local_datasource.dart';
import '../datasources/license_remote_datasource.dart';
import '../models/license_request_dto.dart';

class LicenseRepositoryImpl implements LicenseRepository {
  const LicenseRepositoryImpl({
    required this.local,
    required this.remote,
  });

  final LicenseLocalDatasource local;
  final LicenseRemoteDatasource remote;

  @override
  Future<Either<Failure, License>> getLocalLicense() async {
    try {
      final license = await local.getLicense();
      return right(license);
    } on LicenseException catch (e) {
      return left(LicenseFailure(e.message));
    } catch (e) {
      return left(DatabaseFailure('Gagal membaca lisensi: $e'));
    }
  }

  @override
  Future<Either<Failure, License>> activateLicense(String licenseKey) async {
    try {
      final deviceId = const Uuid().v4();
      final dto = await remote.activate(
        LicenseActivateRequest(
          licenseKey: licenseKey,
          deviceId: deviceId,
          appVersion: AppConstants.appVersion,
        ),
      );

      if (!dto.success) {
        return left(LicenseFailure(dto.message ?? 'Aktivasi gagal'));
      }

      final license = License(
        id: 0,
        licenseKey: dto.licenseKey ?? licenseKey,
        jwtToken: dto.jwtToken ?? '',
        licenseType: dto.licenseType ?? 'standard',
        deviceId: dto.deviceId ?? deviceId,
        activatedAt: dto.activatedAt ?? DateTime.now(),
        lastVerifiedAt: DateTime.now(),
        status: dto.status ?? 1,
        expiresAt: dto.expiresAt,
      );

      await local.saveLicense(license);
      return right(license);
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return left(UnexpectedFailure('Aktivasi gagal: $e'));
    }
  }

  @override
  Future<Either<Failure, License>> refreshLicense() async {
    try {
      final jwt = await local.getJwtToken();
      if (jwt == null) {
        return left(const LicenseFailure('Tidak ada token lisensi'));
      }
      final dto = await remote.refresh(jwt);
      if (!dto.success) {
        return left(LicenseFailure(dto.message ?? 'Refresh gagal'));
      }
      final currentResult = await getLocalLicense();
      return currentResult.fold(
        (f) => left(f),
        (current) async {
          final updated = License(
            id: current.id,
            licenseKey: current.licenseKey,
            jwtToken: dto.jwtToken ?? current.jwtToken,
            licenseType: dto.licenseType ?? current.licenseType,
            deviceId: current.deviceId,
            activatedAt: current.activatedAt,
            lastVerifiedAt: DateTime.now(),
            status: dto.status ?? current.status,
            expiresAt: dto.expiresAt ?? current.expiresAt,
          );
          await local.saveLicense(updated);
          return right(updated);
        },
      );
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return left(UnexpectedFailure('Refresh gagal: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateLicense() async {
    try {
      final jwt = await local.getJwtToken();
      if (jwt != null) await remote.deactivate(jwt);
      await local.deleteLicense();
      return right(null);
    } on NetworkException catch (_) {
      // Still delete locally even if network fails
      await local.deleteLicense();
      return right(null);
    } catch (e) {
      return left(UnexpectedFailure('Deaktivasi gagal: $e'));
    }
  }

  @override
  Future<void> storeLicense(License license) => local.saveLicense(license);
}
