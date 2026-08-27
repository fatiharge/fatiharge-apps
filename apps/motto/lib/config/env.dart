import 'package:flutter/services.dart';

/// Which deployment this build talks to.
enum MottoEnvironment {
  stage('https://authstage.dafalabs.com', 'https://mottostage.dafalabs.com'),
  production('https://auth.dafalabs.com', 'https://motto.dafalabs.com');

  const MottoEnvironment(this.authBaseUrl, this.mottoBaseUrl);

  final String authBaseUrl;
  final String mottoBaseUrl;
}

/// Where the app points, decided by the flavor it was built with.
///
/// Both platforms declare flavors, so a build without one does not happen by
/// accident — and if it somehow does, this refuses to guess. Defaulting either
/// way is worse than failing: pick production and a developer quietly writes to
/// the real database, pick stage and a released build quietly does not.
abstract final class Env {
  static MottoEnvironment get current => switch (appFlavor) {
    'stage' => MottoEnvironment.stage,
    'prod' => MottoEnvironment.production,
    final String unknown => throw StateError('unknown flavor: $unknown'),
    null => throw StateError(
      'built without a flavor — use --flavor stage or --flavor prod',
    ),
  };

  static String get authBaseUrl => current.authBaseUrl;

  static String get mottoBaseUrl => current.mottoBaseUrl;

  static bool get isStage => current == MottoEnvironment.stage;
}
