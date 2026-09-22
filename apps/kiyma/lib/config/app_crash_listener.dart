import 'dart:developer' as developer;

import 'package:bootstrap_kit/bootstrap_kit.dart';

/// Logs for now. There is no crash reporter wired up yet, and a game that
/// posts nothing anywhere is the honest state to leave this in until one is.
class AppCrashListener extends CrashListener {
  @override
  Future<void> onCrash({
    required Object error,
    required StackTrace? stack,
    required bool fatal,
  }) async => developer.log(
    fatal ? 'fatal' : 'framework',
    name: 'kiyma',
    error: error,
    stackTrace: stack,
  );
}
