/// DTO for license API response.
class LicenseResponseDto {
  const LicenseResponseDto({
    required this.success,
    this.jwtToken,
    this.licenseKey,
    this.licenseType,
    this.deviceId,
    this.activatedAt,
    this.expiresAt,
    this.message,
    this.status,
  });

  final bool success;
  final String? jwtToken;
  final String? licenseKey;
  final String? licenseType;
  final String? deviceId;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final String? message;
  final int? status; // 1=active, 2=read_only

  factory LicenseResponseDto.fromJson(Map<String, dynamic> json) {
    return LicenseResponseDto(
      success: json['success'] as bool? ?? false,
      jwtToken: json['jwt_token'] as String?,
      licenseKey: json['license_key'] as String?,
      licenseType: json['license_type'] as String?,
      deviceId: json['device_id'] as String?,
      activatedAt: json['activated_at'] != null
          ? DateTime.tryParse(json['activated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      message: json['message'] as String?,
      status: json['status'] as int?,
    );
  }
}

/// DTO for version check API response.
class VersionCheckResponseDto {
  const VersionCheckResponseDto({
    required this.currentVersion,
    required this.latestVersion,
    required this.updateAvailable,
    this.releaseNotes,
    this.downloadUrl,
  });

  final String currentVersion;
  final String latestVersion;
  final bool updateAvailable;
  final String? releaseNotes;
  final String? downloadUrl;

  factory VersionCheckResponseDto.fromJson(Map<String, dynamic> json) {
    return VersionCheckResponseDto(
      currentVersion: json['current_version'] as String? ?? '',
      latestVersion: json['latest_version'] as String? ?? '',
      updateAvailable: json['update_available'] as bool? ?? false,
      releaseNotes: json['release_notes'] as String?,
      downloadUrl: json['download_url'] as String?,
    );
  }
}
