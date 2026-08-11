import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/clock.dart';
import 'package:wallet/features/finance/presentation/format/category_icons.dart';
import 'package:wallet/features/finance/presentation/format/category_name.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// The add/edit transaction form.
///
/// [amountError] arrives already localized: which failure occurred is the
/// application layer's business, phrasing it is this layer's, and the view
/// only has to render a string.
///
/// The controllers are owned by the caller because the initial text arrives
/// asynchronously when editing — seeding them here would race the load.
class TransactionEntryView extends StatelessWidget {
  const TransactionEntryView({
    required this.amountController,
    required this.noteController,
    required this.isEditing,
    required this.type,
    required this.currency,
    required this.date,
    required this.categories,
    required this.selectedCategoryId,
    required this.submitting,
    required this.onTypeChanged,
    required this.onAmountChanged,
    required this.onCurrencyChanged,
    required this.onCategorySelected,
    required this.onDateSelected,
    required this.onNoteChanged,
    required this.onSubmit,
    this.amountError,
    this.clock = systemClock,
    super.key,
  });

  final TextEditingController amountController;
  final TextEditingController noteController;

  final bool isEditing;
  final TransactionType type;
  final Currency currency;
  final DateTime date;

  /// Selectable categories; archived ones are expected to be filtered out
  /// before they get here.
  final List<Category> categories;
  final String? selectedCategoryId;
  final bool submitting;

  /// Localized message under the amount field, or `null` when it is fine.
  final String? amountError;

  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<Currency> onCurrencyChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSubmit;

  /// Bounds the date picker; injected so a test can pin today.
  final Clock clock;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing
                  ? context.tr(LocaleKeys.entry_edit_title)
                  : context.tr(LocaleKeys.entry_add_title),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _TypeSelector(type: type, onChanged: onTypeChanged),
            const SizedBox(height: 20),
            _AmountField(
              controller: amountController,
              currency: currency,
              autofocus: !isEditing,
              errorText: amountError,
              onChanged: onAmountChanged,
              onCurrencyChanged: onCurrencyChanged,
            ),
            const SizedBox(height: 20),
            Text(
              context.tr(LocaleKeys.entry_category),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _CategoryPicker(
              categories: categories,
              selectedId: selectedCategoryId,
              onSelected: onCategorySelected,
            ),
            const SizedBox(height: 20),
            _DateField(date: date, onChanged: onDateSelected, clock: clock),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              onChanged: onNoteChanged,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.tr(LocaleKeys.entry_note),
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.tr(LocaleKeys.common_save)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  /// Spelled out rather than interpolated from the enum name, so a renamed
  /// value is a compile error instead of a key that silently renders raw.
  String _label(BuildContext context, TransactionType value) => switch (value) {
    TransactionType.income => context.tr(LocaleKeys.entry_type_income),
    TransactionType.expense => context.tr(LocaleKeys.entry_type_expense),
  };

  @override
  Widget build(BuildContext context) => SegmentedButton<TransactionType>(
    segments: [
      for (final value in TransactionType.values)
        ButtonSegment(
          value: value,
          label: Text(_label(context, value)),
          icon: Icon(
            value == TransactionType.expense
                ? Icons.north_east
                : Icons.south_west,
          ),
        ),
    ],
    selected: {type},
    onSelectionChanged: (selection) => onChanged(selection.first),
  );
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.currency,
    required this.autofocus,
    required this.onChanged,
    required this.onCurrencyChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final Currency currency;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<Currency> onCurrencyChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    autofocus: autofocus,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    // Digits plus a single separator: the parser accepts both `,` and `.`.
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
    style: Theme.of(context).textTheme.headlineSmall,
    decoration: InputDecoration(
      labelText: context.tr(LocaleKeys.entry_amount),
      errorText: errorText,
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Currency>(
            value: currency,
            onChanged: (value) =>
                value == null ? null : onCurrencyChanged(value),
            items: [
              for (final value in Currency.values)
                DropdownMenuItem(
                  value: value,
                  child: Text('${value.symbol} ${value.code}'),
                ),
            ],
          ),
        ),
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 96),
    ),
  );
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Text(context.tr(LocaleKeys.entry_no_categories));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final category in categories)
          ChoiceChip(
            avatar: Icon(iconFor(category.icon), size: 18),
            label: Text(category.displayName(context)),
            selected: selectedId == category.id,
            onSelected: (_) => onSelected(category.id),
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.onChanged,
    required this.clock,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final Clock clock;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _pick(context),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: context.tr(LocaleKeys.entry_date),
        prefixIcon: const Icon(Icons.event_outlined),
      ),
      child: Text(date.formatDay(context)),
    ),
  );

  Future<void> _pick(BuildContext context) async {
    final now = clock();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(now.year - 5),
      // No future-dating: this is a ledger of what happened.
      lastDate: now,
    );
    if (picked != null) onChanged(picked);
  }
}
