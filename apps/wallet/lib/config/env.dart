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

  /// Collapses the waiting built into the review prompt and the monthly
  /// reminder, so both can be seen in one sitting rather than in a fortnight.
  /// `--dart-define=DEBUG_GROWTH=true`
  ///
  /// Gated on [kDebugMode] as well as the define: a release build that asked
  /// for a review on first launch, or notified every minute, is the kind of
  /// thing both stores remove apps for.
  static const bool debugGrowth =
      kDebugMode && bool.fromEnvironment('DEBUG_GROWTH');
}
