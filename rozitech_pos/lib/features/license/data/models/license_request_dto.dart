import 'dart:io';

/// DTO for license activation request body.
class LicenseActivateRequest {
  const LicenseActivateRequest({
    required this.licenseKey,
    required this.deviceId,
    required this.appVersion,
  });

  final String licenseKey;
  final String deviceId;
  final String appVersion;

  Map<String, dynamic> toJson() => {
        'license_key': licenseKey,
        'device_id': deviceId,
        'app_version': appVersion,
        'platform': Platform.operatingSystem,
      };
}

/// DTO for license deactivate/refresh request.
class LicenseTokenRequest {
  const LicenseTokenRequest({required this.token});
  final String token;

  Map<String, dynamic> toJson() => {'token': token};
}
