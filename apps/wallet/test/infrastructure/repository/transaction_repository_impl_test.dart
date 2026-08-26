import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/infrastructure/repository/transaction_repository_impl.dart';

import '../../support/finance_fixtures.dart';
import '../../support/hive_harness.dart';

/// Everything above this layer is tested with in-memory doubles, so without
/// these tests nothing would notice if the storage layer stopped persisting,
/// stopped emitting, or started handing back records it could not decode.
void main() {
  late HiveHarness hive;
  late TransactionRepository repository;

  setUp(() async {
    hive = HiveHarness();
    await hive.open();
    repository = TransactionRepositoryImpl(hive.storage);
  });

  tearDown(() => hive.close());

  group('TransactionRepositoryImpl', () {
    test('an empty box reads as an empty list, not null', () async {
      expect(await repository.fetchAll(), isEmpty);
    });

    test('a saved transaction comes back identical', () async {
      final transaction = expenseOf(
        12345,
        category: 'food',
        id: 't1',
        note: 'Lunch',
        currency: Currency.usDollar,
      );

      await repository.save(transaction);

      expect((await repository.fetchAll()).single, transaction);
    });

    test('records survive closing and reopening the box', () async {
      await repository.save(expenseOf(2500, category: 'food', id: 't1'));
      await repository.save(incomeOf(90000, category: 'salary', id: 't2'));

      await hive.reopen();
      final reopened = TransactionRepositoryImpl(hive.storage);

      final all = await reopened.fetchAll()
        ..sort((a, b) => a.id.compareTo(b.id));
      expect(all.map((t) => t.id), ['t1', 't2']);
      expect(all.first.amount, const Money(2500, Currency.turkishLira));
      expect(all.last.type, TransactionType.income);
    });

    test('saving the same id replaces rather than appends', () async {
      await repository.save(expenseOf(1000, category: 'food', id: 'same'));
      await repository.save(expenseOf(9999, category: 'rent', id: 'same'));

      final all = await repository.fetchAll();
      expect(all, hasLength(1));
      expect(all.single.amount.amountMinor, 9999);
      expect(all.single.categoryId, 'rent');
    });

    test('delete removes the record', () async {
      await repository.save(expenseOf(1000, category: 'food', id: 'gone'));

      await repository.delete('gone');

      expect(await repository.fetchAll(), isEmpty);
    });

    test('deleting an unknown id is a no-op', () async {
      await repository.save(expenseOf(1000, category: 'food', id: 'keep'));

      await repository.delete('never-existed');

      expect(await repository.fetchAll(), hasLength(1));
    });

    test('watchAll emits the current contents before any change', () async {
      await repository.save(expenseOf(1000, category: 'food', id: 't1'));

      expect(await repository.watchAll().first, hasLength(1));
    });

    test('watchAll emits again on every write', () async {
      final seen = <int>[];
      final subscription = repository.watchAll().listen(
        (items) => seen.add(items.length),
      );
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);

      await repository.save(expenseOf(1000, category: 'food', id: 't1'));
      await Future<void>.delayed(Duration.zero);
      await repository.save(expenseOf(2000, category: 'rent', id: 't2'));
      await Future<void>.delayed(Duration.zero);
      await repository.delete('t1');
      await Future<void>.delayed(Duration.zero);

      expect(seen, [0, 1, 2, 1]);
    });
  });
}
