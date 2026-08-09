import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/theme/finance_colors.dart';

/// Income / expense / net for the selected month.
class SummaryHeader extends StatelessWidget {
  const SummaryHeader({
    required this.income,
    required this.expense,
    required this.net,
    super.key,
  });

  final Money income;
  final Money expense;
  final Money net;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financeColors = FinanceColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.dashboard_net_balance.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              net.format(context),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: net.isNegative ? financeColors.expense : null,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Figure(
                    label: LocaleKeys.dashboard_income.tr(),
                    value: income,
                    color: financeColors.income,
                    icon: Icons.south_west,
                  ),
                ),
                Expanded(
                  child: _Figure(
                    label: LocaleKeys.dashboard_expense.tr(),
                    value: expense,
                    color: financeColors.expense,
                    icon: Icons.north_east,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final Money value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              Text(
                value.format(context),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
