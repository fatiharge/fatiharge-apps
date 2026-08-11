import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_cubit.dart';
import 'package:wallet/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/features/finance/application/history/history_bloc.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';

import '../support/in_memory_repositories.dart';

/// Runs the generated container for real.
///
/// Every other test builds its subjects by hand, so `injectable.config.dart`
/// was never executed and a bad registration shipped: the clock default was
/// turned into `gh<Clock>()`, which threw on first resolve and no test noticed.
void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wallet_di_test');
    Hive.init(directory.path);

    // Mirrors main.dart: the cubits read the currency preference, and its
    // repository is registered by hand before the container is built — it has
    // to be loaded before the first frame, which a generated async
    // registration cannot promise.
    getIt.registerSingleton<SettingsRepository>(FakeSettingsRepository());

    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.deleteFromDisk();
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  test('every registered type actually resolves', () {
    expect(getIt<TransactionRepository>(), isNotNull);
    expect(getIt<CategoryRepository>(), isNotNull);
    expect(getIt<BudgetRepository>(), isNotNull);

    expect(getIt<DashboardCubit>(), isNotNull);
    expect(getIt<BudgetCubit>(), isNotNull);
    expect(getIt<EntryCubit>(), isNotNull);
    expect(getIt<HistoryBloc>(), isNotNull);
  });

  test('cubits get the real clock, not one from the container', () {
    // The regression: an optional default must stay a default. If injectable
    // ever tries to inject it again, resolving throws instead of failing here.
    final cubit = getIt<DashboardCubit>();

    expect(cubit.clock, isNotNull);
    expect(cubit.clock(), isA<DateTime>());
  });

  test('repositories are shared, cubits are not', () {
    expect(
      identical(getIt<TransactionRepository>(), getIt<TransactionRepository>()),
      isTrue,
    );
    expect(
      identical(getIt<DashboardCubit>(), getIt<DashboardCubit>()),
      isFalse,
    );
  });
}
