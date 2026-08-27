import 'package:flutter/services.dart';

enum MottoEnvironment {
  stage('https://authstage.dafalabs.com', 'https://mottostage.dafalabs.com'),
  production('https://auth.dafalabs.com', 'https://motto.dafalabs.com');

  const MottoEnvironment(this.authBaseUrl, this.mottoBaseUrl);

  final String authBaseUrl;
  final String mottoBaseUrl;
}

/// Where the app points. A build without a flavor refuses to guess: pick
/// production and a developer writes to the real database, pick stage and a
/// released build quietly does not.
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

  /// The store listing needs a public URL anyway; the app opens that one
  /// rather than shipping a second copy.
  static const privacyPolicyUrl = 'https://dafalabs.com/motto/privacy';
}
