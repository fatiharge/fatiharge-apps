import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/app/config/injectable.dart';
import 'package:wallet/app/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/app/features/finance/application/entry/entry_state.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/presentation/format/category_icons.dart';
import 'package:wallet/app/features/finance/presentation/format/money_format.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Add or edit a transaction.
@RoutePage()
class TransactionEntryPage extends StatelessWidget {
  const TransactionEntryPage({super.key, this.existing});

  /// `null` when adding.
  final MoneyTransaction? existing;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<EntryCubit>()..start(existing: existing),
    child: const _EntryForm(),
  );
}

class _EntryForm extends StatefulWidget {
  const _EntryForm();

  @override
  State<_EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<_EntryForm> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  bool _synced = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Seeds the controllers once, when editing loads existing values.
  void _syncOnce(EntryState state) {
    if (_synced) return;
    _synced = true;
    _amount.text = state.amountText;
    _note.text = state.note;
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<EntryCubit, EntryState>(
    listenWhen: (previous, current) => !previous.saved && current.saved,
    listener: (context, state) => context.router.maybePop(true),
    builder: (context, state) {
      if (state.isEditing) _syncOnce(state);
      final cubit = context.read<EntryCubit>();
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
                state.isEditing
                    ? LocaleKeys.entry_edit_title.tr()
                    : LocaleKeys.entry_add_title.tr(),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _TypeSelector(
                type: state.type,
                onChanged: cubit.typeChanged,
              ),
              const SizedBox(height: 20),
              _AmountField(
                controller: _amount,
                state: state,
                onChanged: cubit.amountChanged,
                onCurrencyChanged: cubit.currencyChanged,
              ),
              const SizedBox(height: 20),
              Text(
                LocaleKeys.entry_category.tr(),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              _CategoryPicker(
                state: state,
                onSelected: cubit.categorySelected,
              ),
              const SizedBox(height: 20),
              _DateField(
                date: state.date,
                onChanged: cubit.dateSelected,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _note,
                onChanged: cubit.noteChanged,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: LocaleKeys.entry_note.tr(),
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.submitting ? null : cubit.submit,
                child: state.submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(LocaleKeys.common_save.tr()),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<TransactionType>(
    segments: [
      for (final value in TransactionType.values)
        ButtonSegment(
          value: value,
          label: Text('entry.type_${value.name}'.tr()),
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
    required this.state,
    required this.onChanged,
    required this.onCurrencyChanged,
  });

  final TextEditingController controller;
  final EntryState state;
  final ValueChanged<String> onChanged;
  final ValueChanged<Currency> onCurrencyChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    autofocus: !state.isEditing,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    // Digits plus a single separator: the parser accepts both `,` and `.`.
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
    ],
    style: Theme.of(context).textTheme.headlineSmall,
    decoration: InputDecoration(
      labelText: LocaleKeys.entry_amount.tr(),
      errorText: switch (state.visibleError) {
        EntryError.amountMissing => LocaleKeys.entry_error_amount_missing.tr(),
        EntryError.amountInvalid => LocaleKeys.entry_error_amount_invalid.tr(),
        EntryError.amountNotPositive =>
          LocaleKeys.entry_error_amount_positive.tr(),
        EntryError.noCategory || null => null,
      },
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Currency>(
            value: state.currency,
            onChanged: (value) =>
                value == null ? null : onCurrencyChanged(value),
            items: [
              for (final currency in Currency.values)
                DropdownMenuItem(
                  value: currency,
                  child: Text('${currency.symbol} ${currency.code}'),
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
  const _CategoryPicker({required this.state, required this.onSelected});

  final EntryState state;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (state.categories.isEmpty) {
      return Text(LocaleKeys.entry_no_categories.tr());
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final category in state.categories)
          ChoiceChip(
            avatar: Icon(iconFor(category.icon), size: 18),
            label: Text(category.name),
            selected: state.categoryId == category.id,
            onSelected: (_) => onSelected(category.id),
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _pick(context),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: LocaleKeys.entry_date.tr(),
        prefixIcon: const Icon(Icons.event_outlined),
      ),
      child: Text(date.formatDay(context)),
    ),
  );

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
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
