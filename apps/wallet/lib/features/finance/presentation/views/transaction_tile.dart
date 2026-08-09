import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/presentation/format/category_icons.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';
import 'package:wallet/theme/finance_colors.dart';

/// One row in the history list.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.category,
    this.onTap,
    super.key,
  });

  final MoneyTransaction transaction;

  /// `null` when the category was deleted from storage — the row still has to
  /// render, so it falls back to a neutral look.
  final Category? category;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category == null
        ? theme.colorScheme.outline
        : Color(category!.colorArgb);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.16),
        foregroundColor: color,
        child: Icon(iconFor(category?.icon ?? CategoryIcon.other), size: 20),
      ),
      title: Text(
        category?.name ?? transaction.categoryId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          transaction.date.formatDay(context),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            transaction.note!,
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        transaction.formatAmount(context),
        style: theme.textTheme.titleSmall?.copyWith(
          color: FinanceColors.of(
            context,
          ).amountColor(isExpense: transaction.isExpense),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
