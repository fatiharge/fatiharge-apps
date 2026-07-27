import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';

/// `‹  Temmuz 2026  ›` — moves the whole dashboard between months.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    required this.period,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final MonthPeriod period;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Browsing into the future is allowed only up to the current month —
    // there is nothing recorded past today.
    final isCurrentMonth = period == MonthPeriod.of(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
        ),
        Expanded(
          child: Text(
            period.start.formatMonth(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: isCurrentMonth ? null : onNext,
          icon: const Icon(Icons.chevron_right),
          tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
        ),
      ],
    );
  }
}
