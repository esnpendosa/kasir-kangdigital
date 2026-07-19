import 'package:dio/dio.dart';
import '../../domain/entities/payment_method_config.dart';

/// Generic Dynamic QRIS service.
/// Supports Qopay Merchant and Shopee Merchant (and any NMQR-based provider).
class QrisDynamicService {
  QrisDynamicService({required this.config, required Dio dio})
      : _dio = dio;

  final PaymentGatewayConfig config;
  final Dio _dio;

  // ─── Qopay endpoints ──────────────────────────────────────────────────────
  static const _qopayBase = 'https://api.qopay.id/v1';

  // ─── ShopeePay endpoints ─────────────────────────────────────────────────
  static const _shopeeBase = 'https://open-api.airpay.co.id/v2';

  /// Generate dynamic QRIS for Qopay.
  Future<PaymentGatewayResult> generateQopayQris({
    required String orderId,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        '$_qopayBase/create-qris',
        options: Options(headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        }),
        data: {
          'merchant_id': config.merchantId,
          'order_id': orderId,
          'amount': amount.toInt(),
          'currency': 'IDR',
        },
      );

      final data = response.data as Map<String, dynamic>;
      return PaymentGatewayResult(
        success: true,
        transactionId: orderId,
        paymentType: PaymentType.qopay,
        qrString: data['qr_string'] as String?,
        qrImageUrl: data['qr_url'] as String?,
        rawResponse: data,
      );
    } on DioException catch (e) {
      return PaymentGatewayResult(
        success: false,
        transactionId: orderId,
        paymentType: PaymentType.qopay,
        errorMessage: e.message ?? 'Qopay error',
      );
    }
  }

  /// Generate dynamic QRIS for ShopeePay Merchant.
  Future<PaymentGatewayResult> generateShopeeQris({
    required String orderId,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        '$_shopeeBase/payment/qr/create',
        options: Options(headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        }),
        data: {
          'merchant_ext_id': config.merchantId,
          'request_id': orderId,
          'amount': amount.toInt(),
          'currency': 'IDR',
          'timeout': 300,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return PaymentGatewayResult(
        success: true,
        transactionId: orderId,
        paymentType: PaymentType.shopee,
        qrString: data['qr_string'] as String?,
        qrImageUrl: data['qr_code_url'] as String?,
        rawResponse: data,
      );
    } on DioException catch (e) {
      return PaymentGatewayResult(
        success: false,
        transactionId: orderId,
        paymentType: PaymentType.shopee,
        errorMessage: e.message ?? 'ShopeePay error',
      );
    }
  }

  /// Poll payment status (polling every 3 seconds, max 5 minutes).
  Stream<String> pollStatus({
    required String orderId,
    required PaymentType type,
    Duration interval = const Duration(seconds: 3),
    int maxAttempts = 100,
  }) async* {
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(interval);
      final status = await _checkStatus(orderId, type);
      yield status;
      if (status == 'settlement' ||
          status == 'capture' ||
          status == 'paid' ||
          status == 'success' ||
          status == 'expire' ||
          status == 'cancel' ||
          status == 'deny') {
        break;
      }
    }
  }

  Future<String> _checkStatus(String orderId, PaymentType type) async {
    try {
      String url;
      Map<String, dynamic> headers;

      if (type == PaymentType.qopay) {
        url = '$_qopayBase/status/$orderId';
        headers = {'Authorization': 'Bearer ${config.apiKey}'};
      } else {
        url = '$_shopeeBase/payment/qr/status/$orderId';
        headers = {'Authorization': 'Bearer ${config.apiKey}'};
      }

      final response = await _dio.get(url,
          options: Options(headers: headers));
      final data = response.data as Map<String, dynamic>;
      return data['status'] as String? ??
          data['transaction_status'] as String? ??
          'pending';
    } catch (_) {
      return 'pending';
    }
  }
}
