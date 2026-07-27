import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';

/// Why something the user typed cannot be recorded as an amount.
enum AmountProblem {
  /// Nothing was typed.
  missing,

  /// The text is not a number.
  notANumber,

  /// Zero or negative. Direction is carried by the transaction type rather
  /// than the sign, and a budget of zero is blown by the first kuruş, so
  /// neither an entry nor a limit has a use for it.
  notPositive,
}

/// The outcome of reading typed text. Exactly one field is non-null.
typedef AmountReading = ({Money? money, AmountProblem? problem});

/// Reads what the user typed as an amount that can be stored.
///
/// It is the same rule wherever money is entered — a transaction amount and a
/// budget limit are both positive quantities — so it lives here rather than in
/// each form. It was previously implemented three times: in the entry state,
/// in the budget cubit, and again inside the budget sheet, which meant three
/// places to find and agree on whenever the rule moved.
AmountReading readAmount(String text, Currency currency) {
  if (text.trim().isEmpty) {
    return (money: null, problem: AmountProblem.missing);
  }

  final money = Money.tryParse(text, currency);
  if (money == null) {
    return (money: null, problem: AmountProblem.notANumber);
  }
  if (money.amountMinor <= 0) {
    return (money: null, problem: AmountProblem.notPositive);
  }

  return (money: money, problem: null);
}
