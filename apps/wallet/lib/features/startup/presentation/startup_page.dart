import 'package:auto_route/auto_route.dart';
import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/infrastructure/adapter/bootstrap/bootstrap_adapter.dart';

/// The first route: runs the startup jobs and hands over to the main tabs.
///
/// All of the orchestration lives in `bootstrap_kit`; this page only supplies
/// the port and the localized failure screen.
@RoutePage()
class StartupPage extends StatelessWidget {
  StartupPage({super.key});

  final BootstrapAdapter _adapter = BootstrapAdapter();

  @override
  Widget build(BuildContext context) => BootstrapPage(
    port: _adapter,
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
                LocaleKeys.startup_failed_title.tr(),
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                onRetry != null
                    ? LocaleKeys.startup_failed_retryable.tr()
                    : LocaleKeys.startup_failed_fatal.tr(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(LocaleKeys.common_retry.tr()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
