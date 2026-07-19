/// Database-level exception.
class DatabaseException implements Exception {
  final String message;
  final Object? cause;
  const DatabaseException(this.message, {this.cause});

  @override
  String toString() =>
      'DatabaseException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Network/HTTP exception.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

/// Input validation exception.
class ValidationException implements Exception {
  final String message;
  final Map<String, String> fieldErrors;
  const ValidationException(this.message, {this.fieldErrors = const {}});

  @override
  String toString() => 'ValidationException: $message';
}

/// License-related exception.
class LicenseException implements Exception {
  final String message;
  const LicenseException(this.message);

  @override
  String toString() => 'LicenseException: $message';
}

/// Thermal printer exception.
class PrinterException implements Exception {
  final String message;
  const PrinterException(this.message);

  @override
  String toString() => 'PrinterException: $message';
}

/// Cache read/write exception.
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// File system / storage exception.
class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
