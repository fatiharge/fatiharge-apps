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

class BootstrapAdapter implements BootstrapPort {
  const BootstrapAdapter();

  @override
  List<BootstrapJob> jobs() => [
    // Nothing reads or writes before this, and a failure is unrecoverable.
    BootstrapJob(
      'storage',
      Hive.initFlutter,
      retries: 1,
      errorPolicy: BootstrapErrorPolicy.restart,
    ),

    const BootstrapJob(
      'dependencies',
      configureDependencies,
      errorPolicy: BootstrapErrorPolicy.restart,
    ),

    // A failure costs the starter categories, not the app.
    BootstrapJob(
      'seed_categories',
      _seedCategories,
      retries: 1,
      errorPolicy: BootstrapErrorPolicy.skip,
    ),

    // The review prompt measures age from this stamp.
    BootstrapJob(
      'first_launch',
      () => getIt<ReviewPrompt>().start(),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),

    // Pushes the fixed reminder window forward, and notices a permission
    // revoked in system settings.
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

  /// Checked here rather than in the router: this is the only place that
  /// knows storage is open.
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
