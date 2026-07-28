import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/infrastructure/dev/demo_transactions.dart';

import '../support/finance_fixtures.dart';
import '../support/in_memory_repositories.dart';

void main() {
  late FakeTransactionRepository repository;
  DateTime clock() => DateTime(2026, 7, 20);

  setUp(() => repository = FakeTransactionRepository());
  tearDown(() => repository.dispose());

  group('seedDemoTransactions', () {
    test('fills an empty database', () async {
      await seedDemoTransactions(repository, clock: clock);

      expect((await repository.fetchAll()).length, greaterThan(20));
    });

    test('leaves an existing database alone', () async {
      repository.seed([expenseOf(1000, id: 'mine')]);

      await seedDemoTransactions(repository, clock: clock);

      expect((await repository.fetchAll()).map((t) => t.id), ['mine']);
    });

    test('is deterministic, so screenshots are reproducible', () async {
      await seedDemoTransactions(repository, clock: clock);
      final first = (await repository.fetchAll())
          .map((t) => '${t.id}:${t.amount.amountMinor}:${t.date}')
          .toList();

      final second = FakeTransactionRepository();
      addTearDown(second.dispose);
      await seedDemoTransactions(second, clock: clock);

      expect(
        (await second.fetchAll()).map(
          (t) => '${t.id}:${t.amount.amountMinor}:${t.date}',
        ),
        first,
      );
    });

    test('seeds a second currency for the dashboard switcher', () async {
      await seedDemoTransactions(repository, clock: clock);

      final currencies = (await repository.fetchAll())
          .map((t) => t.amount.currency)
          .toSet();
      expect(
        currencies,
        containsAll([Currency.turkishLira, Currency.usDollar]),
      );
    });

    test('keeps every seeded date inside the current month', () async {
      await seedDemoTransactions(repository, clock: clock);

      for (final transaction in await repository.fetchAll()) {
        expect(transaction.date.year, 2026);
        expect(transaction.date.month, 7);
        expect(transaction.date.day, lessThanOrEqualTo(20));
      }
    });
  });
}
