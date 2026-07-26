import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/app/config/injectable.dart';
import 'package:wallet/app/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/app/features/finance/application/budget/budget_state.dart';
import 'package:wallet/app/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/app/features/finance/presentation/views/budget_editor_sheet.dart';
import 'package:wallet/app/features/finance/presentation/views/budget_progress_tile.dart';
import 'package:wallet/app/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Monthly limits and how far through each one this month is.
@RoutePage()
class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<BudgetCubit>()..start(),
    child: const _BudgetView(),
  );
}

class _BudgetView extends StatelessWidget {
  const _BudgetView();

  @override
  Widget build(BuildContext context) => BlocBuilder<BudgetCubit, BudgetState>(
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.tabs_budget.tr()),
        actions: [
          IconButton(
            onPressed: () => _edit(context, state),
            tooltip: LocaleKeys.budget_add.tr(),
            icon: const Icon(Icons.add_chart),
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.isEmpty
          ? EmptyState(
              icon: Icons.savings_outlined,
              title: LocaleKeys.budget_empty_title.tr(),
              message: LocaleKeys.budget_empty_message.tr(),
              action: FilledButton.icon(
                onPressed: () => _edit(context, state),
                icon: const Icon(Icons.add),
                label: Text(LocaleKeys.budget_add.tr()),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: state.statuses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final status = state.statuses[index];
                return BudgetProgressTile(
                  status: status,
                  category: state.categories[status.budget.categoryId],
                  onTap: () => _edit(context, state, existing: status),
                  onDelete: () => context.read<BudgetCubit>().deleteLimit(
                    status.budget.id,
                  ),
                );
              },
            ),
    ),
  );

  Future<void> _edit(
    BuildContext context,
    BudgetState state, {
    BudgetStatus? existing,
  }) async {
    final cubit = context.read<BudgetCubit>();
    final result = await showModalBottomSheet<BudgetDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          BudgetEditorSheet(state: state, existing: existing?.budget),
    );
    if (result == null) return;

    await cubit.saveLimit(
      amountText: result.amountText,
      categoryId: result.categoryId,
      budgetId: result.budgetId,
    );
  }
}
