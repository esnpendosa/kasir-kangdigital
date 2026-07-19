import 'package:flutter/material.dart';
import '../../domain/entities/payment_method_config.dart';

/// A horizontally scrollable row of payment-method selection chips.
///
/// [selected] — currently active payment type.
/// [onSelected] — called with the new [PaymentType] when a chip is tapped.
/// [showMidtrans] — whether to show the Midtrans chip (only if configured).
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.showMidtrans = false,
  });

  final PaymentType selected;
  final ValueChanged<PaymentType> onSelected;
  final bool showMidtrans;

  static const _baseOptions = [
    (PaymentType.cash, Icons.payments_rounded, 'Tunai'),
    (PaymentType.bankTransfer, Icons.account_balance_rounded, 'Transfer Bank'),
    (PaymentType.qrisDynamic, Icons.qr_code_2_rounded, 'QRIS'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final options = [
      ..._baseOptions,
      if (showMidtrans)
        (PaymentType.midtrans, Icons.credit_card_rounded, 'Midtrans'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final (type, icon, label) = opt;
          final isSelected = selected == type;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              avatar: Icon(icon, size: 16),
              iconTheme: IconThemeData(
                color: isSelected ? Colors.white : cs.onSurfaceVariant,
              ),
              label: Text(label),
              selected: isSelected,
              selectedColor: cs.primary,
              onSelected: (v) {
                if (v) onSelected(type);
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : cs.onSurfaceVariant,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
