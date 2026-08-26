import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_bloc.dart';
import 'package:wallet/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/features/finance/application/history/history_bloc.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/onboarding/application/onboarding_cubit.dart';
import 'package:wallet/features/settings/application/review_prompt.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/review_requester.dart';
import 'package:wallet/features/settings/domain/summary_notifier.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/infrastructure/adapter/bootstrap/bootstrap_adapter.dart';
import 'package:wallet/route/app_router.dart';

import 'in_memory_repositories.dart';

/// The fakes behind a booted `App`.
class AppHarness {
  AppHarness._(
    this.transactions,
    this.categories,
    this.budgets,
    this.settings,
    this.notifier,
  );

  final FakeTransactionRepository transactions;
  final FakeCategoryRepository categories;
  final FakeBudgetRepository budgets;
  final FakeSettingsRepository settings;
  final FakeSummaryNotifier notifier;

  Future<void> dispose() async {
    await transactions.dispose();
    await categories.dispose();
    await budgets.dispose();
    await getIt.reset();
  }
}

/// Fills `getIt` with everything `App` resolves, backed by in-memory fakes.
Future<AppHarness> registerAppDependencies({
  ThemePreference theme = ThemePreference.dark,
  Currency currency = Currency.turkishLira,
  bool onboarded = true,
  DateTime Function()? clock,
}) async {
  final transactions = FakeTransactionRepository();
  final categories = FakeCategoryRepository();
  final budgets = FakeBudgetRepository();
  final settings = FakeSettingsRepository(
    theme: theme,
    currency: currency,
    onboarded: onboarded,
  );
  final notifier = FakeSummaryNotifier();
  final reviewRequester = FakeReviewRequester();
  final now = clock ?? () => DateTime(2026, 7, 15);

  await getIt.reset();
  getIt
    ..registerSingleton<RouteManager>(RouteManager())
    ..registerSingleton<BootstrapPort>(_NoJobs())
    ..registerSingleton<TransactionRepository>(transactions)
    ..registerSingleton<CategoryRepository>(categories)
    ..registerSingleton<BudgetRepository>(budgets)
    ..registerSingleton<SettingsRepository>(settings)
    ..registerSingleton<SummaryNotifier>(notifier)
    ..registerSingleton<ReviewRequester>(reviewRequester)
    ..registerFactory<ReviewPrompt>(
      () => ReviewPrompt(settings, reviewRequester, clock: now),
    )
    ..registerSingleton<SummaryReminderController>(
      SummaryReminderController(settings, notifier),
    )
    ..registerFactory<DashboardBloc>(
      () => DashboardBloc(
        transactions,
        categories,
        budgets,
        settings,
        ReviewPrompt(settings, reviewRequester, clock: now),
        clock: now,
      ),
    )
    ..registerFactory<HistoryBloc>(() => HistoryBloc(transactions, categories))
    ..registerFactory<EntryCubit>(
      () => EntryCubit(transactions, categories, settings),
    )
    ..registerFactory<OnboardingCubit>(
      () => OnboardingCubit(categories, settings),
    )
    ..registerFactory<BudgetCubit>(
      () => BudgetCubit(
        budgets,
        transactions,
        categories,
        settings,
        clock: now,
      ),
    );

  return AppHarness._(
    transactions,
    categories,
    budgets,
    settings,
    notifier,
  );
}

/// No jobs to run — those are covered in bootstrap_kit — but the real
/// hand-over, because where startup lands is the adapter's decision and worth
/// exercising through the router that carries it out.
class _NoJobs implements BootstrapPort {
  @override
  List<BootstrapJob> jobs() => const [];

  @override
  void bootstrapFinished() => const BootstrapAdapter().bootstrapFinished();
}
