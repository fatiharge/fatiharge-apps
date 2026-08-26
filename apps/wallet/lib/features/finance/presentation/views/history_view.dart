import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/presentation/views/empty_state.dart';
import 'package:wallet/features/finance/presentation/views/transaction_tile.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// [isFiltered] separates "the filter hides everything" from "nothing has been
/// recorded yet" — the same empty list means different things to the reader,
/// and only the first one is worth offering a way out of.
class HistoryView extends StatelessWidget {
  const HistoryView({
    required this.transactions,
    required this.categories,
    required this.isFiltered,
    required this.onDelete,
    required this.onEdit,
    required this.onClearFilter,
    super.key,
  });

  final List<MoneyTransaction> transactions;
  final Map<String, Category> categories;
  final bool isFiltered;

  final ValueChanged<MoneyTransaction> onDelete;
  final ValueChanged<MoneyTransaction> onEdit;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return isFiltered
          ? EmptyState(
              icon: Icons.search_off,
              title: context.tr(LocaleKeys.history_no_match),
              action: TextButton(
                onPressed: onClearFilter,
                child: Text(context.tr(LocaleKeys.history_clear_filter)),
              ),
            )
          : EmptyState(
              icon: Icons.receipt_long_outlined,
              title: context.tr(LocaleKeys.history_empty_title),
              message: context.tr(LocaleKeys.history_empty_message),
            );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Dismissible(
          key: ValueKey(transaction.id),
          direction: DismissDirection.endToStart,
          background: const _DeleteBackground(),
          onDismissed: (_) => onDelete(transaction),
          child: TransactionTile(
            transaction: transaction,
            category: categories[transaction.categoryId],
            onTap: () => onEdit(transaction),
          ),
        );
      },
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    color: Theme.of(context).colorScheme.errorContainer,
    child: Icon(
      Icons.delete_outline,
      color: Theme.of(context).colorScheme.onErrorContainer,
    ),
  );
}
