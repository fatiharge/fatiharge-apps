import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/transaction_filter.dart';

part 'history_state.freezed.dart';

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default(TransactionFilter()) TransactionFilter filter,

    /// Everything in storage, unfiltered — kept so a filter change never needs
    /// another read.
    @Default(<MoneyTransaction>[]) List<MoneyTransaction> all,
    @Default(<String, Category>{}) Map<String, Category> categories,
    @Default(true) bool loading,
  }) = _HistoryState;

  const HistoryState._();

  List<MoneyTransaction> get visible => filter.apply(all);

  bool get isEmpty => visible.isEmpty;

  /// True when there is data but the filter hides all of it — a different
  /// empty state from "nothing recorded yet".
  bool get isFilteredEmpty => visible.isEmpty && all.isNotEmpty;
}
