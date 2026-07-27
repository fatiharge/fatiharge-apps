import 'dart:async';

import 'package:bootstrap_kit/src/application/bootstrap_cubit.dart';
import 'package:bootstrap_kit/src/application/bootstrap_state.dart';
import 'package:bootstrap_kit/src/domain/bootstrap_port.dart';
import 'package:flutter/material.dart';

/// Signature for rendering the running (splash) state with live progress.
typedef BootstrapRunningBuilder =
    Widget Function(BuildContext context, BootstrapRunning state);

/// Signature for rendering a failed bootstrap.
///
/// [onRetry] is `null` when the failure is unrecoverable
/// ([BootstrapFailed.canRetry] is `false`) — the app has to be restarted.
typedef BootstrapErrorBuilder =
    Widget Function(
      BuildContext context,
      BootstrapFailed state,
      VoidCallback? onRetry,
    );

/// Drives a [BootstrapPort] to completion and shows the right view for each
/// phase.
///
/// Owns the [BootstrapCubit] (creates, starts and closes it), so the app
/// supplies the port and the view to show while it runs:
///
/// ```dart
/// MaterialApp(
///   home: BootstrapPage(port: BootstrapAdapter(), splash: const SplashView()),
/// );
/// ```
///
/// Use [BootstrapPage.withProgress] instead when the splash should react to
/// how far along the jobs are.
///
/// The splash is a parameter rather than something the port provides, so that
/// [BootstrapPort] can stay free of Flutter and the app can keep its startup
/// UI in the presentation layer.
///
/// Deliberately built on a plain [StreamBuilder] rather than `flutter_bloc`:
/// startup is the one screen that must not depend on the app's state
/// management choice.
class BootstrapPage extends StatefulWidget {
  /// Shows [splash] unchanged for the whole run.
  const BootstrapPage({
    required this.port,
    required this.splash,
    this.errorBuilder,
    super.key,
  }) : runningBuilder = null;

  /// Rebuilds the running view from live progress, e.g. to draw a bar.
  const BootstrapPage.withProgress({
    required this.port,
    required this.runningBuilder,
    this.errorBuilder,
    super.key,
  }) : splash = null;

  final BootstrapPort port;

  /// Renders a failure. Defaults to a minimal message + retry screen.
  final BootstrapErrorBuilder? errorBuilder;

  /// Set by the default constructor. Exactly one of [splash] and
  /// [runningBuilder] is non-null.
  final Widget? splash;

  /// Set by [BootstrapPage.withProgress].
  final BootstrapRunningBuilder? runningBuilder;

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  late final BootstrapCubit _cubit = BootstrapCubit(widget.port);

  @override
  void initState() {
    super.initState();
    // Not awaited: the stream below is what drives the UI.
    unawaited(_cubit.start());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<BootstrapState>(
    stream: _cubit.stream,
    initialData: _cubit.state,
    builder: (context, snapshot) {
      final state = snapshot.data!;
      return switch (state) {
        BootstrapRunning() =>
          widget.runningBuilder?.call(context, state) ?? widget.splash!,
        BootstrapFailed() =>
          widget.errorBuilder?.call(
                context,
                state,
                state.canRetry ? _cubit.retry : null,
              ) ??
              _DefaultBootstrapError(
                state: state,
                onRetry: state.canRetry ? _cubit.retry : null,
              ),
      };
    },
  );
}

/// The fallback failure screen. Intentionally plain — apps are expected to
/// pass [BootstrapPage.errorBuilder] and use their own design system.
class _DefaultBootstrapError extends StatelessWidget {
  const _DefaultBootstrapError({required this.state, this.onRetry});

  final BootstrapFailed state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              state.jobName,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${state.error}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    ),
  );
}
