import 'package:equatable/equatable.dart';

/// Base class for all application failures.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// Failure from database operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure from network/API operations.
class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure from user input validation.
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Failure related to license operations.
class LicenseFailure extends Failure {
  const LicenseFailure(super.message);
}

/// Failure from printer operations.
class PrinterFailure extends Failure {
  const PrinterFailure(super.message);
}

/// Entity not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Missing device permission.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Cache miss or invalid cache.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Unexpected / unknown error.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
