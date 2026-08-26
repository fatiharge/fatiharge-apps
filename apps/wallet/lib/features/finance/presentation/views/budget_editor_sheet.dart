import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/features/finance/application/budget/budget_state.dart';
import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/rules/amount_input.dart';
import 'package:wallet/features/finance/presentation/format/category_name.dart';
import 'package:wallet/generated/locale_keys.g.dart';

class BudgetDraft {
  const BudgetDraft({
    required this.amountText,
    this.categoryId,
    this.budgetId,
  });

  final String amountText;

  /// `null` means the overall monthly limit.
  final String? categoryId;

  final String? budgetId;
}

class BudgetEditorSheet extends StatefulWidget {
  const BudgetEditorSheet({required this.state, this.existing, super.key});

  final BudgetState state;
  final Budget? existing;

  @override
  State<BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends State<BudgetEditorSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.existing == null
        ? ''
        : widget.existing!.limit.amountMajor.toStringAsFixed(
            widget.existing!.limit.currency.decimalDigits,
          ),
  );

  late String? _categoryId = widget.existing?.categoryId;
  late final bool _isOverall = widget.existing?.isOverall ?? false;

  bool _showError = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// Categories that can still take a limit: not archived, and not already
  /// budgeted (unless this is the one being edited).
  List<MapEntry<String, String>> _selectable(BuildContext context) => [
    for (final entry in widget.state.categories.entries)
      if (!entry.value.archived &&
          (!widget.state.budgetedCategoryIds.contains(entry.key) ||
              entry.key == widget.existing?.categoryId))
        MapEntry(entry.key, entry.value.displayName(context)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPickOverall = !widget.state.hasOverallBudget || _isOverall;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existing == null
                  ? context.tr(LocaleKeys.budget_add)
                  : context.tr(LocaleKeys.budget_edit),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: InputDecoration(
                labelText: context.tr(LocaleKeys.budget_limit),
                suffixText: widget.state.currency.symbol,
                errorText: _showError
                    ? context.tr(LocaleKeys.budget_invalid_limit)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr(LocaleKeys.budget_applies_to),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (canPickOverall)
                  ChoiceChip(
                    label: Text(context.tr(LocaleKeys.budget_overall)),
                    selected: _categoryId == null,
                    onSelected: (_) => setState(() => _categoryId = null),
                  ),
                for (final entry in _selectable(context))
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _categoryId == entry.key,
                    onSelected: (_) => setState(() => _categoryId = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(context.tr(LocaleKeys.common_save)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    // Consults the rule, does not restate it — the cubit checks the same way
    // before saving. The sheet only needs the answer to decide whether to show
    // an error or close.
    if (readAmount(_amount.text, widget.state.currency).problem != null) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(
      BudgetDraft(
        amountText: _amount.text,
        categoryId: _categoryId,
        budgetId: widget.existing?.id,
      ),
    );
  }
}
