import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../../features/payment/domain/entities/payment_method_config.dart';

/// Service for showing local push notifications (payment status, cash drawer, etc.)
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final _log = Logger();

  bool _initialized = false;

  static const _channelId = 'payment_channel';
  static const _channelName = 'Pembayaran';
  static const _channelDesc = 'Notifikasi status pembayaran dan laci kas';

  /// Call once after WidgetsFlutterBinding.ensureInitialized()
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _plugin.initialize(initSettings);

      // Create the notification channel
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _initialized = true;
      _log.i('NotificationService initialized');
    } catch (e) {
      _log.w('NotificationService init failed: $e');
    }
  }

  /// Show a generic payment notification.
  Future<void> showPaymentNotification(String title, String body) async {
    if (!_initialized) return;
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (e) {
      _log.w('showPaymentNotification error: $e');
    }
  }

  /// Show notification when payment completes successfully.
  Future<void> showPaymentSuccess(String invoiceNo, double amount) async {
    final amountStr = 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
    await showPaymentNotification(
      '✅ Pembayaran Berhasil',
      'Invoice #$invoiceNo — $amountStr',
    );
  }

  /// Show notification for online payment waiting for confirmation.
  Future<void> showPaymentPending(String invoiceNo, PaymentType type) async {
    await showPaymentNotification(
      '⏳ Menunggu Pembayaran',
      'Invoice #$invoiceNo via ${type.label} — cek status di aplikasi.',
    );
  }

  /// Show cash drawer open notification.
  Future<void> showCashDrawerOpenNotification() async {
    await showPaymentNotification(
      'Laci Kas Dibuka',
      'Laci kas telah dibuka untuk transaksi tunai.',
    );
  }
}
