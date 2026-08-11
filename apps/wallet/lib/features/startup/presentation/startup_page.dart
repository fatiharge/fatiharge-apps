import 'package:auto_route/auto_route.dart';
import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/config/env.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/startup/presentation/splash_view.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// The first route: runs the startup jobs and hands over to the main tabs.
///
/// All of the orchestration lives in `bootstrap_kit`; this page only supplies
/// the port and the localized failure screen.
@RoutePage()
class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) => BootstrapPage(
    port: getIt<BootstrapPort>(),
    splash: const SplashView(),
    errorBuilder: (context, state, onRetry) =>
        _StartupError(state: state, onRetry: onRetry),
  );
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.state, this.onRetry});

  final BootstrapFailed state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                context.tr(LocaleKeys.startup_failed_title),
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                onRetry != null
                    ? context.tr(LocaleKeys.startup_failed_retryable)
                    : context.tr(LocaleKeys.startup_failed_fatal),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              // Which job failed, for whoever is holding the device. Users get
              // nothing useful out of a job name and an exception, but a
              // tester on a build with no debugger attached gets everything
              // they need for an exact report. Off in release by default.
              if (Env.debugLogs) ...[
                const SizedBox(height: 12),
                Text(
                  '${state.jobName}: ${state.error}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              if (onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr(LocaleKeys.common_retry)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
