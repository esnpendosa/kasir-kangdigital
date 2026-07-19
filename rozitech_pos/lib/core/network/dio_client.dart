import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';

/// Creates a pre-configured [Dio] instance with base URL and interceptors.
Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Log requests in debug mode
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
      compact: true,
    ),
  );

  // Auth token interceptor — attach JWT from storage if available
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Token is injected by the license service when needed
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );

  return dio;
}

/// Riverpod provider for the shared [Dio] instance.
final dioProvider = Provider<Dio>((ref) => _createDio());
