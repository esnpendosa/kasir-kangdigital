import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/license.dart';
import '../repositories/license_repository.dart';

class ActivateLicenseUseCase {
  const ActivateLicenseUseCase(this._repository);
  final LicenseRepository _repository;

  Future<Either<Failure, License>> call(String licenseKey) {
    if (licenseKey.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('Kunci lisensi tidak boleh kosong')),
      );
    }
    return _repository.activateLicense(licenseKey.trim());
  }
}
