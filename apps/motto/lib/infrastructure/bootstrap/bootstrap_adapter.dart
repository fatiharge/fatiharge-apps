import 'dart:async';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/content/application/content_repository.dart';
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

  /// Somebody who already has a result lands on today, not on a welcome screen
  /// inviting them to do what they have done.
  @override
  void bootstrapFinished() {
    final started = getIt<LastArchetype>().id != null;
    unawaited(
      getIt<AppRouter>().replaceAll([
        if (started) const TodayRoute() else const WelcomeRoute(),
      ]),
    );
  }
}
