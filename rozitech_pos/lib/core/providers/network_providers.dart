import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_info.dart';
import '../constants/api_constants.dart';

/// Singleton [Dio] client provider — pre-configured with base URL and timeouts.
final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  return dio;
});

/// Internal connectivity instance.
final _connectivityProvider = Provider<Connectivity>((_) => Connectivity());

/// Singleton [NetworkInfo] provider.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(_connectivityProvider));
});
