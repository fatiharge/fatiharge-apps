import 'dart:math';

import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/domain/repository/transaction_repository.dart';

/// Fills an empty database with a plausible month, for screenshots and manual
/// testing. Enabled with `--dart-define=SEED_DEMO_DATA=true`.
///
/// Seeded from a fixed [Random] so repeated runs produce the same numbers.
Future<void> seedDemoTransactions(TransactionRepository repository) async {
  if ((await repository.fetchAll()).isNotEmpty) return;

  final random = Random(42);
  final now = DateTime.now();
  const expenseCategories = <String, ({int min, int max})>{
    'food': (min: 8000, max: 45000),
    'transport': (min: 3000, max: 15000),
    'bills': (min: 25000, max: 90000),
    'shopping': (min: 15000, max: 120000),
    'entertainment': (min: 10000, max: 60000),
  };

  var index = 0;
  Future<void> add(MoneyTransaction transaction) =>
      repository.save(transaction);

  await add(
    MoneyTransaction(
      id: 'demo-salary',
      type: TransactionType.income,
      categoryId: 'salary',
      amount: const Money(6500000, Currency.turkishLira),
      date: DateTime(now.year, now.month),
      note: 'Maaş',
    ),
  );

  for (final entry in expenseCategories.entries) {
    for (var i = 0; i < 4; i++) {
      final range = entry.value;
      final amount = range.min + random.nextInt(range.max - range.min);
      final day = 1 + random.nextInt(min(28, now.day));
      await add(
        MoneyTransaction(
          id: 'demo-${index++}',
          type: TransactionType.expense,
          categoryId: entry.key,
          amount: Money(amount, Currency.turkishLira),
          date: DateTime(now.year, now.month, day),
        ),
      );
    }
  }

  // A second currency, so the dashboard's currency switcher has something to
  // switch to.
  await add(
    MoneyTransaction(
      id: 'demo-usd',
      type: TransactionType.expense,
      categoryId: 'shopping',
      amount: const Money(4999, Currency.usDollar),
      date: DateTime(now.year, now.month, min(10, now.day)),
      note: 'Domain renewal',
    ),
  );
}
