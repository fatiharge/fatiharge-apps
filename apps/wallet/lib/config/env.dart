import 'package:flutter/foundation.dart';

/// Not a `.env` file or a flavor: nothing in v1 differs between environments
/// except log verbosity. Both arrive with the backend.
abstract final class Env {
  static const bool debugLogs = bool.fromEnvironment(
    'FEATURE_DEBUG_LOGS',
    defaultValue: kDebugMode,
  );

  static const bool seedDemoData = bool.fromEnvironment('SEED_DEMO_DATA');

  /// [kDebugMode] as well as the define: a release that asked for a review on
  /// first launch is the kind of thing stores remove apps for.
  static const bool debugGrowth =
      kDebugMode && bool.fromEnvironment('DEBUG_GROWTH');
}
