import 'package:flutter/foundation.dart' show immutable, listEquals, mapEquals;
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/transaction_filter.dart';

/// The history screen: the full set, the active filter, and the filtered view.
@immutable
class HistoryState {
  const HistoryState({
    this.filter = const TransactionFilter(),
    this.all = const [],
    this.categories = const {},
    this.loading = true,
  });

  final TransactionFilter filter;

  /// Everything in storage, unfiltered — kept so a filter change never needs
  /// another read.
  final List<MoneyTransaction> all;

  final Map<String, Category> categories;

  final bool loading;

  /// [all] with [filter] applied, newest first.
  List<MoneyTransaction> get visible => filter.apply(all);

  bool get isEmpty => visible.isEmpty;

  /// True when there is data but the filter hides all of it — a different
  /// empty state from "nothing recorded yet".
  bool get isFilteredEmpty => visible.isEmpty && all.isNotEmpty;

  HistoryState copyWith({
    TransactionFilter? filter,
    List<MoneyTransaction>? all,
    Map<String, Category>? categories,
    bool? loading,
  }) => HistoryState(
    filter: filter ?? this.filter,
    all: all ?? this.all,
    categories: categories ?? this.categories,
    loading: loading ?? this.loading,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryState &&
          other.filter == filter &&
          listEquals(other.all, all) &&
          mapEquals(other.categories, categories) &&
          other.loading == loading;

  @override
  int get hashCode => Object.hash(
    filter,
    Object.hashAll(all),
    Object.hashAllUnordered(
      categories.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    loading,
  );
}
