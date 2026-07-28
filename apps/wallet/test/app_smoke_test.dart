import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app.dart';
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
import 'package:wallet/route/app_router.gr.dart';
import 'package:wallet/theme/app_mark.dart';

import 'support/finance_fixtures.dart';
import 'support/in_memory_repositories.dart';
import 'support/widget_harness.dart';

/// Proves the app boots: DI, router, theme and the first screen, wired
/// together. Everything below `App` was covered in isolation and nothing
/// checked that the pieces fit.
void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;
  late FakeBudgetRepository budgets;

  setUp(() async {
    transactions = FakeTransactionRepository();
    categories = FakeCategoryRepository()
      ..seed([categoryOf('misc', name: 'Diğer')]);
    budgets = FakeBudgetRepository();

    await getIt.reset();
    getIt
      ..registerSingleton<RouteManager>(RouteManager())
      ..registerSingleton<BootstrapPort>(_NoJobs())
      ..registerSingleton<TransactionRepository>(transactions)
      ..registerSingleton<CategoryRepository>(categories)
      ..registerSingleton<BudgetRepository>(budgets)
      ..registerSingleton<SettingsRepository>(
        _StubSettings(ThemePreference.dark),
      )
      ..registerFactory<DashboardCubit>(
        () => DashboardCubit(
          transactions,
          categories,
          budgets,
          clock: () => DateTime(2026, 7, 15),
        ),
      )
      ..registerFactory<HistoryBloc>(
        () => HistoryBloc(transactions, categories),
      )
      ..registerFactory<EntryCubit>(() => EntryCubit(transactions, categories))
      ..registerFactory<BudgetCubit>(
        () => BudgetCubit(
          budgets,
          transactions,
          categories,
          clock: () => DateTime(2026, 7, 15),
        ),
      );
  });

  tearDown(() async {
    await transactions.dispose();
    await categories.dispose();
    await budgets.dispose();
    await getIt.reset();
  });

  testWidgets('boots to the dashboard without throwing', (tester) async {
    await pumpApp(tester, const App());
    await tester.pump(const Duration(seconds: 3));

    // The router starts on StartupPage; this navigates the way
    // BootstrapAdapter does once its jobs finish.
    await getIt<RouteManager>().replaceAll([const MainRoute()]);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Geçmiş'), findsOneWidget);
    expect(find.text('Bütçe'), findsOneWidget);
  });

  testWidgets('every tab opens, and so does the entry sheet', (tester) async {
    await pumpApp(tester, const App());
    await tester.pump(const Duration(seconds: 3));
    await getIt<RouteManager>().replaceAll([const MainRoute()]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Geçmiş'));
    await tester.pumpAndSettle();
    expect(find.text('Geçmiş boş'), findsOneWidget);

    await tester.tap(find.text('Bütçe'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz bütçe yok'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('applies the stored theme rather than the system one', (
    tester,
  ) async {
    await pumpApp(tester, const App());
    // bootstrap_kit pads the splash to a minimum duration; let that timer run.
    await tester.pump(const Duration(seconds: 3));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('the splash shows the app mark while startup runs', (
    tester,
  ) async {
    await pumpApp(tester, const App());
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(AppMark), findsOneWidget);
  });
}

/// Bootstrap with nothing to do: the smoke test is about the shell, not the
/// startup jobs, which have their own tests in bootstrap_kit.
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
