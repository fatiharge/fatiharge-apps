import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';

enum AmountProblem {
  missing,

  notANumber,

  /// Direction comes from the transaction type, not the sign, and a budget of
  /// zero is blown by the first kuruş.
  notPositive,
}

typedef AmountReading = ({Money? money, AmountProblem? problem});

/// One rule wherever money is entered. It used to live in three places that
/// had to agree.
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
