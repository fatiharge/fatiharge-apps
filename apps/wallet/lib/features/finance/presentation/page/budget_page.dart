import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/features/finance/application/budget/budget_state.dart';
import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/presentation/views/budget_editor_sheet.dart';
import 'package:wallet/features/finance/presentation/views/budget_view.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Wiring only — the list itself is [BudgetView]. Opening the editor sheet
/// stays here because it is navigation, not drawing.
@RoutePage()
class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<BudgetCubit>()..start(),
    child: BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(context.tr(LocaleKeys.tabs_budget)),
          actions: [
            IconButton(
              onPressed: () => _edit(context, state),
              tooltip: context.tr(LocaleKeys.budget_add),
              icon: const Icon(Icons.add_chart),
            ),
          ],
        ),
        body: state.loading
            ? const Center(child: CircularProgressIndicator())
            : BudgetView(
                statuses: state.statuses,
                categories: state.categories,
                onAdd: () => _edit(context, state),
                onEdit: (status) =>
                    _edit(context, state, existing: status.budget),
                onDelete: (status) =>
                    context.read<BudgetCubit>().deleteLimit(status.budget.id),
              ),
      ),
    ),
  );

  Future<void> _edit(
    BuildContext context,
    BudgetState state, {
    Budget? existing,
  }) async {
    final cubit = context.read<BudgetCubit>();
    final result = await showModalBottomSheet<BudgetDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BudgetEditorSheet(state: state, existing: existing),
    );
    if (result == null) return;

    await cubit.saveLimit(
      amountText: result.amountText,
      categoryId: result.categoryId,
      budgetId: result.budgetId,
    );
  }
}
