import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../settings/data/repositories/settings_repository_impl.dart';
import '../../domain/entities/payment_method_config.dart';

// ── Payment gateway config providers ─────────────────────────────────────────

/// Loads all payment gateway configs from the settings table.
///
/// Performance fix: uses a single batch load via [SettingsRepositoryImpl]
/// which reads all rows at once and caches them in memory, instead of
/// making 10 separate sequential DB queries.
final paymentGatewayConfigsProvider =
    FutureProvider<List<PaymentGatewayConfig>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final repo = SettingsRepositoryImpl(db);

  // Single batch read — loads the entire settings table once and caches it.
  // Subsequent getBool/getString calls are synchronous cache hits.
  final all = await repo.getAllSettings();

  bool flag(String key) => all[key] == 'true';
  String str(String key) => all[key] ?? '';

  return [
    PaymentGatewayConfig(
      type: PaymentType.midtrans,
      isEnabled: flag('gw_midtrans_enabled'),
      serverKey: str('gw_midtrans_server_key').isEmpty
          ? null
          : str('gw_midtrans_server_key'),
      clientKey: str('gw_midtrans_client_key').isEmpty
          ? null
          : str('gw_midtrans_client_key'),
      isProduction: flag('gw_midtrans_production'),
    ),
    PaymentGatewayConfig(
      type: PaymentType.qrisDynamic,
      isEnabled: flag('gw_qris_enabled'),
      merchantId: str('gw_qris_merchant_id').isEmpty
          ? null
          : str('gw_qris_merchant_id'),
    ),
    PaymentGatewayConfig(
      type: PaymentType.qopay,
      isEnabled: flag('gw_qopay_enabled'),
      apiKey: str('gw_qopay_api_key').isEmpty ? null : str('gw_qopay_api_key'),
    ),
    PaymentGatewayConfig(
      type: PaymentType.shopee,
      isEnabled: flag('gw_shopee_enabled'),
      apiKey:
          str('gw_shopee_api_key').isEmpty ? null : str('gw_shopee_api_key'),
    ),
  ];
});

/// Only returns enabled payment gateway configurations.
/// Always includes offline methods (cash + bank transfer) immediately,
/// even while online gateway configs are still loading.
final enabledPaymentMethodsProvider = Provider<List<PaymentType>>((ref) {
  // Always include offline methods — available instantly, no async wait.
  const always = [PaymentType.cash, PaymentType.bankTransfer];

  final configsAsync = ref.watch(paymentGatewayConfigsProvider);
  final online = configsAsync.maybeWhen(
    data: (configs) => configs
        .where((c) => c.isEnabled)
        .map((c) => c.type)
        .toList(),
    orElse: () => <PaymentType>[],
  );

  return [...always, ...online];
});

// ── Payment flow state machine ────────────────────────────────────────────────

enum PaymentFlowStatus { idle, processing, success, failed, cancelled }

class PaymentFlowState {
  const PaymentFlowState({
    this.status = PaymentFlowStatus.idle,
    this.selectedType = PaymentType.cash,
    this.cashAmount = 0,
    this.qrString,
    this.redirectUrl,
    this.errorMessage,
    this.invoiceNo,
    this.transactionId,
  });

  final PaymentFlowStatus status;
  final PaymentType selectedType;
  final double cashAmount;
  final String? qrString;
  final String? redirectUrl;
  final String? errorMessage;
  final String? invoiceNo;
  final int? transactionId;

  bool get isIdle => status == PaymentFlowStatus.idle;
  bool get isProcessing => status == PaymentFlowStatus.processing;
  bool get isSuccess => status == PaymentFlowStatus.success;
  bool get isFailed => status == PaymentFlowStatus.failed;

  PaymentFlowState copyWith({
    PaymentFlowStatus? status,
    PaymentType? selectedType,
    double? cashAmount,
    String? qrString,
    String? redirectUrl,
    String? errorMessage,
    String? invoiceNo,
    int? transactionId,
  }) =>
      PaymentFlowState(
        status: status ?? this.status,
        selectedType: selectedType ?? this.selectedType,
        cashAmount: cashAmount ?? this.cashAmount,
        qrString: qrString ?? this.qrString,
        redirectUrl: redirectUrl ?? this.redirectUrl,
        errorMessage: errorMessage ?? this.errorMessage,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        transactionId: transactionId ?? this.transactionId,
      );
}

class PaymentNotifier extends StateNotifier<PaymentFlowState> {
  PaymentNotifier() : super(const PaymentFlowState());

  void selectPaymentType(PaymentType type) {
    state = state.copyWith(selectedType: type);
  }

  void setCashAmount(double amount) {
    state = state.copyWith(cashAmount: amount);
  }

  void setProcessing() {
    state = state.copyWith(status: PaymentFlowStatus.processing);
  }

  void setSuccess({required String invoiceNo, required int transactionId}) {
    state = state.copyWith(
      status: PaymentFlowStatus.success,
      invoiceNo: invoiceNo,
      transactionId: transactionId,
    );
  }

  void setFailed(String message) {
    state = state.copyWith(
      status: PaymentFlowStatus.failed,
      errorMessage: message,
    );
  }

  void setCancelled() {
    state = state.copyWith(status: PaymentFlowStatus.cancelled);
  }

  void setQrString(String qrString) {
    state = state.copyWith(qrString: qrString);
  }

  void setRedirectUrl(String url) {
    state = state.copyWith(redirectUrl: url);
  }

  void reset() {
    state = const PaymentFlowState();
  }
}

final paymentNotifierProvider =
    StateNotifierProvider.autoDispose<PaymentNotifier, PaymentFlowState>(
  (ref) => PaymentNotifier(),
);
