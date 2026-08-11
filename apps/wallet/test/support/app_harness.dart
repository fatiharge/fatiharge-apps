import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_cubit.dart';
import 'package:wallet/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/features/finance/application/history/history_bloc.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/route/app_router.dart';

import 'in_memory_repositories.dart';

/// The fakes behind a booted `App`.
class AppHarness {
  AppHarness._(this.transactions, this.categories, this.budgets);

  final FakeTransactionRepository transactions;
  final FakeCategoryRepository categories;
  final FakeBudgetRepository budgets;

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
  DateTime Function()? clock,
}) async {
  final transactions = FakeTransactionRepository();
  final categories = FakeCategoryRepository();
  final budgets = FakeBudgetRepository();
  final now = clock ?? () => DateTime(2026, 7, 15);

  await getIt.reset();
  getIt
    ..registerSingleton<RouteManager>(RouteManager())
    ..registerSingleton<BootstrapPort>(_NoJobs())
    ..registerSingleton<TransactionRepository>(transactions)
    ..registerSingleton<CategoryRepository>(categories)
    ..registerSingleton<BudgetRepository>(budgets)
    ..registerSingleton<SettingsRepository>(_StubSettings(theme))
    ..registerFactory<DashboardCubit>(
      () => DashboardCubit(transactions, categories, budgets, clock: now),
    )
    ..registerFactory<HistoryBloc>(() => HistoryBloc(transactions, categories))
    ..registerFactory<EntryCubit>(() => EntryCubit(transactions, categories))
    ..registerFactory<BudgetCubit>(
      () => BudgetCubit(budgets, transactions, categories, clock: now),
    );

  return AppHarness._(transactions, categories, budgets);
}

/// Bootstrap with nothing to do: the startup jobs are covered in bootstrap_kit.
class _NoJobs implements BootstrapPort {
  @override
  List<BootstrapJob> jobs() => const [];

  @override
  void bootstrapFinished() {}
}

class _StubSettings implements SettingsRepository {
  _StubSettings(this._theme);

  ThemePreference _theme;

  @override
  ThemePreference readTheme() => _theme;

  @override
  Future<void> writeTheme(ThemePreference preference) async =>
      _theme = preference;
}
