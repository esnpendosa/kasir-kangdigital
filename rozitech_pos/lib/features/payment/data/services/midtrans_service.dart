import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/payment_method_config.dart';

/// Midtrans Payment Gateway integration.
/// Supports SNAP API for generating payment tokens and checking status.
class MidtransService {
  MidtransService({required this.config, required Dio dio}) : _dio = dio;

  final PaymentGatewayConfig config;
  final Dio _dio;

  static const _snapSandboxUrl =
      'https://app.sandbox.midtrans.com/snap/v1';
  static const _snapProductionUrl = 'https://app.midtrans.com/snap/v1';
  static const _coreApiSandbox =
      'https://api.sandbox.midtrans.com/v2';
  static const _coreApiProduction = 'https://api.midtrans.com/v2';

  String get _snapBaseUrl =>
      config.isProduction ? _snapProductionUrl : _snapSandboxUrl;

  String get _coreBaseUrl =>
      config.isProduction ? _coreApiProduction : _coreApiSandbox;

  /// Create Midtrans SNAP transaction and get payment token.
  Future<PaymentGatewayResult> createTransaction({
    required String orderId,
    required double amount,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    try {
      final authKey = base64Encode(utf8.encode('${config.serverKey}:'));

      final response = await _dio.post(
        '$_snapBaseUrl/transactions',
        options: Options(headers: {
          'Authorization': 'Basic $authKey',
          'Content-Type': 'application/json',
        }),
        data: {
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': amount.toInt(),
          },
          'customer_details': {
            'first_name': customerName,
            if (customerEmail != null) 'email': customerEmail,
            if (customerPhone != null) 'phone': customerPhone,
          },
          'enabled_payments': [
            'credit_card',
            'gopay',
            'shopeepay',
            'other_qris',
            'bca_va',
            'bni_va',
            'bri_va',
            'mandiri_clickpay',
          ],
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return PaymentGatewayResult(
          success: true,
          transactionId: orderId,
          paymentType: PaymentType.midtrans,
          redirectUrl: data['redirect_url'] as String?,
          rawResponse: data,
        );
      }
      return PaymentGatewayResult(
        success: false,
        transactionId: orderId,
        paymentType: PaymentType.midtrans,
        errorMessage: 'HTTP ${response.statusCode}',
      );
    } on DioException catch (e) {
      return PaymentGatewayResult(
        success: false,
        transactionId: orderId,
        paymentType: PaymentType.midtrans,
        errorMessage: e.message ?? 'Network error',
      );
    }
  }

  /// Check transaction status.
  Future<String> checkStatus(String orderId) async {
    try {
      final authKey = base64Encode(utf8.encode('${config.serverKey}:'));
      final response = await _dio.get(
        '$_coreBaseUrl/$orderId/status',
        options: Options(
            headers: {'Authorization': 'Basic $authKey'}),
      );
      final data = response.data as Map<String, dynamic>;
      return data['transaction_status'] as String? ?? 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  /// Generate QRIS code specifically.
  Future<PaymentGatewayResult> createQrisTransaction({
    required String orderId,
    required double amount,
  }) async {
    try {
      final authKey = base64Encode(utf8.encode('${config.serverKey}:'));
      final response = await _dio.post(
        '$_coreBaseUrl/charge',
        options: Options(headers: {
          'Authorization': 'Basic $authKey',
          'Content-Type': 'application/json',
        }),
        data: {
          'payment_type': 'qris',
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': amount.toInt(),
          },
          'qris': {'acquirer': 'gopay'},
        },
      );

      final data = response.data as Map<String, dynamic>;
      final actions = data['actions'] as List? ?? [];
      String? qrUrl;
      String? qrStr;
      for (final a in actions) {
        final action = a as Map<String, dynamic>;
        if (action['name'] == 'generate-qr-code') {
          qrUrl = action['url'] as String?;
        }
      }
      qrStr = data['qr_string'] as String?;

      return PaymentGatewayResult(
        success: true,
        transactionId: orderId,
        paymentType: PaymentType.midtrans,
        qrImageUrl: qrUrl,
        qrString: qrStr,
        rawResponse: data,
      );
    } on DioException catch (e) {
      return PaymentGatewayResult(
        success: false,
        transactionId: orderId,
        paymentType: PaymentType.midtrans,
        errorMessage: e.message,
      );
    }
  }
}
