import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/amount_input.dart';

part 'entry_state.freezed.dart';

enum EntryError { amountMissing, amountInvalid, amountNotPositive, noCategory }

/// The amount is held as raw [amountText] rather than a parsed [Money]: the
/// user types `12,` on the way to `12,50`, and a state that cannot represent
/// half-typed input forces the widget to keep its own shadow copy.
@freezed
abstract class EntryState with _$EntryState {
  const factory EntryState({
    required TransactionType type,
    required Currency currency,
    required DateTime date,

    String? editingId,
    @Default('') String amountText,
    String? categoryId,
    @Default('') String note,

    @Default(<Category>[]) List<Category> categories,
    @Default(false) bool submitting,
    @Default(false) bool saved,

    /// Errors stay hidden until the first submit attempt.
    @Default(false) bool showErrors,
  }) = _EntryState;

  const EntryState._();

  factory EntryState.initial({DateTime? now, Currency? currency}) => EntryState(
    type: TransactionType.expense,
    currency: currency ?? Currency.turkishLira,
    date: now ?? DateTime.now(),
  );

  bool get isEditing => editingId != null;

  Money? get amount => readAmount(amountText, currency).money;

  EntryError? get error {
    final problem = readAmount(amountText, currency).problem;
    if (problem != null) {
      return switch (problem) {
        AmountProblem.missing => EntryError.amountMissing,
        AmountProblem.notANumber => EntryError.amountInvalid,
        AmountProblem.notPositive => EntryError.amountNotPositive,
      };
    }
    if (categoryId == null) return EntryError.noCategory;
    return null;
  }

  bool get isValid => error == null;

  EntryError? get visibleError => showErrors ? error : null;
}
