import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_cubit.dart';
import 'package:wallet/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/features/finance/application/history/history_bloc.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/route/app_router.dart';

import 'in_memory_repositories.dart';

/// The fakes behind a booted `App`.
class AppHarness {
  AppHarness._(this.transactions, this.categories, this.budgets, this.settings);

  final FakeTransactionRepository transactions;
  final FakeCategoryRepository categories;
  final FakeBudgetRepository budgets;
  final FakeSettingsRepository settings;

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
  DateTime Function()? clock,
}) async {
  final transactions = FakeTransactionRepository();
  final categories = FakeCategoryRepository();
  final budgets = FakeBudgetRepository();
  final settings = FakeSettingsRepository(theme: theme, currency: currency);
  final now = clock ?? () => DateTime(2026, 7, 15);

  await getIt.reset();
  getIt
    ..registerSingleton<RouteManager>(RouteManager())
    ..registerSingleton<BootstrapPort>(_NoJobs())
    ..registerSingleton<TransactionRepository>(transactions)
    ..registerSingleton<CategoryRepository>(categories)
    ..registerSingleton<BudgetRepository>(budgets)
    ..registerSingleton<SettingsRepository>(settings)
    ..registerFactory<DashboardCubit>(
      () => DashboardCubit(
        transactions,
        categories,
        budgets,
        settings,
        clock: now,
      ),
    )
    ..registerFactory<HistoryBloc>(() => HistoryBloc(transactions, categories))
    ..registerFactory<EntryCubit>(
      () => EntryCubit(transactions, categories, settings),
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

  return AppHarness._(transactions, categories, budgets, settings);
}

/// Bootstrap with nothing to do: the startup jobs are covered in bootstrap_kit.
class _NoJobs implements BootstrapPort {
  @override
  List<BootstrapJob> jobs() => const [];

  @override
  void bootstrapFinished() {}
}
