import 'dart:developer' as developer;

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:wallet/config/env.dart';

/// The app's crash sink.
///
/// v1 has no backend, so crashes go to the local log. When Crashlytics is
/// added this is the only file that changes — [CrashListener.runGuarded] and
/// every call site stay as they are.
class AppCrashListener extends CrashListener {
  @override
  Future<void> onCrash({
    required Object error,
    required StackTrace? stack,
    required bool fatal,
  }) async {
    if (!Env.debugLogs) return;
    developer.log(
      fatal ? 'FATAL' : 'non-fatal',
      name: 'wallet.crash',
      error: error,
      stackTrace: stack,
    );
  }
}
