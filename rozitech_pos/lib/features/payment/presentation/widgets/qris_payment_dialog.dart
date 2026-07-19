import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/utils/extensions.dart';

/// Dialog that displays a QR code for QRIS payments with a countdown timer
/// and a manual confirmation button.
///
/// Returns `true` when the payment is confirmed (either via polling or manual),
/// or `null`/`false` when cancelled.
class QrisPaymentDialog extends StatefulWidget {
  const QrisPaymentDialog({
    super.key,
    required this.qrString,
    required this.amount,
    this.timeoutSeconds = 300,
    this.onCheckStatus,
  });

  /// The raw QRIS payload / string to encode into the QR image.
  final String qrString;

  /// Amount to pay (displayed to the customer).
  final double amount;

  /// Countdown duration in seconds (default 5 minutes).
  final int timeoutSeconds;

  /// Optional callback that checks whether payment has been received.
  /// Should return `true` if paid.
  final Future<bool> Function()? onCheckStatus;

  @override
  State<QrisPaymentDialog> createState() => _QrisPaymentDialogState();
}

class _QrisPaymentDialogState extends State<QrisPaymentDialog> {
  late int _remaining;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  bool _isChecking = false;

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
        Navigator.of(context).pop(false);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final paid = await widget.onCheckStatus!();
      if (paid && mounted) {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        Navigator.of(context).pop(true);
      }
    });
  }

  Future<void> _manualConfirm() async {
    setState(() => _isChecking = true);
    if (widget.onCheckStatus != null) {
      final paid = await widget.onCheckStatus!();
      if (!mounted) return;
      if (paid) {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        Navigator.of(context).pop(true);
        return;
      }
    } else {
      // No status checker → accept manual confirmation directly
      _pollTimer?.cancel();
      _countdownTimer?.cancel();
      if (mounted) Navigator.of(context).pop(true);
      return;
    }
    if (mounted) {
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran belum terdeteksi, coba lagi sebentar.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String get _formattedTime {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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

    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      title: const Row(
        children: [
          Icon(Icons.qr_code_2_rounded, color: Colors.green),
          SizedBox(width: 8),
          Text('Pembayaran QRIS'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amount
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                widget.amount.toCurrency(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ),

            // QR Code
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: QrImageView(
                data: widget.qrString,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                errorStateBuilder: (ctx, err) => const Center(
                  child: Text('Gagal memuat QR', textAlign: TextAlign.center),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Countdown / expired
            if (!isExpired) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Berlaku selama $_formattedTime',
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ],
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
                          strokeWidth: 2, color: cs.primary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Menunggu konfirmasi...',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
            ] else
              const Text(
                'QR Code kadaluarsa',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _pollTimer?.cancel();
            _countdownTimer?.cancel();
            Navigator.of(context).pop(false);
          },
          child:
              const Text('Batal', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton.icon(
          onPressed: isExpired || _isChecking ? null : _manualConfirm,
          icon: _isChecking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_rounded),
          label: const Text('Konfirmasi Manual'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
