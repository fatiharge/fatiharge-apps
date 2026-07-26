import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app/features/finance/application/dashboard/dashboard_cubit.dart';
import 'package:wallet/app/features/finance/application/dashboard/dashboard_state.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/app/features/finance/domain/rules/month_period.dart';

import '../../../../support/finance_fixtures.dart';
import '../../../../support/in_memory_repositories.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;
  late FakeBudgetRepository budgets;

  final thisMonth = DateTime.now();

  setUp(() {
    transactions = FakeTransactionRepository();
    categories = FakeCategoryRepository();
    budgets = FakeBudgetRepository();
  });

  tearDown(() async {
    await transactions.dispose();
    await categories.dispose();
    await budgets.dispose();
  });

  DashboardCubit build() => DashboardCubit(transactions, categories, budgets);

  /// Lets the three repository streams deliver their first values.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('DashboardCubit', () {
    test('starts loading and becomes ready once storage answers', () async {
      final cubit = build();
      addTearDown(cubit.close);

      expect(cubit.state, isA<DashboardLoading>());

      cubit.start();
      await settle();

      expect(cubit.state, isA<DashboardReady>());
    });

    test('totals the current month', () async {
      transactions.seed([
        incomeOf(100000, category: 'salary', on: thisMonth),
        expenseOf(30000, category: 'food', on: thisMonth),
      ]);
      categories.seed([categoryOf('food'), categoryOf('salary')]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      final state = cubit.state as DashboardReady;
      expect(state.summary.income, const Money(100000, Currency.turkishLira));
      expect(state.summary.expense, const Money(30000, Currency.turkishLira));
      expect(state.hasData, isTrue);
    });

    test('recomputes when a transaction is added afterwards', () async {
      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect((cubit.state as DashboardReady).hasData, isFalse);

      await transactions.save(expenseOf(5000, on: thisMonth));
      await settle();

      expect(
        (cubit.state as DashboardReady).summary.expense,
        const Money(5000, Currency.turkishLira),
      );
    });

    test('changing the month changes what is counted', () async {
      final lastMonth = MonthPeriod.of(thisMonth).previous;
      transactions.seed([
        expenseOf(1000, on: thisMonth),
        expenseOf(9000, on: lastMonth.start),
      ]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect(
        (cubit.state as DashboardReady).summary.expense,
        const Money(1000, Currency.turkishLira),
      );

      cubit.showPreviousMonth();

      final state = cubit.state as DashboardReady;
      expect(state.period, lastMonth);
      expect(state.summary.expense, const Money(9000, Currency.turkishLira));
    });

    test(
      'lists only the currencies in use and defaults to the first',
      () async {
        transactions.seed([
          expenseOf(1000, currency: Currency.usDollar, on: thisMonth),
        ]);

        final cubit = build()..start();
        addTearDown(cubit.close);
        await settle();

        final state = cubit.state as DashboardReady;
        expect(state.availableCurrencies, [Currency.usDollar]);
        expect(state.currency, Currency.usDollar);
      },
    );

    test('switching currency re-scopes the totals', () async {
      transactions.seed([
        expenseOf(1000, on: thisMonth),
        expenseOf(2500, currency: Currency.usDollar, on: thisMonth),
      ]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      expect(
        (cubit.state as DashboardReady).summary.expense,
        const Money(1000, Currency.turkishLira),
      );

      cubit.selectCurrency(Currency.usDollar);

      expect(
        (cubit.state as DashboardReady).summary.expense,
        const Money(2500, Currency.usDollar),
      );
    });

    test('surfaces exceeded budgets', () async {
      transactions.seed([
        expenseOf(15000, category: 'food', on: thisMonth),
      ]);
      budgets.seed([budgetOf(10000, category: 'food')]);
      categories.seed([categoryOf('food')]);

      final cubit = build()..start();
      addTearDown(cubit.close);
      await settle();

      final state = cubit.state as DashboardReady;
      expect(state.exceededBudgets, hasLength(1));
      expect(state.budgetStatuses.single.health, BudgetHealth.exceeded);
    });

    test('start is idempotent, so a rebuild cannot double-subscribe', () async {
      final cubit = build()
        ..start()
        ..start();
      addTearDown(cubit.close);
      await settle();

      final emissions = <DashboardState>[];
      final subscription = cubit.stream.listen(emissions.add);
      addTearDown(subscription.cancel);

      await transactions.save(expenseOf(100, on: thisMonth));
      await settle();

      expect(emissions, hasLength(1));
    });
  });
}
