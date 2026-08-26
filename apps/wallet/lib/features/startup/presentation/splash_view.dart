import 'package:flutter/material.dart';
import 'package:wallet/theme/app_mark.dart';

/// Passed to `BootstrapPage` by `StartupPage`. It lives here, next to the
/// failure view, rather than inside the bootstrap adapter: the adapter belongs
/// to `infrastructure/` and has no business building widgets.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppMark(size: 88),
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
