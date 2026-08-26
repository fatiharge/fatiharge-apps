import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/about/domain/app_version_port.dart';
import 'package:wallet/features/finance/application/budget/budget_cubit.dart';
import 'package:wallet/features/finance/application/category/category_cubit.dart';
import 'package:wallet/features/finance/application/dashboard/dashboard_bloc.dart';
import 'package:wallet/features/finance/application/entry/entry_cubit.dart';
import 'package:wallet/features/finance/application/history/history_bloc.dart';
import 'package:wallet/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/features/onboarding/application/onboarding_cubit.dart';
import 'package:wallet/features/settings/application/review_prompt.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/review_requester.dart';
import 'package:wallet/features/settings/domain/summary_notifier.dart';
import 'package:wallet/infrastructure/storage/wallet_storage.dart';

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

  /// Every type the generated container registers, resolved for real. Kept
  /// honest by the test below rather than by whoever remembers to add a line.
  const resolved = <String>{
    'WalletStorage',
    'AppVersionPort',
    'TransactionRepository',
    'CategoryRepository',
    'BudgetRepository',
    'SummaryNotifier',
    'ReviewRequester',
    'ReviewPrompt',
    'SummaryReminderController',
    'DashboardBloc',
    'BudgetCubit',
    'EntryCubit',
    'HistoryBloc',
    'CategoryCubit',
    'OnboardingCubit',
  };

  test('every registered type actually resolves', () {
    expect(getIt<TransactionRepository>(), isNotNull);
    expect(getIt<CategoryRepository>(), isNotNull);
    expect(getIt<BudgetRepository>(), isNotNull);
    expect(getIt<WalletStorage>(), isNotNull);
    expect(getIt<AppVersionPort>(), isNotNull);

    expect(getIt<SummaryNotifier>(), isNotNull);
    expect(getIt<ReviewRequester>(), isNotNull);
    expect(getIt<ReviewPrompt>(), isNotNull);
    expect(getIt<SummaryReminderController>(), isNotNull);

    expect(getIt<DashboardBloc>(), isNotNull);
    expect(getIt<BudgetCubit>(), isNotNull);
    expect(getIt<EntryCubit>(), isNotNull);
    expect(getIt<HistoryBloc>(), isNotNull);
    expect(getIt<CategoryCubit>(), isNotNull);
    expect(getIt<OnboardingCubit>(), isNotNull);
  });

  test('the list above is not allowed to fall behind the container', () {
    // The regression this closes: `SummaryNotifier` depended on a type nothing
    // registered, and the test that claims to resolve "every registered type"
    // simply did not name it. A hand-kept list quietly stops being a list of
    // everything, so the generated file gets to say what belongs on it.
    final generated = File(
      'lib/config/injectable.config.dart',
    ).readAsStringSync();

    final registered = RegExp(
      r'gh\.(?:factory|singleton|lazySingleton|singletonAsync|factoryAsync)'
      r'<_i\d+\.(\w+)>',
    ).allMatches(generated).map((match) => match.group(1)!).toSet();

    expect(
      registered.difference(resolved),
      isEmpty,
      reason:
          'injectable registers these but nothing above resolves them — add '
          'them to the test, do not delete them from this check',
    );
  });

  test('state holders get the real clock, not one from the container', () {
    // The regression: an optional default must stay a default. If injectable
    // ever tries to inject it again, resolving throws instead of failing here.
    final bloc = getIt<DashboardBloc>();

    expect(bloc.clock, isNotNull);
    expect(bloc.clock(), isA<DateTime>());
  });

  test('repositories are shared, state holders are not', () {
    expect(
      identical(getIt<TransactionRepository>(), getIt<TransactionRepository>()),
      isTrue,
    );
    expect(
      identical(getIt<DashboardBloc>(), getIt<DashboardBloc>()),
      isFalse,
    );
  });
}
