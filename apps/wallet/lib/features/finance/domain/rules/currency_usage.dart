import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// The currencies actually present in [transactions], in enum order.
///
/// Drives the dashboard's currency switcher: with no exchange rates, the user
/// picks which currency they are looking at, and offering currencies they have
/// never used would be noise.
List<Currency> currenciesUsed(Iterable<MoneyTransaction> transactions) {
  final used = transactions.map((t) => t.currency).toSet();
  return Currency.values.where(used.contains).toList();
}
