import 'dart:developer' as developer;

import 'package:bootstrap_kit/bootstrap_kit.dart';

/// Crashes go to the local log for now. Wiring the events endpoint changes
/// only this file.
class AppCrashListener extends CrashListener {
  @override
  Future<void> onCrash({
    required Object error,
    required StackTrace? stack,
    required bool fatal,
  }) async {
    developer.log(
      fatal ? 'FATAL' : 'non-fatal',
      name: 'motto.crash',
      error: error,
      stackTrace: stack,
    );
  }
}
