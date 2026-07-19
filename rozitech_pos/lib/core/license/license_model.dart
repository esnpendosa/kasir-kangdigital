/// Domain model for the license returned from the API.
class LicenseModel {
  final String licenseKey;
  final String jwtToken;
  final String status;
  final String? deviceId;
  final DateTime? activatedAt;
  final DateTime? expiresAt;

  const LicenseModel({
    required this.licenseKey,
    required this.jwtToken,
    required this.status,
    this.deviceId,
    this.activatedAt,
    this.expiresAt,
  });

  bool get isValid => status == 'active';

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      licenseKey: json['license_key'] as String? ?? '',
      jwtToken: json['token'] as String? ?? '',
      status: json['status'] as String? ?? 'inactive',
      deviceId: json['device_id'] as String?,
      activatedAt: json['activated_at'] != null
          ? DateTime.tryParse(json['activated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'license_key': licenseKey,
        'token': jwtToken,
        'status': status,
        'device_id': deviceId,
        'activated_at': activatedAt?.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
      };
}
