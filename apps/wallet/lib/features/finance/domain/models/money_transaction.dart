import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';

part 'money_transaction.freezed.dart';

enum TransactionType { income, expense }

/// [amount] is always stored positive; the direction lives in [type]. Keeping
/// the sign out of the amount means a transaction can be flipped between
/// income and expense without touching the number.
@freezed
abstract class MoneyTransaction with _$MoneyTransaction {
  const factory MoneyTransaction({
    required String id,
    required TransactionType type,
    required String categoryId,
    required Money amount,
    required DateTime date,
    String? note,
  }) = _MoneyTransaction;

  const MoneyTransaction._();

  Currency get currency => amount.currency;

  bool get isExpense => type == TransactionType.expense;

  Money get signedAmount => isExpense ? -amount : amount;
}
