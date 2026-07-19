import 'package:equatable/equatable.dart';

/// License status tiers based on days since last verification.
enum LicenseStatusTier { normal, warning, readOnly, inactive, expired }

/// Domain entity for a license record.
class License extends Equatable {
  const License({
    required this.id,
    required this.licenseKey,
    required this.jwtToken,
    required this.licenseType,
    required this.deviceId,
    required this.activatedAt,
    required this.lastVerifiedAt,
    required this.status,
    this.expiresAt,
  });

  final int id;
  final String licenseKey;
  final String jwtToken;
  final String licenseType; // 'trial' | 'standard' | 'premium'
  final String deviceId;
  final DateTime activatedAt;
  final DateTime lastVerifiedAt;
  final int status; // 0=inactive, 1=active, 2=read_only
  final DateTime? expiresAt;

  bool get isActive => status == 1;
  bool get isReadOnly => status == 2;
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  int get daysSinceVerification =>
      DateTime.now().difference(lastVerifiedAt).inDays;

  /// Returns the tier based on how long since last verification.
  LicenseStatusTier get statusTier {
    if (status == 0) return LicenseStatusTier.inactive;
    if (isExpired) return LicenseStatusTier.expired;
    final days = daysSinceVerification;
    if (days < 30) return LicenseStatusTier.normal;
    if (days < 60) return LicenseStatusTier.warning;
    return LicenseStatusTier.readOnly;
  }

  @override
  List<Object?> get props => [
        id,
        licenseKey,
        jwtToken,
        licenseType,
        deviceId,
        activatedAt,
        lastVerifiedAt,
        status,
        expiresAt,
      ];
}
