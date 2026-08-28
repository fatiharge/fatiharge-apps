import 'package:flutter/foundation.dart';

/// Reports a failure the app is about to swallow.
///
/// A cubit turns a failed request into a calm sentence on screen, which is
/// right for the reader and useless for whoever has to fix it.
void reported(String where, Object error, StackTrace trace) {
  // Printed as well as reported: `developer.log`, where the crash listener
  // sends things, reaches the VM service and not the device log.
  debugPrint('motto/$where failed: $error');
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: trace,
      library: 'motto/$where',
    ),
  );
}
