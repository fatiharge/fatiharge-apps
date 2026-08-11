import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/features/finance/application/entry/entry_state.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

/// Drives the add/edit transaction form.
@injectable
class EntryCubit extends Cubit<EntryState> {
  EntryCubit(this._transactions, this._categories, SettingsRepository settings)
    : super(EntryState.initial(currency: settings.readCurrency()));

  final TransactionRepository _transactions;
  final CategoryRepository _categories;

  static const _uuid = Uuid();

  StreamSubscription<void>? _categorySubscription;

  /// Loads categories and, when [existing] is given, the values being edited.
  void start({MoneyTransaction? existing}) {
    if (existing != null) {
      emit(
        state.copyWith(
          editingId: existing.id,
          type: existing.type,
          currency: existing.amount.currency,
          date: existing.date,
          amountText: _formatForEditing(existing),
          categoryId: existing.categoryId,
          note: existing.note ?? '',
        ),
      );
    }

    _categorySubscription ??= _categories.watchAll().listen((categories) {
      final selectable = categories
          .where((category) => !category.archived)
          .toList();
      emit(
        state.copyWith(
          categories: selectable,
          // Preselect for a new entry so the common case is one tap shorter.
          categoryId:
              state.categoryId ??
              (selectable.isEmpty ? null : selectable.first.id),
        ),
      );
    });
  }

  void amountChanged(String value) => emit(state.copyWith(amountText: value));

  void typeChanged(TransactionType type) => emit(state.copyWith(type: type));

  void currencyChanged(Currency currency) =>
      emit(state.copyWith(currency: currency));

  void categorySelected(String categoryId) =>
      emit(state.copyWith(categoryId: categoryId));

  void dateSelected(DateTime date) => emit(state.copyWith(date: date));

  void noteChanged(String note) => emit(state.copyWith(note: note));

  /// Validates and persists. Sets `saved` on success so the page can pop.
  Future<void> submit() async {
    if (!state.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(submitting: true, showErrors: true));

    final note = state.note.trim();
    await _transactions.save(
      MoneyTransaction(
        id: state.editingId ?? _uuid.v4(),
        type: state.type,
        categoryId: state.categoryId!,
        amount: state.amount!,
        date: state.date,
        note: note.isEmpty ? null : note,
      ),
    );

    emit(state.copyWith(submitting: false, saved: true));
  }

  /// Renders minor units back into an editable string (`12345` -> `123.45`).
  String _formatForEditing(MoneyTransaction transaction) {
    final digits = transaction.amount.currency.decimalDigits;
    return transaction.amount.amountMajor.toStringAsFixed(digits);
  }

  @override
  Future<void> close() async {
    await _categorySubscription?.cancel();
    return super.close();
  }
}
