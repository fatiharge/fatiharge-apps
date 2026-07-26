import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';

part 'money_transaction.freezed.dart';

/// Whether a transaction adds to or subtracts from the balance.
enum TransactionType { income, expense }

/// A single recorded income or expense.
///
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

  /// The amount as it affects the balance: negative for expenses.
  Money get signedAmount => isExpense ? -amount : amount;
}
