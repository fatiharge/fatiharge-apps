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

/// What has to happen before the first screen means anything.
class BootstrapAdapter implements BootstrapPort {
  const BootstrapAdapter();

  @override
  List<BootstrapJob> jobs() => [
    const BootstrapJob('dependencies', configureDependencies),
    BootstrapJob(
      'session',
      () => getIt<DeviceSession>().ensure(),
      retries: 2,
      // Skipped rather than retried into a wall: the app is usable without a
      // token — the welcome screen reads fine — and the first screen that needs
      // the server is a better place to explain a network problem than a
      // splash that will not move.
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
    // Skipped rather than retried, like the session above: the app already
    // ships with a content package, so a refresh that cannot happen costs
    // nothing anyone can see.
    BootstrapJob(
      'content',
      () => getIt<ContentRepository>().refresh(),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
    // Last, because it needs the token the job above fetches — and because
    // this is also where anything the phone collected while offline gets a
    // chance to leave.
    BootstrapJob(
      'analytics',
      () => getIt<Analytics>().record(MottoEvent.appOpen),
      errorPolicy: BootstrapErrorPolicy.skip,
    ),
  ];

  /// Replaces rather than pushes: the splash is not somewhere to come back to.
  ///
  /// Somebody who already has a result lands on today, not on a welcome screen
  /// inviting them to do the thing they have done. Daily freshness is what
  /// this product is, and the front door has to be it.
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
