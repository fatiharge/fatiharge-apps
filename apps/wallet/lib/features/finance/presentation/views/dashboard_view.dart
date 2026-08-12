import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/finance/presentation/views/budget_progress_tile.dart';
import 'package:wallet/features/finance/presentation/views/category_pie_chart.dart';
import 'package:wallet/features/finance/presentation/views/currency_chips.dart';
import 'package:wallet/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/features/finance/presentation/views/month_switcher.dart';
import 'package:wallet/features/finance/presentation/views/summary_header.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// The dashboard, once there is something to draw.
///
/// Takes values and callbacks — no cubit, no router, no container. That is
/// what lets it be pumped in a widget test with literals, and what would let
/// it move out of this app without dragging the application layer along.
class DashboardView extends StatelessWidget {
  const DashboardView({
    required this.period,
    required this.currency,
    required this.availableCurrencies,
    required this.summary,
    required this.budgetStatuses,
    required this.categories,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrencySelected,
    required this.onAddTransaction,
    this.reminderNudge,
    super.key,
  });

  final MonthPeriod period;
  final Currency currency;
  final List<Currency> availableCurrencies;
  final MonthlySummary summary;

  /// Most-at-risk budget first.
  final List<BudgetStatus> budgetStatuses;
  final Map<String, Category> categories;

  final VoidCallback onPreviousMonth;
  final VoidCallback? onNextMonth;
  final ValueChanged<Currency> onCurrencySelected;
  final VoidCallback onAddTransaction;

  /// Offered when the month has numbers and the reminder is not already on.
  /// Passed in rather than decided here — a view does not read preferences.
  final Widget? reminderNudge;

  List<BudgetStatus> get _exceeded =>
      budgetStatuses.where((status) => status.isExceeded).toList();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
    children: [
      MonthSwitcher(
        period: period,
        onPrevious: onPreviousMonth,
        onNext: onNextMonth,
      ),
      if (availableCurrencies.length > 1) ...[
        CurrencyChips(
          available: availableCurrencies,
          selected: currency,
          onSelected: onCurrencySelected,
        ),
        const SizedBox(height: 12),
      ],
      if (summary.isEmpty)
        _EmptyMonth(
          hasAnyCurrency: availableCurrencies.isNotEmpty,
          onAddTransaction: onAddTransaction,
        )
      else ...[
        if (_exceeded.isNotEmpty) ...[
          BudgetAlertBanner(exceeded: _exceeded, categories: categories),
          const SizedBox(height: 16),
        ],
        SummaryHeader(
          income: summary.income,
          expense: summary.expense,
          net: summary.net,
        ),
        const SizedBox(height: 16),
        CategoryPieChart(
          breakdown: summary.expenseBreakdown,
          total: summary.expense,
          categories: categories,
        ),
        if (budgetStatuses.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            context.tr(LocaleKeys.budget_title),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final status in budgetStatuses)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BudgetProgressTile(
                status: status,
                category: categories[status.budget.categoryId],
              ),
            ),
        ],
      ],
    ],
  );
}

class _EmptyMonth extends StatelessWidget {
  const _EmptyMonth({
    required this.hasAnyCurrency,
    required this.onAddTransaction,
  });

  /// Distinguishes "nothing this month" from "nothing at all", which want
  /// different wording.
  final bool hasAnyCurrency;
  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 48),
    child: EmptyState(
      icon: Icons.insights_outlined,
      title: hasAnyCurrency
          ? context.tr(LocaleKeys.dashboard_empty_month)
          : context.tr(LocaleKeys.dashboard_empty_title),
      message: context.tr(LocaleKeys.dashboard_empty_message),
      action: FilledButton.icon(
        onPressed: onAddTransaction,
        icon: const Icon(Icons.add),
        label: Text(context.tr(LocaleKeys.entry_add_title)),
      ),
    ),
  );
}
