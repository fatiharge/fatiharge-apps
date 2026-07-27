import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';

/// On-disk shape of a budget.
abstract final class BudgetDto {
  static const _id = 'id';
  static const _categoryId = 'categoryId';
  static const _limitMinor = 'limitMinor';
  static const _currency = 'currency';

  static Map<String, dynamic> encode(Budget budget) => <String, dynamic>{
    _id: budget.id,
    // null means "the whole month", which is a meaningful value, not missing
    // data — it round-trips as null on purpose.
    _categoryId: budget.categoryId,
    _limitMinor: budget.limit.amountMinor,
    _currency: budget.limit.currency.code,
  };

  static Budget decode(Map<String, dynamic> record) => Budget(
    id: record[_id] as String,
    categoryId: record[_categoryId] as String?,
    limit: Money(
      record[_limitMinor] as int,
      Currency.fromCode(record[_currency] as String),
    ),
  );
}
