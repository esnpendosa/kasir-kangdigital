import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/license.dart';
import '../repositories/license_repository.dart';

class RefreshLicenseUseCase {
  const RefreshLicenseUseCase(this._repository);
  final LicenseRepository _repository;

  Future<Either<Failure, License>> call() =>
      _repository.refreshLicense();
}
