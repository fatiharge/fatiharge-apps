import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/infrastructure/session/device_session.dart';

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
  ];

  @override
  void bootstrapFinished() {}
}
