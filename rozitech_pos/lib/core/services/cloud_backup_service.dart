import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../../../features/license/data/datasources/license_local_datasource.dart';

/// CloudBackupService — Upload dan download backup database ke/dari server
///
/// Mendukung shared hosting hPanel:
/// - Tidak butuh FTP langsung, cukup via HTTP multipart upload
/// - File disimpan di server storage hingga 5 backup terbaru
/// - Integritas file dijamin dengan MD5 hash
class CloudBackupService {
  final Dio _dio;
  final LicenseLocalDatasource _licenseLocal;

  CloudBackupService({required Dio dio, required LicenseLocalDatasource licenseLocal})
      : _dio = dio,
        _licenseLocal = licenseLocal;

  Future<String?> _getAuthToken() async {
    try {
      return await _licenseLocal.getJwtToken();
    } catch (_) {
      return null;
    }
  }

  // ─── UPLOAD BACKUP ───────────────────────────────────────────────────────

  /// Upload file backup SQLite ke server cloud
  ///
  /// [storeId] — ID toko di server (dari stores API)
  /// [dbFilePath] — Path lengkap file .db di device
  /// [onProgress] — Callback progress (0.0 - 1.0)
  Future<BackupUploadResult> uploadBackup({
    required int storeId,
    required String dbFilePath,
    String? appVersion,
    String? deviceId,
    String? notes,
    Function(double progress)? onProgress,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      return BackupUploadResult.error('Token lisensi tidak ditemukan.');
    }

    final file = File(dbFilePath);
    if (!await file.exists()) {
      return BackupUploadResult.error('File backup tidak ditemukan: $dbFilePath');
    }

    try {
      final formData = FormData.fromMap({
        'backup_file': await MultipartFile.fromFile(
          dbFilePath,
          filename: 'backup_${DateTime.now().millisecondsSinceEpoch}.db',
        ),
        if (appVersion != null) 'app_version': appVersion,
        if (deviceId != null) 'device_id': deviceId,
        if (notes != null) 'notes': notes,
      });

      final response = await _dio.post(
        '${AppConfig.baseUrl}backup/$storeId/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      if (response.data['success'] == true) {
        return BackupUploadResult.success(
          backupId: response.data['data']['id'],
          filename: response.data['data']['filename'],
          fileSize: response.data['data']['file_size'],
          fileHash: response.data['data']['file_hash'],
        );
      }

      return BackupUploadResult.error(response.data['message'] ?? 'Upload gagal.');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return BackupUploadResult.error('Koneksi timeout. Coba lagi.');
      }
      return BackupUploadResult.error(
          e.response?.data?['message'] ?? 'Gagal menghubungi server.');
    } catch (e) {
      return BackupUploadResult.error('Error: $e');
    }
  }

  // ─── LIST BACKUPS ────────────────────────────────────────────────────────

  /// Ambil daftar backup yang tersedia di server
  Future<List<BackupInfo>> listBackups(int storeId) async {
    final token = await _getAuthToken();
    if (token == null) return [];

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}backup/$storeId/list',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((item) => BackupInfo.fromJson(item))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── DOWNLOAD BACKUP ─────────────────────────────────────────────────────

  /// Download backup dari server ke device
  ///
  /// [savePath] — Path tempat file akan disimpan di device
  Future<BackupDownloadResult> downloadBackup({
    required int storeId,
    required int backupId,
    required String savePath,
    Function(double progress)? onProgress,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      return BackupDownloadResult.error('Token lisensi tidak ditemukan.');
    }

    try {
      await _dio.download(
        '${AppConfig.baseUrl}backup/$storeId/download/$backupId',
        savePath,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(minutes: 5),
        ),
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      final file = File(savePath);
      if (await file.exists()) {
        return BackupDownloadResult.success(filePath: savePath);
      }
      return BackupDownloadResult.error('File tidak tersimpan.');
    } on DioException catch (e) {
      return BackupDownloadResult.error(
          e.response?.data?['message'] ?? 'Download gagal.');
    } catch (e) {
      return BackupDownloadResult.error('Error: $e');
    }
  }

  // ─── DELETE BACKUP ────────────────────────────────────────────────────────

  /// Hapus backup dari server
  Future<bool> deleteBackup(int storeId, int backupId) async {
    final token = await _getAuthToken();
    if (token == null) return false;

    try {
      final response = await _dio.delete(
        '${AppConfig.baseUrl}backup/$storeId/$backupId',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      return response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}

// ─── Data Classes ──────────────────────────────────────────────────────────

class BackupUploadResult {
  final bool success;
  final int? backupId;
  final String? filename;
  final String? fileSize;
  final String? fileHash;
  final String? error;

  const BackupUploadResult._({
    required this.success,
    this.backupId,
    this.filename,
    this.fileSize,
    this.fileHash,
    this.error,
  });

  factory BackupUploadResult.success({
    required int backupId,
    required String filename,
    required String fileSize,
    required String fileHash,
  }) =>
      BackupUploadResult._(
        success: true,
        backupId: backupId,
        filename: filename,
        fileSize: fileSize,
        fileHash: fileHash,
      );

  factory BackupUploadResult.error(String message) =>
      BackupUploadResult._(success: false, error: message);
}

class BackupDownloadResult {
  final bool success;
  final String? filePath;
  final String? error;

  const BackupDownloadResult._({required this.success, this.filePath, this.error});

  factory BackupDownloadResult.success({required String filePath}) =>
      BackupDownloadResult._(success: true, filePath: filePath);

  factory BackupDownloadResult.error(String message) =>
      BackupDownloadResult._(success: false, error: message);
}

class BackupInfo {
  final int id;
  final String filename;
  final String originalFilename;
  final int fileSize;
  final String fileSizeFormatted;
  final String? fileHash;
  final String? appVersion;
  final String? deviceId;
  final String? notes;
  final DateTime createdAt;

  const BackupInfo({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.fileSize,
    required this.fileSizeFormatted,
    this.fileHash,
    this.appVersion,
    this.deviceId,
    this.notes,
    required this.createdAt,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) => BackupInfo(
        id: json['id'] as int,
        filename: json['filename'] as String,
        originalFilename: json['original_filename'] as String,
        fileSize: json['file_size'] as int,
        fileSizeFormatted: json['file_size_formatted'] as String,
        fileHash: json['file_hash'] as String?,
        appVersion: json['app_version'] as String?,
        deviceId: json['device_id'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
