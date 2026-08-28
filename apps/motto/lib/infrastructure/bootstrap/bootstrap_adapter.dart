import 'dart:async';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:motto/config/app_ready.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/content/application/content_repository.dart';
import 'package:motto/features/onboarding/application/onboarding_store.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';
import 'package:motto/infrastructure/session/device_session.dart';
import 'package:motto/route/app_router.dart';
import 'package:motto/route/app_router.gr.dart';

class BootstrapAdapter implements BootstrapPort {
  const BootstrapAdapter();

  @override
  List<BootstrapJob> jobs() => [
    const BootstrapJob('dependencies', configureDependencies),
    BootstrapJob(
      'session',
      () => getIt<DeviceSession>().ensure(),
      retries: 2,
      // The first screen that needs the server explains a network problem
      // better than a splash that will not move.
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
    // Not skipped: nothing ships inside the app, so a phone that has never
    // had a package has nothing to show and should say so rather than open on
    // an empty screen.
    BootstrapJob(
      'content',
      () => getIt<ContentRepository>().refresh(),
      retries: 2,
    ),
    // Last: it needs the token, and this is where anything collected while
    // offline gets a chance to leave.
    BootstrapJob(
      'analytics',
      () => getIt<Analytics>().record(MottoEvent.appOpen),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
  ];

  /// Three doors, and which one opens says what the app thinks of you: never
  /// been here, been here and has no result, or has one.
  @override
  void bootstrapFinished() {
    // Everything above the router — the mascot — is waiting for this.
    appReady.value = true;

    final router = getIt<AppRouter>();

    if (!getIt<OnboardingStore>().seen) {
      unawaited(router.replaceAll([OnboardingRoute()]));
      return;
    }
    if (getIt<LastArchetype>().id == null) {
      unawaited(router.replaceAll([const WelcomeRoute()]));
      return;
    }
    unawaited(router.replaceAll([const ShellRoute()]));
  }
}
