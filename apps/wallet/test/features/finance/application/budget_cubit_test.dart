import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/in_memory_repositories.dart';

void main() {
  late FakeBudgetRepository budgets;
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;

  final thisMonth = DateTime(2026, 7, 15);
  DateTime clock() => thisMonth;

  setUp(() {
    budgets = FakeBudgetRepository();
    transactions = FakeTransactionRepository();
    categories = FakeCategoryRepository()
      ..seed([categoryOf('food'), categoryOf('rent')]);
  });

  tearDown(() async {
    await budgets.dispose();
    await transactions.dispose();
    await categories.dispose();
  });

  BudgetCubit build() =>
      BudgetCubit(budgets, transactions, categories, clock: clock);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('BudgetCubit', () {
    test('pairs each limit with the spending this month', () async {
      budgets.seed([budgetOf(20000, category: 'food')]);
      transactions.seed([
        expenseOf(5000, category: 'food', on: thisMonth),
        expenseOf(9000, category: 'rent', on: thisMonth),
      ]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      final status = cubit.state.statuses.single;
      expect(status.spent, const Money(5000, Currency.turkishLira));
      expect(status.health, BudgetHealth.safe);
    });

    test('saving a limit rejects a non-positive amount', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect(await cubit.saveLimit(amountText: ''), isFalse);
      expect(await cubit.saveLimit(amountText: 'abc'), isFalse);
      expect(await cubit.saveLimit(amountText: '0'), isFalse);
      expect(await budgets.fetchAll(), isEmpty);
    });

    test('saving a valid limit stores it in the selected currency', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      cubit.selectCurrency(Currency.euro);
      final saved = await cubit.saveLimit(
        amountText: '250,50',
        categoryId: 'food',
      );
      await settle();

      expect(saved, isTrue);
      final budget = (await budgets.fetchAll()).single;
      expect(budget.limit, const Money(25050, Currency.euro));
      expect(budget.categoryId, 'food');
    });

    test('a null category means the overall budget', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      await cubit.saveLimit(amountText: '100');
      await settle();

      expect((await budgets.fetchAll()).single.isOverall, isTrue);
      expect(cubit.state.hasOverallBudget, isTrue);
    });

    test(
      'saving with an existing id replaces rather than duplicates',
      () async {
        budgets.seed([budgetOf(10000, category: 'food', id: 'b1')]);

        final cubit = build()..start();
        addTearDown(cubit.close);
        await settle();

        await cubit.saveLimit(
          amountText: '300',
          categoryId: 'food',
          budgetId: 'b1',
        );
        await settle();

        final all = await budgets.fetchAll();
        expect(all, hasLength(1));
        expect(all.single.limit, const Money(30000, Currency.turkishLira));
      },
    );

    test('budgetedCategoryIds reports what already has a limit', () async {
      budgets.seed([
        budgetOf(10000, category: 'food', id: 'b1'),
        budgetOf(10000, id: 'overall'),
      ]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.budgetedCategoryIds, {'food'});
    });

    test('deleting removes the limit', () async {
      budgets.seed([budgetOf(10000, category: 'food', id: 'b1')]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      await cubit.deleteLimit('b1');
      await settle();

      expect(cubit.state.statuses, isEmpty);
    });

    test('recomputes when a transaction lands', () async {
      budgets.seed([budgetOf(10000, category: 'food')]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.statuses.single.health, BudgetHealth.safe);

      await transactions.save(
        expenseOf(11000, category: 'food', on: thisMonth),
      );
      await settle();

      expect(cubit.state.statuses.single.health, BudgetHealth.exceeded);
    });
  });
}
