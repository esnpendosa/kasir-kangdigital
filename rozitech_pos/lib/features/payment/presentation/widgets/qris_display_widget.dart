import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/utils/extensions.dart';

/// Reusable QRIS display widget with countdown timer and polling indicator.
/// Shows a QR code with a 5-minute (configurable) countdown.
/// Calls [onExpired] when the timer reaches zero.
/// Calls [onConfirmed] when payment is confirmed.
class QrisDisplayWidget extends StatefulWidget {
  const QrisDisplayWidget({
    super.key,
    required this.qrString,
    required this.amount,
    this.timeoutSeconds = 300,
    this.onCheckStatus,
    this.onExpired,
    this.onConfirmed,
    this.title = 'Scan QRIS untuk Membayar',
  });

  final String qrString;
  final double amount;
  final int timeoutSeconds;
  final Future<bool> Function()? onCheckStatus;
  final VoidCallback? onExpired;
  final VoidCallback? onConfirmed;
  final String title;

  @override
  State<QrisDisplayWidget> createState() => _QrisDisplayWidgetState();
}

class _QrisDisplayWidgetState extends State<QrisDisplayWidget> {
  late int _remaining;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeoutSeconds;
    _startCountdown();
    if (widget.onCheckStatus != null) {
      _startPolling();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remaining <= 0) {
        t.cancel();
        widget.onExpired?.call();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted || _isPaid) return;
      final paid = await widget.onCheckStatus!();
      if (paid && mounted) {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        setState(() => _isPaid = true);
        widget.onConfirmed?.call();
      }
    });
  }

  String get _formattedTime {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remaining <= 30) return Colors.red;
    if (_remaining <= 60) return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExpired = _remaining <= 0;

    if (_isPaid) {
      return _buildSuccessCard(cs);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Amount
        Text(
          widget.amount.toCurrency(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: cs.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // QR Code
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpired
                  ? Colors.red.withValues(alpha: 0.5)
                  : cs.outlineVariant,
              width: isExpired ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: widget.qrString,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                errorStateBuilder: (ctx, err) => const Center(
                  child: Text(
                    'Gagal memuat QR',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              if (isExpired)
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_off_rounded, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'QR Kadaluarsa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Countdown
        if (!isExpired) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _timerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _timerColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: _timerColor),
                const SizedBox(width: 6),
                Text(
                  'Berlaku $_formattedTime',
                  style: TextStyle(
                    color: _timerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Polling indicator
          if (widget.onCheckStatus != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Menunggu pembayaran...',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
        ] else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
                SizedBox(width: 6),
                Text(
                  'QR Code kadaluarsa',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSuccessCard(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pembayaran Berhasil!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.amount.toCurrency(),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
