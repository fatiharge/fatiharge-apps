import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/finance/presentation/views/budget_progress_tile.dart';
import 'package:wallet/features/finance/presentation/views/currency_chips.dart';
import 'package:wallet/features/finance/presentation/views/dashboard_view.dart';
import 'package:wallet/features/finance/presentation/views/summary_header.dart';

import '../../../support/finance_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  const period = MonthPeriod(2026, 7);
  var previousTapped = 0;
  var addTapped = 0;

  setUp(() {
    previousTapped = 0;
    addTapped = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    MonthlySummary? summary,
    List<Currency> available = const [Currency.turkishLira],
    List<BudgetStatus> budgetStatuses = const [],
    Widget? reminderNudge,
  }) => pumpLocalized(
    tester,
    DashboardView(
      period: period,
      currency: Currency.turkishLira,
      availableCurrencies: available,
      summary:
          summary ??
          MonthlySummary.empty(period: period, currency: Currency.turkishLira),
      budgetStatuses: budgetStatuses,
      categories: {'misc': categoryOf('misc', name: 'Diğer')},
      onPreviousMonth: () => previousTapped++,
      onNextMonth: () {},
      onCurrencySelected: (_) {},
      onAddTransaction: () => addTapped++,
      reminderNudge: reminderNudge,
    ),
  );

  MonthlySummary summaryOf(List<dynamic> transactions) => MonthlySummary.from(
    transactions: transactions.cast(),
    period: period,
    currency: Currency.turkishLira,
  );

  group('DashboardView', () {
    testWidgets('an empty month with no data at all says nothing is recorded', (
      tester,
    ) async {
      await pump(tester, available: const []);

      expect(find.text('Henüz kayıt yok'), findsOneWidget);
    });

    testWidgets('an empty month that follows real data words it differently', (
      tester,
    ) async {
      // The distinction _EmptyMonth exists for: "you have never used this app"
      // and "you spent nothing in July" deserve different sentences.
      await pump(tester);

      expect(find.text('Bu ay kayıt yok'), findsOneWidget);
      expect(find.text('Henüz kayıt yok'), findsNothing);
    });

    testWidgets('the empty state offers a way to add the first record', (
      tester,
    ) async {
      await pump(tester, available: const []);

      await tester.tap(find.text('Kayıt ekle'));

      expect(addTapped, 1);
    });

    testWidgets('a single currency draws no currency chips', (tester) async {
      // Chips for a choice of one would be furniture, not a control.
      await pump(tester, summary: summaryOf([expenseOf(1000)]));

      expect(find.byType(CurrencyChips), findsNothing);
    });

    testWidgets('two currencies bring the chips out', (tester) async {
      await pump(
        tester,
        summary: summaryOf([expenseOf(1000)]),
        available: const [Currency.turkishLira, Currency.usDollar],
      );

      expect(find.byType(CurrencyChips), findsOneWidget);
    });

    testWidgets(
      'a month with data shows the totals instead of an empty state',
      (
        tester,
      ) async {
        await pump(
          tester,
          summary: summaryOf([expenseOf(1000), incomeOf(2500)]),
        );

        expect(find.byType(SummaryHeader), findsOneWidget);
        expect(find.text('Bu ay kayıt yok'), findsNothing);
      },
    );

    testWidgets('a budget within its limit raises no alert', (tester) async {
      final statuses = BudgetEvaluator.evaluate(
        budgets: [budgetOf(5000)],
        summary: summaryOf([expenseOf(1000)]),
      );

      await pump(
        tester,
        summary: summaryOf([expenseOf(1000)]),
        budgetStatuses: statuses,
      );

      expect(find.byType(BudgetAlertBanner), findsNothing);
    });

    testWidgets('an exceeded budget raises the alert banner', (tester) async {
      final statuses = BudgetEvaluator.evaluate(
        budgets: [budgetOf(500)],
        summary: summaryOf([expenseOf(1000)]),
      );

      await pump(
        tester,
        summary: summaryOf([expenseOf(1000)]),
        budgetStatuses: statuses,
      );

      expect(find.byType(BudgetAlertBanner), findsOneWidget);
    });

    testWidgets('the month switcher reports a step backwards', (tester) async {
      await pump(tester);

      await tester.tap(find.byIcon(Icons.chevron_left));

      expect(previousTapped, 1);
    });

    testWidgets('draws the reminder offer it is handed', (tester) async {
      // The regression: the parameter existed, was passed in by the page and
      // was never placed in the tree, so the whole nudge — card, counter,
      // dismissal — was unreachable and no test noticed.
      await pump(
        tester,
        summary: summaryOf([expenseOf(1000)]),
        reminderNudge: const Text('offer-here'),
      );

      expect(find.text('offer-here'), findsOneWidget);
    });

    testWidgets('draws nothing where the offer would go when there is none', (
      tester,
    ) async {
      await pump(tester, summary: summaryOf([expenseOf(1000)]));

      expect(find.text('offer-here'), findsNothing);
    });
  });
}
