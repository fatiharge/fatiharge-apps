import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:wallet/config/env.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/infrastructure/seed/default_categories.dart';
import 'package:wallet/infrastructure/seed/demo_transactions.dart';
import 'package:wallet/route/app_router.dart';
import 'package:wallet/route/app_router.gr.dart';

/// The app's half of the bootstrap contract: what to run at startup, what to
/// show while it runs, and where to go once it is done.
class BootstrapAdapter implements BootstrapPort {
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

    if (Env.seedDemoData)
      BootstrapJob(
        'demo_data',
        _seedDemoData,
        errorPolicy: BootstrapErrorPolicy.skip,
      ),
  ];

  @override
  Widget get bootstrapView => const _SplashView();

  @override
  void bootstrapFinished() => getIt<RouteManager>().replaceAll([
    const MainRoute(),
  ]);

  Future<void> _seedCategories() async {
    final repository = getIt<CategoryRepository>();
    if ((await repository.fetchAll()).isNotEmpty) return;

    for (final category in defaultCategories((key) => key.tr())) {
      await repository.save(category);
    }
  }

  Future<void> _seedDemoData() => seedDemoTransactions(getIt());
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
