import 'package:flutter/foundation.dart';

/// Build-time switches.
///
/// Deliberately not a `.env` file or a flavor: nothing in v1 differs between
/// environments except log verbosity. Real per-environment values (API keys,
/// Firebase config) arrive with the backend, and `--dart-define-from-file`
/// plus flavors arrive with them.
abstract final class Env {
  /// On in debug builds; override with
  /// `--dart-define=FEATURE_DEBUG_LOGS=true|false`.
  static const bool debugLogs = bool.fromEnvironment(
    'FEATURE_DEBUG_LOGS',
    defaultValue: kDebugMode,
  );

  /// Fills an empty database with a month of sample transactions.
  /// `--dart-define=SEED_DEMO_DATA=true`
  static const bool seedDemoData = bool.fromEnvironment('SEED_DEMO_DATA');
}
