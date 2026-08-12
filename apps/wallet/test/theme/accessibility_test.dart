import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/finance/presentation/views/category_editor_sheet.dart';
import 'package:wallet/features/finance/presentation/views/category_view.dart';
import 'package:wallet/features/finance/presentation/views/dashboard_view.dart';
import 'package:wallet/features/finance/presentation/views/history_view.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';
import 'package:wallet/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

import '../support/finance_fixtures.dart';
import '../support/in_memory_repositories.dart';
import '../support/widget_harness.dart';

/// The checks Play's pre-launch report runs on every build, brought forward.
///
/// Google's Accessibility Scanner reports tap target size and missing labels
/// on anything uploaded to a testing track, so these findings arrive either
/// way — here, or in the Play Console after the fact. Flutter ships the same
/// guidelines as matchers, so they cost a test rather than a release cycle.
void main() {
  late FakeSettingsRepository settings;

  setUp(() async {
    settings = FakeSettingsRepository();
    await getIt.reset();
    getIt
      ..registerSingleton<SettingsRepository>(settings)
      ..registerSingleton<SummaryReminderController>(
        SummaryReminderController(settings, FakeSummaryNotifier()),
      );
  });

  tearDown(getIt.reset);

  const period = MonthPeriod(2026, 7);
  final food = categoryOf('food', name: 'Yemek');
  final transport = categoryOf('transport', name: 'Ulaşım');

  Future<void> check(WidgetTester tester, Widget view) async {
    useTallSurface(tester);
    final handle = tester.ensureSemantics();
    await pumpLocalized(tester, view);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  }

  testWidgets('history rows', (tester) async {
    await check(
      tester,
      HistoryView(
        transactions: [expenseOf(2500, category: 'food')],
        categories: {food.id: food},
        isFiltered: false,
        onClearFilter: () {},
        onEdit: (_) {},
        onDelete: (_) {},
      ),
    );
  });

  testWidgets('dashboard', (tester) async {
    final summary = MonthlySummary.from(
      transactions: [
        expenseOf(45000, category: 'food'),
        incomeOf(650000),
      ],
      period: period,
      currency: Currency.turkishLira,
    );

    await check(
      tester,
      DashboardView(
        period: period,
        currency: Currency.turkishLira,
        availableCurrencies: const [Currency.turkishLira, Currency.euro],
        summary: summary,
        budgetStatuses: BudgetEvaluator.evaluate(
          budgets: [budgetOf(100000, category: 'food')],
          summary: summary,
        ),
        categories: {food.id: food, transport.id: transport},
        onPreviousMonth: () {},
        onNextMonth: () {},
        onCurrencySelected: (_) {},
        onAddTransaction: () {},
      ),
    );
  });

  testWidgets('category list', (tester) async {
    await check(
      tester,
      CategoryView(
        active: [food],
        archived: [categoryOf('old', name: 'Eski')],
        onAdd: () {},
        onArchive: (_) {},
        onRestore: (_) {},
      ),
    );
  });

  testWidgets('category editor', (tester) async {
    await check(tester, const CategoryEditorSheet());
  });

  testWidgets('onboarding steps', (tester) async {
    for (final step in OnboardingStep.values) {
      await check(
        tester,
        BlocProvider(
          create: (_) => SettingsCubit(settings),
          child: OnboardingView(
            state: OnboardingState(
              step: step,
              categories: [food, transport],
              keptCategoryIds: const {'food', 'transport'},
            ),
            onNext: () {},
            onBack: () {},
            onSkip: () {},
            onFinish: () {},
            onToggleCategory: (_, {required keep}) {},
          ),
        ),
      );
    }
  });
}
