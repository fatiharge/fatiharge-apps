import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';

part 'budget.freezed.dart';

/// One model covers both shapes the UI offers: a [categoryId] of `null` means
/// "everything I spend this month", otherwise the limit applies to that
/// category alone. A budget is scoped to the currency of its [limit] — with no
/// exchange rates, a `TRY` budget simply ignores `USD` spending.
@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,
    required Money limit,
    String? categoryId,
  }) = _Budget;

  const Budget._();

  bool get isOverall => categoryId == null;

  Currency get currency => limit.currency;
}
