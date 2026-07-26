import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/app/features/finance/domain/models/category.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/domain/rules/transaction_filter.dart';

/// What the filter sheet returns. Wrapped so "closed without changing
/// anything" (`null`) is distinguishable from "cleared the filter".
class TransactionFilterResult {
  const TransactionFilterResult(this.filter);

  final TransactionFilter filter;
}

/// Type / category filter for the history list.
class HistoryFilterSheet extends StatefulWidget {
  const HistoryFilterSheet({
    required this.filter,
    required this.categories,
    super.key,
  });

  final TransactionFilter filter;
  final List<Category> categories;

  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late TransactionFilter _draft = widget.filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('history.filter'.tr(), style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('history.type'.tr(), style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text('common.all'.tr()),
                  selected: _draft.type == null,
                  onSelected: (_) => setState(
                    () => _draft = _draft.copyWith(clearType: true),
                  ),
                ),
                for (final type in TransactionType.values)
                  ChoiceChip(
                    label: Text('entry.type_${type.name}'.tr()),
                    selected: _draft.type == type,
                    onSelected: (_) =>
                        setState(() => _draft = _draft.copyWith(type: type)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('history.categories'.tr(), style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final category in widget.categories)
                  FilterChip(
                    label: Text(category.name),
                    selected: _draft.categoryIds.contains(category.id),
                    onSelected: (selected) =>
                        setState(() => _toggleCategory(category.id, selected)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(
                      const TransactionFilterResult(TransactionFilter()),
                    ),
                    child: Text('history.clear_filter'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(TransactionFilterResult(_draft)),
                    child: Text('common.apply'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCategory(String id, bool selected) {
    final ids = Set<String>.from(_draft.categoryIds);
    if (selected) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    _draft = _draft.copyWith(categoryIds: ids);
  }
}
