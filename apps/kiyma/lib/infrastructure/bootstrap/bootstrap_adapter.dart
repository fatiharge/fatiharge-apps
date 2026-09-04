import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter/services.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:kiyma/route/first_run.dart';
import 'package:meta/meta.dart';

/// The orientation, then the container, then the scene, then the art.
///
/// The three that load are `restart`: there is no reduced game to fall back
/// to, and a scene that will not parse is not something a retry fixes.
class BootstrapAdapter implements BootstrapPort {
  const BootstrapAdapter();

  @override
  List<BootstrapJob> jobs() => [
    BootstrapJob('display', () async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }, errorPolicy: BootstrapErrorPolicy.skip),
    const BootstrapJob(
      'dependencies',
      configureDependencies,
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
    BootstrapJob(
      'scene',
      () => getIt<GameWorld>().loadScene(),
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
    BootstrapJob(
      'art',
      () => getIt<GameWorld>().loadArt(),
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
  ];

  /// `replaceAll`, so a back gesture cannot land on a finished bootstrap.
  @override
  void bootstrapFinished() =>
      unawaited(getIt<AppRouter>().replaceAll([firstRoute()]));

  /// Split out so the order can be asserted: getting it wrong is invisible
  /// until somebody installs the app fresh.
  @visibleForTesting
  static PageRouteInfo<dynamic> firstRoute({bool? chosen}) =>
      (chosen ?? languageChosen) ? const MenuRoute() : LanguageRoute();
}
