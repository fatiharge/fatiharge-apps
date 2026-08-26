import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';

/// Visible only when the user actually has more than one — with no exchange
/// rates, totals are per-currency and this is how you move between them.
class CurrencyChips extends StatelessWidget {
  const CurrencyChips({
    required this.available,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Currency> available;
  final Currency selected;
  final ValueChanged<Currency> onSelected;

  @override
  Widget build(BuildContext context) {
    if (available.length < 2) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          for (final currency in available)
            ChoiceChip(
              label: Text('${currency.symbol} ${currency.code}'),
              selected: currency == selected,
              onSelected: (_) => onSelected(currency),
            ),
        ],
      ),
    );
  }
}
