import 'package:flutter/material.dart';

/// Numeric keypad for the POS cash input.
class PosNumpad extends StatelessWidget {
  const PosNumpad({super.key, required this.onKey});
  final void Function(String key) onKey;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['000', '0', '⌫'],
  ];

  static const _quickAmounts = [
    '10000',
    '20000',
    '50000',
    '100000',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Quick amount buttons
        Row(
          children: _quickAmounts.map((amt) {
            final label =
                int.parse(amt) >= 1000 ? '${int.parse(amt) ~/ 1000}rb' : amt;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: OutlinedButton(
                  onPressed: () => onKey(amt),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text(label),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // Number grid
        for (final row in _keys)
          Row(
            children: row.map((key) {
              final isBackspace = key == '⌫';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Material(
                    color: isBackspace
                        ? cs.errorContainer
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onKey(key),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Text(
                          key,
                          style: TextStyle(
                            fontSize: key.length > 1 ? 14 : 18,
                            fontWeight: FontWeight.w700,
                            color: isBackspace
                                ? cs.error
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
