import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_bloc.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_effect.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_event.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_state.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/review_moment.dart';
import 'package:wallet/features/settings/application/review_prompt.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/in_memory_repositories.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;
  late FakeBudgetRepository budgets;
  late FakeSettingsRepository settings;

  final thisMonth = DateTime(2026, 7, 15);
  DateTime clock() => thisMonth;

  setUp(() {
    transactions = FakeTransactionRepository();
    categories = FakeCategoryRepository();
    budgets = FakeBudgetRepository();
    settings = FakeSettingsRepository();
  });

  tearDown(() async {
    await transactions.dispose();
    await categories.dispose();
    await budgets.dispose();
  });

  DashboardBloc build() => DashboardBloc(
    transactions,
    categories,
    budgets,
    settings,
    ReviewPrompt(settings, FakeReviewRequester(), clock: clock),
    clock: clock,
  );

  /// Lets the repository streams deliver and the bloc drain its event queue.
  Future<void> settle() => pumpEventQueue();

  group('DashboardBloc', () {
    test('starts loading and becomes ready once storage answers', () async {
      final bloc = build();
      addTearDown(bloc.close);

      expect(bloc.state, isA<DashboardLoading>());

      bloc.add(const DashboardStarted());
      await settle();

      expect(bloc.state, isA<DashboardReady>());
    });

    test('totals the current month', () async {
      transactions.seed([
        incomeOf(100000, category: 'salary', on: thisMonth),
        expenseOf(30000, category: 'food', on: thisMonth),
      ]);
      categories.seed([categoryOf('food'), categoryOf('salary')]);

      final bloc = build()..add(const DashboardStarted());
      addTearDown(bloc.close);
      await settle();

      final state = bloc.state as DashboardReady;
      expect(state.summary.income, const Money(100000, Currency.turkishLira));
      expect(state.summary.expense, const Money(30000, Currency.turkishLira));
      expect(state.hasData, isTrue);
    });

    test('recomputes when a transaction is added afterwards', () async {
      final bloc = build()..add(const DashboardStarted());
      addTearDown(bloc.close);
      await settle();

      expect((bloc.state as DashboardReady).hasData, isFalse);

      await transactions.save(expenseOf(5000, on: thisMonth));
      await settle();

      expect(
        (bloc.state as DashboardReady).summary.expense,
        const Money(5000, Currency.turkishLira),
      );
    });

    test('changing the month changes what is counted', () async {
      final lastMonth = MonthPeriod.of(thisMonth).previous;
      transactions.seed([
        expenseOf(1000, on: thisMonth),
        expenseOf(9000, on: lastMonth.start),
      ]);

      final bloc = build()..add(const DashboardStarted());
      addTearDown(bloc.close);
      await settle();

      expect(
        (bloc.state as DashboardReady).summary.expense,
        const Money(1000, Currency.turkishLira),
      );

      bloc.add(const DashboardPreviousMonthRequested());
      await settle();

      final state = bloc.state as DashboardReady;
      expect(state.period, lastMonth);
      expect(state.summary.expense, const Money(9000, Currency.turkishLira));
    });

    test(
      'lists only the currencies in use and defaults to the first',
      () async {
        transactions.seed([
          expenseOf(1000, currency: Currency.usDollar, on: thisMonth),
        ]);

        final bloc = build()..add(const DashboardStarted());
        addTearDown(bloc.close);
        await settle();

        final state = bloc.state as DashboardReady;
        expect(state.availableCurrencies, [Currency.usDollar]);
        expect(state.currency, Currency.usDollar);
      },
    );

    test('switching currency re-scopes the totals', () async {
      transactions.seed([
        expenseOf(1000, on: thisMonth),
        expenseOf(2500, currency: Currency.usDollar, on: thisMonth),
      ]);

      final bloc = build()..add(const DashboardStarted());
      addTearDown(bloc.close);
      await settle();

      expect(
        (bloc.state as DashboardReady).summary.expense,
        const Money(1000, Currency.turkishLira),
      );

      bloc.add(const DashboardCurrencySelected(Currency.usDollar));
      await settle();

      expect(
        (bloc.state as DashboardReady).summary.expense,
        const Money(2500, Currency.usDollar),
      );
    });

    test('surfaces exceeded budgets', () async {
      transactions.seed([
        expenseOf(15000, category: 'food', on: thisMonth),
      ]);
      budgets.seed([budgetOf(10000, category: 'food')]);
      categories.seed([categoryOf('food')]);

      final bloc = build()..add(const DashboardStarted());
      addTearDown(bloc.close);
      await settle();

      final state = bloc.state as DashboardReady;
      expect(state.exceededBudgets, hasLength(1));
      expect(state.budgetStatuses.single.health, BudgetHealth.exceeded);
    });

    test('refuses to browse past the current month', () async {
      final bloc = build();
      addTearDown(bloc.close);
      bloc.add(const DashboardStarted());
      await settle();

      bloc.add(const DashboardNextMonthRequested());
      await settle();

      final state = bloc.state as DashboardReady;
      expect(state.period, MonthPeriod.of(thisMonth));
      expect(state.canShowNextMonth, isFalse);
    });

    test('allows browsing forward once it is behind', () async {
      final bloc = build();
      addTearDown(bloc.close);
      bloc.add(const DashboardStarted());
      await settle();

      bloc.add(const DashboardPreviousMonthRequested());
      await settle();
      expect((bloc.state as DashboardReady).canShowNextMonth, isTrue);

      bloc.add(const DashboardNextMonthRequested());
      await settle();
      expect(
        (bloc.state as DashboardReady).period,
        MonthPeriod.of(thisMonth),
      );
    });

    test('starting twice cannot double-subscribe', () async {
      final bloc = build()
        ..add(const DashboardStarted())
        ..add(const DashboardStarted());
      addTearDown(bloc.close);
      await settle();

      final emissions = <DashboardState>[];
      final subscription = bloc.stream.listen(emissions.add);
      addTearDown(subscription.cancel);

      await transactions.save(expenseOf(100, on: thisMonth));
      await settle();

      expect(emissions, hasLength(1));
    });

    group('review moment', () {
      /// Enough records, old enough install: everything but the month on
      /// screen, which each test supplies.
      void qualify() {
        settings.installed = thisMonth.subtract(ReviewMoment.minimumAge);
        transactions.seed([
          for (var i = 0; i < ReviewMoment.minimumTransactions; i++)
            expenseOf(1000, on: thisMonth, id: 'e$i'),
        ]);
      }

      test('is announced once, not on every recompute', () async {
        qualify();

        final bloc = build()..add(const DashboardStarted());
        addTearDown(bloc.close);

        final effects = <DashboardEffect>[];
        final subscription = bloc.effects.listen(effects.add);
        addTearDown(subscription.cancel);

        await settle();

        expect(effects.single, isA<DashboardReviewMomentReached>());

        // Another transaction is another recompute, not another moment. This
        // is the whole reason it is an effect: state would re-announce it.
        await transactions.save(expenseOf(500, on: thisMonth, id: 'later'));
        await settle();

        expect(effects, hasLength(1));
      });

      test('is withheld while the month on screen is empty', () async {
        settings.installed = thisMonth.subtract(ReviewMoment.minimumAge);

        final bloc = build()..add(const DashboardStarted());
        addTearDown(bloc.close);

        final effects = <DashboardEffect>[];
        final subscription = bloc.effects.listen(effects.add);
        addTearDown(subscription.cancel);

        await settle();

        expect(effects, isEmpty);
      });
    });
  });
}
