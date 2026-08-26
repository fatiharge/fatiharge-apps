import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:wallet/config/env.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/default_categories.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/settings/application/review_prompt.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/infrastructure/dev/demo_transactions.dart';
import 'package:wallet/route/app_router.dart';
import 'package:wallet/route/app_router.gr.dart';

/// The app's half of the bootstrap contract: what to run at startup, what to
/// show while it runs, and where to go once it is done.
class BootstrapAdapter implements BootstrapPort {
  const BootstrapAdapter();

  @override
  List<BootstrapJob> jobs() => [
    // Nothing can be read or written before this; a failure is unrecoverable.
    BootstrapJob(
      'storage',
      Hive.initFlutter,
      retries: 1,
      errorPolicy: BootstrapErrorPolicy.restart,
    ),

    // Opens the boxes (@preResolve) and registers the repositories.
    const BootstrapJob(
      'dependencies',
      configureDependencies,
      errorPolicy: BootstrapErrorPolicy.restart,
    ),

    // First launch only. If it fails the app still works — the user just has
    // no starter categories — so it must not block startup.
    BootstrapJob(
      'seed_categories',
      _seedCategories,
      retries: 1,
      errorPolicy: BootstrapErrorPolicy.skip,
    ),

    // Stamps the install date the first time it runs. The review prompt
    // measures age from it, so without this it never reaches a moment worth
    // asking at.
    BootstrapJob(
      'first_launch',
      () => getIt<ReviewPrompt>().start(),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),

    // Only a fixed number of reminders are scheduled at a time, so the window
    // has to be pushed forward on launch — which is also where a permission
    // revoked in system settings is noticed. Costs a reminder if it fails,
    // not the app.
    BootstrapJob(
      'reminder_window',
      () => getIt<SummaryReminderController>().refresh(),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),

    if (Env.seedDemoData)
      BootstrapJob(
        'demo_data',
        _seedDemoData,
        errorPolicy: BootstrapErrorPolicy.skip,
      ),
  ];

  /// Straight to the tabs once the first-run flow has been through — checked
  /// here rather than in the router because this is the only place that knows
  /// storage is open.
  @override
  void bootstrapFinished() => getIt<RouteManager>().replaceAll([
    if (getIt<SettingsRepository>().isOnboarded())
      const MainRoute()
    else
      const OnboardingRoute(),
  ]);

  Future<void> _seedCategories() async {
    final repository = getIt<CategoryRepository>();
    if ((await repository.fetchAll()).isNotEmpty) return;

    for (final category in defaultCategories()) {
      await repository.save(category);
    }
  }

  Future<void> _seedDemoData() => seedDemoTransactions(getIt());
}
