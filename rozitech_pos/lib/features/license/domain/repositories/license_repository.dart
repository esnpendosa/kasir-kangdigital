import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/license.dart';

/// Abstract repository interface for license operations.
abstract class LicenseRepository {
  /// Retrieve the locally stored license.
  Future<Either<Failure, License>> getLocalLicense();

  /// Activate a license key via the remote API and persist locally.
  Future<Either<Failure, License>> activateLicense(String licenseKey);

  /// Refresh the license via the remote API.
  Future<Either<Failure, License>> refreshLicense();

  /// Deactivate the current license via the remote API.
  Future<Either<Failure, void>> deactivateLicense();

  /// Persist a license record locally (DB + secure storage).
  Future<void> storeLicense(License license);
}
