import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/app/config/injectable.dart';
import 'package:wallet/app/features/finance/application/dashboard/dashboard_cubit.dart';
import 'package:wallet/app/features/finance/application/dashboard/dashboard_state.dart';
import 'package:wallet/app/features/finance/presentation/views/budget_progress_tile.dart';
import 'package:wallet/app/features/finance/presentation/views/category_pie_chart.dart';
import 'package:wallet/app/features/finance/presentation/views/currency_chips.dart';
import 'package:wallet/app/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/app/features/finance/presentation/views/month_switcher.dart';
import 'package:wallet/app/features/finance/presentation/views/summary_header.dart';
import 'package:wallet/app/route/app_router.gr.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Monthly totals, the category breakdown and any blown budgets.
@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<DashboardCubit>()..start(),
    child: const _DashboardView(),
  );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(LocaleKeys.tabs_dashboard.tr())),
    body: BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => switch (state) {
        DashboardLoading() => const Center(child: CircularProgressIndicator()),
        DashboardReady() => _Ready(state: state),
      },
    ),
  );
}

class _Ready extends StatelessWidget {
  const _Ready({required this.state});

  final DashboardReady state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        MonthSwitcher(
          period: state.period,
          onPrevious: cubit.showPreviousMonth,
          onNext: cubit.showNextMonth,
        ),
        if (state.availableCurrencies.length > 1) ...[
          CurrencyChips(
            available: state.availableCurrencies,
            selected: state.currency,
            onSelected: cubit.selectCurrency,
          ),
          const SizedBox(height: 12),
        ],
        if (!state.hasData)
          _EmptyMonth(hasAnyCurrency: state.availableCurrencies.isNotEmpty)
        else ...[
          if (state.exceededBudgets.isNotEmpty) ...[
            BudgetAlertBanner(
              exceeded: state.exceededBudgets,
              categories: state.categories,
            ),
            const SizedBox(height: 16),
          ],
          SummaryHeader(
            income: state.summary.income,
            expense: state.summary.expense,
            net: state.summary.net,
          ),
          const SizedBox(height: 16),
          CategoryPieChart(
            breakdown: state.summary.expenseBreakdown,
            total: state.summary.expense,
            categories: state.categories,
          ),
          if (state.budgetStatuses.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              LocaleKeys.budget_title.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final status in state.budgetStatuses)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BudgetProgressTile(
                  status: status,
                  category: state.categories[status.budget.categoryId],
                ),
              ),
          ],
        ],
      ],
    );
  }
}

class _EmptyMonth extends StatelessWidget {
  const _EmptyMonth({required this.hasAnyCurrency});

  /// Distinguishes "nothing this month" from "nothing at all", which want
  /// different wording.
  final bool hasAnyCurrency;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 48),
    child: EmptyState(
      icon: Icons.insights_outlined,
      title: hasAnyCurrency
          ? LocaleKeys.dashboard_empty_month.tr()
          : LocaleKeys.dashboard_empty_title.tr(),
      message: LocaleKeys.dashboard_empty_message.tr(),
      action: FilledButton.icon(
        onPressed: () => context.router.push(TransactionEntryRoute()),
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.entry_add_title.tr()),
      ),
    ),
  );
}
