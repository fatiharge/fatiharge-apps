import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/presentation/format/category_icons.dart';
import 'package:wallet/features/finance/presentation/format/category_name.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// One budget with its progress bar.
class BudgetProgressTile extends StatelessWidget {
  const BudgetProgressTile({
    required this.status,
    this.category,
    this.onDelete,
    this.onTap,
    super.key,
  });

  final BudgetStatus status;
  final Category? category;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status.health) {
      BudgetHealth.safe => theme.colorScheme.primary,
      BudgetHealth.warning => Colors.orange,
      BudgetHealth.exceeded => theme.colorScheme.error,
    };
    final title = status.budget.isOverall
        ? context.tr(LocaleKeys.budget_overall)
        : category?.displayName(context) ?? status.budget.categoryId!;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    status.budget.isOverall
                        ? Icons.account_balance_wallet_outlined
                        : iconFor(category?.icon ?? CategoryIcon.other),
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: context.tr(LocaleKeys.common_delete),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  // Clamped so an overspend stays a full bar rather than
                  // overflowing the track.
                  value: status.ratio.clamp(0.0, 1.0),
                  minHeight: 8,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Both sides flex: five-figure amounts in two currencies
                  // overflowed this row on a 360dp screen.
                  Expanded(
                    child: Text(
                      '${status.spent.format(context)}'
                      ' / ${status.budget.limit.format(context)}',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      status.isExceeded
                          ? context.tr(
                              LocaleKeys.budget_over_by,
                              namedArgs: {
                                'amount': status.remaining.abs().format(
                                  context,
                                ),
                              },
                            )
                          : context.tr(
                              LocaleKeys.budget_remaining,
                              namedArgs: {
                                'amount': status.remaining.format(context),
                              },
                            ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The banner shown on the dashboard when limits have been blown.
class BudgetAlertBanner extends StatelessWidget {
  const BudgetAlertBanner({
    required this.exceeded,
    required this.categories,
    super.key,
  });

  final List<BudgetStatus> exceeded;
  final Map<String, Category> categories;

  @override
  Widget build(BuildContext context) {
    if (exceeded.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final names = exceeded
        .map(
          (status) => status.budget.isOverall
              ? context.tr(LocaleKeys.budget_overall)
              : categories[status.budget.categoryId]?.displayName(context) ??
                    status.budget.categoryId!,
        )
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.plural(
                LocaleKeys.budget_exceeded_warning,

                exceeded.length,
                namedArgs: {'names': names},
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
