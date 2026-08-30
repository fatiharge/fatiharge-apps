import 'dart:async';

import 'package:auto_route/auto_route.dart';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:meta/meta.dart';
import 'package:motto/config/app_ready.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/content/application/content_repository.dart';
import 'package:motto/features/onboarding/application/onboarding_store.dart';
import 'package:motto/features/support/application/archetype_restore.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';
import 'package:motto/infrastructure/effects/effect_repository.dart';
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
    // Not skipped, for the same reason content is not: the door below is
    // chosen from a value a reinstall wipes, and skipping this one would ask
    // somebody with a running chain to fill the inventory again. A phone with
    // no network cannot get past `content` either, so this adds no failure
    // anyone can reach.
    BootstrapJob(
      'archetype',
      () => getIt<ArchetypeRestore>().ensure(),
      retries: 2,
    ),
    // Not skipped: nothing ships inside the app, so a phone that has never
    // had a package has nothing to show and should say so rather than open on
    // an empty screen.
    BootstrapJob(
      'content',
      () => getIt<ContentRepository>().refresh(),
      retries: 2,
    ),
    // Skipped when it fails, unlike content: an app with no definitions still
    // works. Every refusal reads as a code nobody wrote for, and that case has
    // an answer already.
    BootstrapJob(
      'effects',
      () => getIt<EffectRepository>().refresh(),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
    // Last: it needs the token, and this is where anything collected while
    // offline gets a chance to leave.
    BootstrapJob(
      'analytics',
      () => getIt<Analytics>().record(MottoEvent.appOpen),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
  ];

  /// Three doors, and which one opens says what the app thinks of you: has a
  /// result, has never been here, or has been here without one.
  @override
  void bootstrapFinished() {
    // Everything above the router — the mascot — is waiting for this.
    appReady.value = true;

    final router = getIt<AppRouter>();

    unawaited(router.replaceAll([firstRoute()]));
  }

  /// Split out so the order of the doors can be asserted: getting it wrong is
  /// invisible until somebody reinstalls, and by then they have answered the
  /// inventory a second time.
  @visibleForTesting
  static PageRouteInfo<dynamic> firstRoute({
    bool? hasResult,
    bool? onboardingSeen,
  }) {
    // Asked first, and before the introduction: a device with a result has
    // used this app before. The introduction opens with "I will ask you
    // twenty questions", which is the wrong sentence to hand somebody whose
    // answers are already on the server and whose chain is still running.
    if (hasResult ?? getIt<LastArchetype>().id != null) {
      return const ShellRoute();
    }
    if (!(onboardingSeen ?? getIt<OnboardingStore>().seen)) {
      return OnboardingRoute();
    }
    return const WelcomeRoute();
  }
}
