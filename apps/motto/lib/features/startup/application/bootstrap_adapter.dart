import 'dart:async';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:motto/config/injectable.dart';
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
  @override
  void bootstrapFinished() {
    unawaited(getIt<AppRouter>().replaceAll([const WelcomeRoute()]));
  }
}
