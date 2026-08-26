import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/about/domain/app_version_port.dart';
import 'package:wallet/features/about/presentation/page/about_page.dart';
import 'package:wallet/features/finance/application/budget/budget_state.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/features/finance/domain/rules/budget_evaluator.dart';
import 'package:wallet/features/finance/domain/rules/month_period.dart';
import 'package:wallet/features/finance/domain/rules/monthly_summary.dart';
import 'package:wallet/features/finance/domain/rules/transaction_filter.dart';
import 'package:wallet/features/finance/presentation/views/budget_editor_sheet.dart';
import 'package:wallet/features/finance/presentation/views/budget_view.dart';
import 'package:wallet/features/finance/presentation/views/category_editor_sheet.dart';
import 'package:wallet/features/finance/presentation/views/category_view.dart';
import 'package:wallet/features/finance/presentation/views/dashboard_view.dart';
import 'package:wallet/features/finance/presentation/views/history_filter_sheet.dart';
import 'package:wallet/features/finance/presentation/views/history_view.dart';
import 'package:wallet/features/finance/presentation/views/transaction_entry_view.dart';
import 'package:wallet/features/onboarding/application/onboarding_state.dart';
import 'package:wallet/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/presentation/page/settings_page.dart';

import '../support/finance_fixtures.dart';
import '../support/in_memory_repositories.dart';
import '../support/widget_harness.dart';

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
      ..registerSingleton<AppVersionPort>(_StubVersion())
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

  testWidgets('budget list', (tester) async {
    final summary = MonthlySummary.from(
      transactions: [expenseOf(120000, category: 'food')],
      period: period,
      currency: Currency.turkishLira,
    );

    await check(
      tester,
      BudgetView(
        statuses: BudgetEvaluator.evaluate(
          budgets: [budgetOf(100000, category: 'food')],
          summary: summary,
        ),
        categories: {food.id: food},
        onAdd: () {},
        onEdit: (_) {},
        onDelete: (_) {},
      ),
    );
  });

  testWidgets('budget editor', (tester) async {
    await check(
      tester,
      BudgetEditorSheet(
        state: BudgetState(
          period: period,
          categories: {food.id: food, transport.id: transport},
          loading: false,
        ),
      ),
    );
  });

  testWidgets('history filter', (tester) async {
    await check(
      tester,
      HistoryFilterSheet(
        filter: const TransactionFilter(),
        categories: [food, transport],
      ),
    );
  });

  testWidgets('transaction entry', (tester) async {
    final amount = TextEditingController(text: '125');
    final note = TextEditingController();
    addTearDown(amount.dispose);
    addTearDown(note.dispose);

    await check(
      tester,
      TransactionEntryView(
        amountController: amount,
        noteController: note,
        isEditing: false,
        type: TransactionType.expense,
        currency: Currency.turkishLira,
        date: DateTime(2026, 7, 15),
        categories: [food, transport],
        selectedCategoryId: food.id,
        submitting: false,
        onTypeChanged: (_) {},
        onAmountChanged: (_) {},
        onCurrencyChanged: (_) {},
        onCategorySelected: (_) {},
        onDateSelected: (_) {},
        onNoteChanged: (_) {},
        onSubmit: () {},
      ),
    );
  });

  testWidgets('settings', (tester) async {
    await check(
      tester,
      BlocProvider(
        create: (_) => SettingsCubit(settings),
        child: const SettingsPage(),
      ),
    );
  });

  testWidgets('about', (tester) async {
    await check(tester, const AboutPage());
  });
}

class _StubVersion implements AppVersionPort {
  @override
  Future<AppVersion> read() async =>
      const AppVersion(name: '0.3.1', build: '7');
}
