import 'package:meta/meta.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';

/// Every field is optional and they combine with AND. An empty filter matches
/// everything, which is what the screen opens with.
@immutable
class TransactionFilter {
  const TransactionFilter({
    this.type,
    this.categoryIds = const <String>{},
    this.currency,
    this.period,
    this.query,
  });

  final TransactionType? type;

  /// Empty means "any category".
  final Set<String> categoryIds;

  final Currency? currency;

  final MonthPeriod? period;

  /// Case-insensitive substring match against the note.
  final String? query;

  bool get isEmpty =>
      type == null &&
      categoryIds.isEmpty &&
      currency == null &&
      period == null &&
      (query == null || query!.trim().isEmpty);

  bool matches(MoneyTransaction transaction) {
    if (type != null && transaction.type != type) return false;
    if (categoryIds.isNotEmpty &&
        !categoryIds.contains(transaction.categoryId)) {
      return false;
    }
    if (currency != null && transaction.currency != currency) return false;
    if (period != null && !period!.contains(transaction.date)) return false;

    final term = query?.trim().toLowerCase();
    if (term != null && term.isNotEmpty) {
      final note = transaction.note?.toLowerCase() ?? '';
      if (!note.contains(term)) return false;
    }
    return true;
  }

  List<MoneyTransaction> apply(Iterable<MoneyTransaction> transactions) {
    final result = transactions.where(matches).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  TransactionFilter copyWith({
    TransactionType? type,
    Set<String>? categoryIds,
    Currency? currency,
    MonthPeriod? period,
    String? query,
    bool clearType = false,
    bool clearCurrency = false,
    bool clearPeriod = false,
  }) => TransactionFilter(
    type: clearType ? null : (type ?? this.type),
    categoryIds: categoryIds ?? this.categoryIds,
    currency: clearCurrency ? null : (currency ?? this.currency),
    period: clearPeriod ? null : (period ?? this.period),
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFilter &&
          other.type == type &&
          other.currency == currency &&
          other.period == period &&
          other.query == query &&
          _sameIds(other.categoryIds);

  bool _sameIds(Set<String> other) =>
      other.length == categoryIds.length && other.containsAll(categoryIds);

  @override
  int get hashCode => Object.hash(
    type,
    currency,
    period,
    query,
    Object.hashAllUnordered(categoryIds),
  );
}
