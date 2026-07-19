import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../network/dio_client.dart';
import '../utils/result.dart';
import 'license_model.dart';

/// Handles all license-related HTTP calls to Kang Digital API.
/// No backend logic is created here — only Flutter API calls.
class LicenseApiService {
  LicenseApiService(this._dio);
  final Dio _dio;

  Future<String> _getDeviceId() async {
    final di = DeviceInfoPlugin();
    try {
      final android = await di.androidInfo;
      return android.id;
    } catch (_) {
      final pkg = await PackageInfo.fromPlatform();
      return '${pkg.packageName}-desktop';
    }
  }

  /// POST /license/activate
  /// Sends license key + device ID, receives JWT token.
  Future<Result<LicenseModel>> activate(String licenseKey) async {
    try {
      final deviceId = await _getDeviceId();
      final pkg = await PackageInfo.fromPlatform();

      final response = await _dio.post(
        'license/activate',
        data: {
          'license_key': licenseKey,
          'device_id': deviceId,
          'app_version': pkg.version,
          'platform': 'android',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final model = LicenseModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        return Success(model);
      }
      return Failure(
        response.data['message'] as String? ?? 'Aktivasi gagal',
      );
    } on DioException catch (e) {
      return Failure(_parseDioError(e), e);
    } catch (e) {
      return Failure('Terjadi kesalahan tidak terduga', e);
    }
  }

  /// POST /license/check
  /// Validates the current JWT token is still active.
  Future<Result<LicenseModel>> check(String jwtToken) async {
    try {
      final deviceId = await _getDeviceId();
      final response = await _dio.post(
        'license/check',
        data: {
          'token': jwtToken,
          'device_id': deviceId,
        },
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final model = LicenseModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        return Success(model);
      }
      return Failure(
        response.data['message'] as String? ?? 'Lisensi tidak valid',
      );
    } on DioException catch (e) {
      return Failure(_parseDioError(e), e);
    } catch (e) {
      return Failure('Terjadi kesalahan tidak terduga', e);
    }
  }

  /// POST /license/deactivate
  Future<Result<bool>> deactivate(String jwtToken) async {
    try {
      final deviceId = await _getDeviceId();
      final response = await _dio.post(
        'license/deactivate',
        data: {'device_id': deviceId},
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );
      if (response.statusCode == 200) return const Success(true);
      return Failure(response.data['message'] as String? ?? 'Gagal menonaktifkan');
    } on DioException catch (e) {
      return Failure(_parseDioError(e), e);
    }
  }

  /// POST /license/refresh — renew JWT token.
  Future<Result<LicenseModel>> refresh(String jwtToken) async {
    try {
      final response = await _dio.post(
        'license/refresh',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Success(
          LicenseModel.fromJson(response.data['data'] as Map<String, dynamic>),
        );
      }
      return Failure(response.data['message'] as String? ?? 'Gagal refresh');
    } on DioException catch (e) {
      return Failure(_parseDioError(e), e);
    }
  }

  /// GET /version — check for app updates.
  Future<Result<Map<String, dynamic>>> getLatestVersion() async {
    try {
      final response = await _dio.get('version');
      if (response.statusCode == 200) {
        return Success(response.data as Map<String, dynamic>);
      }
      return const Failure('Gagal mengambil versi terbaru');
    } on DioException catch (e) {
      return Failure(_parseDioError(e), e);
    }
  }

  String _parseDioError(DioException e) {
    if (e.response?.data is Map) {
      return (e.response!.data as Map)['message'] as String? ??
          'Error: ${e.response?.statusCode}';
    }
    final detail = e.message != null ? '\nDetail: ${e.message}' : '';
    final errDetail = e.error != null ? '\nError: ${e.error}' : '';
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'Koneksi timeout. Periksa jaringan.',
      DioExceptionType.receiveTimeout => 'Server tidak merespons.',
      DioExceptionType.connectionError =>
        'Tidak dapat terhubung ke server. Mode offline aktif.$detail$errDetail',
      _ => 'Terjadi kesalahan jaringan.$detail$errDetail',
    };
  }
}

final licenseApiServiceProvider = Provider<LicenseApiService>((ref) {
  return LicenseApiService(ref.watch(dioProvider));
});
