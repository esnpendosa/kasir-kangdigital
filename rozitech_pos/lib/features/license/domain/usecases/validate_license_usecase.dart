import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/license.dart';
import '../repositories/license_repository.dart';

class ValidateLicenseUseCase {
  const ValidateLicenseUseCase(this._repository);
  final LicenseRepository _repository;

  /// Returns the license if locally valid, otherwise returns a [Failure].
  Future<Either<Failure, License>> call() async {
    final result = await _repository.getLocalLicense();
    return result.flatMap((license) {
      if (license.isExpired) {
        return left(const LicenseFailure('Lisensi telah kedaluwarsa'));
      }
      if (!license.isActive && !license.isReadOnly) {
        return left(const LicenseFailure('Lisensi tidak aktif'));
      }
      return right(license);
    });
  }
}
