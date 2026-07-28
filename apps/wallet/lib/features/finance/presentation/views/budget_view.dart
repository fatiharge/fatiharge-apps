import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/presentation/views/budget_progress_tile.dart';
import 'package:wallet/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// The list of monthly limits with this month's spending against each.
class BudgetView extends StatelessWidget {
  const BudgetView({
    required this.statuses,
    required this.categories,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Most-at-risk first.
  final List<BudgetStatus> statuses;
  final Map<String, Category> categories;

  final VoidCallback onAdd;
  final ValueChanged<BudgetStatus> onEdit;
  final ValueChanged<BudgetStatus> onDelete;

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return EmptyState(
        icon: Icons.savings_outlined,
        title: LocaleKeys.budget_empty_title.tr(),
        message: LocaleKeys.budget_empty_message.tr(),
        action: FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(LocaleKeys.budget_add.tr()),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: statuses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final status = statuses[index];
        return BudgetProgressTile(
          status: status,
          category: categories[status.budget.categoryId],
          onTap: () => onEdit(status),
          onDelete: () => onDelete(status),
        );
      },
    );
  }
}
