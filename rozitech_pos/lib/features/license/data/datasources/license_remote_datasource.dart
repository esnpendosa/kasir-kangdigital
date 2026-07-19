import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/license_request_dto.dart';
import '../models/license_response_dto.dart';

/// Remote data source: calls the Kang Digital API for license operations.
class LicenseRemoteDatasource {
  const LicenseRemoteDatasource(this._dio);
  final Dio _dio;

  static const _activate = 'license/activate';
  static const _deactivate = 'license/deactivate';
  static const _refresh = 'license/refresh';

  Future<LicenseResponseDto> activate(LicenseActivateRequest request) async {
    try {
      final response = await _dio.post(_activate, data: request.toJson());
      return LicenseResponseDto.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Gagal menghubungi server',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<LicenseResponseDto> deactivate(String jwtToken) async {
    try {
      final response = await _dio.post(
        _deactivate,
        data: LicenseTokenRequest(token: jwtToken).toJson(),
      );
      return LicenseResponseDto.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Gagal menghubungi server',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<LicenseResponseDto> refresh(String jwtToken) async {
    try {
      final response = await _dio.post(
        _refresh,
        data: LicenseTokenRequest(token: jwtToken).toJson(),
      );
      return LicenseResponseDto.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Gagal menghubungi server',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
