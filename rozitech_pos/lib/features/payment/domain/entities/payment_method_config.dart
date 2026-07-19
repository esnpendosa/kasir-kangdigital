/// Supported payment method types.
enum PaymentType {
  cash,
  bankTransfer,
  qrisDynamic,
  midtrans,
  qopay,
  shopee,
}

extension PaymentTypeX on PaymentType {
  String get label {
    switch (this) {
      case PaymentType.cash:
        return 'Tunai';
      case PaymentType.bankTransfer:
        return 'Transfer Bank';
      case PaymentType.qrisDynamic:
        return 'QRIS Dinamis';
      case PaymentType.midtrans:
        return 'Midtrans';
      case PaymentType.qopay:
        return 'QRIS Qopay';
      case PaymentType.shopee:
        return 'ShopeePay';
    }
  }

  String get icon {
    switch (this) {
      case PaymentType.cash:
        return '💵';
      case PaymentType.bankTransfer:
        return '🏦';
      case PaymentType.qrisDynamic:
        return '🔲';
      case PaymentType.midtrans:
        return '💳';
      case PaymentType.qopay:
        return '📱';
      case PaymentType.shopee:
        return '🛍️';
    }
  }

  bool get isOnline =>
      this == PaymentType.midtrans ||
      this == PaymentType.qrisDynamic ||
      this == PaymentType.qopay ||
      this == PaymentType.shopee;

  bool get requiresCashInput => this == PaymentType.cash;

  /// The value stored in DB (backward compatible).
  String get dbValue {
    switch (this) {
      case PaymentType.cash:
        return 'cash';
      case PaymentType.bankTransfer:
        return 'transfer';
      case PaymentType.qrisDynamic:
        return 'qris';
      case PaymentType.midtrans:
        return 'midtrans';
      case PaymentType.qopay:
        return 'qopay';
      case PaymentType.shopee:
        return 'shopee';
    }
  }

  static PaymentType fromDbValue(String v) {
    switch (v) {
      case 'cash':
        return PaymentType.cash;
      case 'transfer':
        return PaymentType.bankTransfer;
      case 'qris':
        return PaymentType.qrisDynamic;
      case 'midtrans':
        return PaymentType.midtrans;
      case 'qopay':
        return PaymentType.qopay;
      case 'shopee':
        return PaymentType.shopee;
      default:
        return PaymentType.cash;
    }
  }
}

/// Gateway configuration stored in settings.
class PaymentGatewayConfig {
  const PaymentGatewayConfig({
    required this.type,
    this.isEnabled = false,
    this.serverKey,
    this.clientKey,
    this.merchantId,
    this.apiKey,
    this.isProduction = false,
  });

  final PaymentType type;
  final bool isEnabled;
  final String? serverKey;   // Midtrans server key
  final String? clientKey;   // Midtrans client key / Qopay API key
  final String? merchantId;  // Merchant ID for QRIS
  final String? apiKey;      // Generic API key
  final bool isProduction;

  PaymentGatewayConfig copyWith({
    bool? isEnabled,
    String? serverKey,
    String? clientKey,
    String? merchantId,
    String? apiKey,
    bool? isProduction,
  }) =>
      PaymentGatewayConfig(
        type: type,
        isEnabled: isEnabled ?? this.isEnabled,
        serverKey: serverKey ?? this.serverKey,
        clientKey: clientKey ?? this.clientKey,
        merchantId: merchantId ?? this.merchantId,
        apiKey: apiKey ?? this.apiKey,
        isProduction: isProduction ?? this.isProduction,
      );
}

/// Result from a payment gateway transaction.
class PaymentGatewayResult {
  const PaymentGatewayResult({
    required this.success,
    required this.transactionId,
    required this.paymentType,
    this.qrImageUrl,
    this.qrString,
    this.redirectUrl,
    this.errorMessage,
    this.rawResponse,
  });

  final bool success;
  final String transactionId;
  final PaymentType paymentType;
  final String? qrImageUrl;
  final String? qrString;
  final String? redirectUrl;
  final String? errorMessage;
  final Map<String, dynamic>? rawResponse;
}
