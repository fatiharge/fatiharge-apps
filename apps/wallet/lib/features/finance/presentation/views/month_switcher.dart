import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';

class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    required this.period,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final MonthPeriod period;
  final VoidCallback onPrevious;

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Row(
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
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right),
        tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
      ),
    ],
  );
}
