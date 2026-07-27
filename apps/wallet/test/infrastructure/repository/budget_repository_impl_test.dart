import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/infrastructure/repository/budget_repository_impl.dart';

import '../../support/finance_fixtures.dart';
import '../../support/hive_harness.dart';

void main() {
  late HiveHarness hive;
  late BudgetRepository repository;

  setUp(() async {
    hive = HiveHarness();
    await hive.open();
    repository = BudgetRepositoryImpl(hive.storage);
  });

  tearDown(() => hive.close());

  group('BudgetRepositoryImpl', () {
    test('a category budget comes back identical', () async {
      final budget = budgetOf(25000, category: 'food', id: 'b1');

      await repository.save(budget);

      expect((await repository.fetchAll()).single, budget);
    });

    test('an overall budget keeps its null category through storage', () async {
      const overall = Budget(
        id: 'b2',
        limit: Money(100000, Currency.euro),
      );

      await repository.save(overall);
      await hive.reopen();
      final reopened = BudgetRepositoryImpl(hive.storage);

      final stored = (await reopened.fetchAll()).single;
      expect(stored.categoryId, isNull);
      expect(stored.isOverall, isTrue);
      expect(stored.limit, const Money(100000, Currency.euro));
    });

    test('delete removes it', () async {
      await repository.save(budgetOf(1000, id: 'b1'));

      await repository.delete('b1');

      expect(await repository.fetchAll(), isEmpty);
    });

    test('watchAll emits the current contents then every change', () async {
      final seen = <int>[];
      final subscription = repository.watchAll().listen(
        (items) => seen.add(items.length),
      );
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);

      await repository.save(budgetOf(1000, id: 'b1'));
      await Future<void>.delayed(Duration.zero);
      await repository.delete('b1');
      await Future<void>.delayed(Duration.zero);

      expect(seen, [0, 1, 0]);
    });
  });
}
