import 'dart:developer' as developer;

import 'package:bootstrap_kit/bootstrap_kit.dart';

/// Crashes go to the local log for now. Once the events endpoint is wired this
/// is the only file that changes — `runGuarded` and every call site stay as
/// they are.
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
