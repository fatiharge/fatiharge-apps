import 'package:flutter/foundation.dart';

/// Reports a failure the app is about to swallow.
///
/// Cubits turn a failed request into a state and say something calm on screen,
/// which is right for the person holding the phone and useless for whoever has
/// to fix it: the screen said "alınamadı" and the log said nothing at all.
/// This does not change what the user sees; it just stops the reason from
/// disappearing.
void reported(String where, Object error, StackTrace trace) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: trace,
      library: 'motto/$where',
    ),
  );
}
