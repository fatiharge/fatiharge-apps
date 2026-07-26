import 'dart:async';

import 'package:flutter/widgets.dart';

/// The outermost startup boundary: runs the app inside a guarded zone and
/// forwards both framework and uncaught async errors to [onCrash].
///
/// Implement [onCrash] in the app (e.g. report to Crashlytics) and wrap
/// startup with [runGuarded]:
///
/// ```dart
/// void main() => AppCrashListener().runGuarded(() async {
///   // configureDependencies(); runApp(...);
/// });
/// ```
abstract class CrashListener {
  /// Called for every captured error. [fatal] is `false` for framework errors
  /// (build/layout asserts) and `true` for uncaught async errors that crash the
  /// app.
  Future<void> onCrash({
    required Object error,
    required StackTrace? stack,
    required bool fatal,
  });

  /// Ensures the binding is initialized, installs the framework error handler,
  /// and runs [body] inside a guarded zone so nothing escapes uncaught.
  Future<void> runGuarded(Future<void> Function() body) async {
    // Completed from both paths below. Awaiting the zone's own future instead
    // would hang forever when [body] throws: that error is routed to the zone
    // handler, so the future it came from is never completed for the awaiter.
    final finished = Completer<void>();
    void settle() {
      if (!finished.isCompleted) finished.complete();
    }

    // The zone's own future is deliberately dropped; [finished] is what
    // callers wait on.
    unawaited(
      runZonedGuarded(
        () async {
          WidgetsFlutterBinding.ensureInitialized();
          // Framework errors (overflow, build asserts) are usually not
          // crashes -> non-fatal. The red screen is preserved in debug.
          FlutterError.onError = (details) {
            FlutterError.presentError(details);
            unawaited(
              onCrash(
                error: details.exception,
                stack: details.stack,
                fatal: false,
              ),
            );
          };
          try {
            await body();
          } finally {
            // Runs on the throwing path too; the error still escapes to the
            // zone handler below and is reported as fatal.
            settle();
          }
        },
        // Uncaught async errors crash the app -> fatal.
        (error, stack) {
          unawaited(onCrash(error: error, stack: stack, fatal: true));
          settle();
        },
      ),
    );

    return finished.future;
  }
}
