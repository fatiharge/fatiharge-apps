import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/features/finance/application/entry/entry_state.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/presentation/views/transaction_entry_view.dart';
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

/// Owns the text controllers and turns the form's state into arguments.
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

  /// Which failure it is belongs to the form; how it reads belongs here.
  String? _amountError(EntryError? error) => switch (error) {
    EntryError.amountMissing => LocaleKeys.entry_error_amount_missing.tr(),
    EntryError.amountInvalid => LocaleKeys.entry_error_amount_invalid.tr(),
    EntryError.amountNotPositive => LocaleKeys.entry_error_amount_positive.tr(),
    EntryError.noCategory || null => null,
  };

  @override
  Widget build(BuildContext context) => BlocConsumer<EntryCubit, EntryState>(
    listenWhen: (previous, current) => !previous.saved && current.saved,
    listener: (context, state) => context.router.maybePop(true),
    builder: (context, state) {
      if (state.isEditing) _syncOnce(state);
      final cubit = context.read<EntryCubit>();

      return TransactionEntryView(
        amountController: _amount,
        noteController: _note,
        isEditing: state.isEditing,
        type: state.type,
        currency: state.currency,
        date: state.date,
        categories: state.categories,
        selectedCategoryId: state.categoryId,
        submitting: state.submitting,
        amountError: _amountError(state.visibleError),
        onTypeChanged: cubit.typeChanged,
        onAmountChanged: cubit.amountChanged,
        onCurrencyChanged: cubit.currencyChanged,
        onCategorySelected: cubit.categorySelected,
        onDateSelected: cubit.dateSelected,
        onNoteChanged: cubit.noteChanged,
        onSubmit: cubit.submit,
      );
    },
  );
}
