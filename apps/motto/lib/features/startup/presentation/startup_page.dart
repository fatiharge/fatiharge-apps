import 'package:auto_route/auto_route.dart';
import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/theme/motto_loading.dart';

/// The first route, and the only place the container is built.
///
/// Everything downstream resolves out of get_it, so this page cannot be skipped
/// — a route that renders before it finds an empty container, which is exactly
/// what happened the first time this ran on a phone.
@RoutePage()
class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) => BootstrapPage(
    port: getIt<BootstrapPort>(),
    splash: const _Splash(),
    errorBuilder: (context, state, onRetry) => _StartupError(onRetry: onRetry),
  );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(body: MottoLoading());
}

class _StartupError extends StatelessWidget {
  const _StartupError({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'startup.failed'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (onRetry != null)
                FilledButton(
                  onPressed: onRetry,
                  child: Text('startup.retry'.tr()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
