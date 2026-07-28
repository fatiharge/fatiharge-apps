@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/finance/presentation/format/money_format.dart';
import 'package:wallet/features/finance/presentation/views/budget_progress_tile.dart';
import 'package:wallet/features/finance/presentation/views/summary_header.dart';
import 'package:wallet/features/finance/presentation/views/transaction_tile.dart';
import 'package:wallet/theme/app_mark.dart';

import '../support/finance_fixtures.dart';
import '../support/widget_harness.dart';

/// Pixel baselines for the widgets whose whole job is how they look.
///
/// Tagged so `melos run test` skips them: goldens are rendered by the host, so
/// a baseline written on macOS does not match one rendered on CI's Linux. Run
/// `melos run test:golden` on the machine that owns the baselines.
///
/// flutter_test loads no real fonts, so text renders as filled boxes. These
/// are layout baselines, not typography ones — which is enough: the first run
/// caught a Row overflowing by 69px at 360dp.
void main() {
  const period = MonthPeriod(2026, 7);

  Future<void> frame(WidgetTester tester, Widget child) => pumpLocalized(
    tester,
    Center(child: SizedBox(width: 360, child: child)),
  );

  testWidgets('SummaryHeader', (tester) async {
    final summary = MonthlySummary.from(
      transactions: [expenseOf(45000), incomeOf(650000)],
      period: period,
      currency: Currency.turkishLira,
    );

    await frame(
      tester,
      SummaryHeader(
        income: summary.income,
        expense: summary.expense,
        net: summary.net,
      ),
    );

    await expectLater(
      find.byType(SummaryHeader),
      matchesGoldenFile('goldens/summary_header.png'),
    );
  });

  testWidgets('BudgetProgressTile within its limit', (tester) async {
    final statuses = BudgetEvaluator.evaluate(
      budgets: [budgetOf(100000, category: 'food')],
      summary: MonthlySummary.from(
        transactions: [expenseOf(45000, category: 'food')],
        period: period,
        currency: Currency.turkishLira,
      ),
    );

    await frame(
      tester,
      BudgetProgressTile(
        status: statuses.single,
        category: categoryOf('food', name: 'Yemek'),
      ),
    );

    await expectLater(
      find.byType(BudgetProgressTile),
      matchesGoldenFile('goldens/budget_progress_within.png'),
    );
  });

  testWidgets('BudgetProgressTile exceeded', (tester) async {
    final statuses = BudgetEvaluator.evaluate(
      budgets: [budgetOf(30000, category: 'food')],
      summary: MonthlySummary.from(
        transactions: [expenseOf(45000, category: 'food')],
        period: period,
        currency: Currency.turkishLira,
      ),
    );

    await frame(
      tester,
      BudgetProgressTile(
        status: statuses.single,
        category: categoryOf('food', name: 'Yemek'),
      ),
    );

    await expectLater(
      find.byType(BudgetProgressTile),
      matchesGoldenFile('goldens/budget_progress_exceeded.png'),
    );
  });

  testWidgets('TransactionTile', (tester) async {
    await frame(
      tester,
      TransactionTile(
        transaction: expenseOf(
          12550,
          category: 'food',
          note: 'Öğle yemeği',
        ),
        category: categoryOf('food', name: 'Yemek'),
      ),
    );

    await expectLater(
      find.byType(TransactionTile),
      matchesGoldenFile('goldens/transaction_tile.png'),
    );
  });

  testWidgets('AppMark', (tester) async {
    await frame(tester, const Center(child: AppMark(size: 96)));

    await expectLater(
      find.byType(AppMark),
      matchesGoldenFile('goldens/app_mark.png'),
    );
  });

  testWidgets('Money formatting stays Turkish', (tester) async {
    // Not a picture of a widget so much as a guard on the locale the goldens
    // above were rendered in.
    await frame(
      tester,
      Builder(
        builder: (context) => Text(
          const Money(123456, Currency.turkishLira).format(context),
        ),
      ),
    );

    expect(find.textContaining('1.234,56'), findsOneWidget);
  });
}
