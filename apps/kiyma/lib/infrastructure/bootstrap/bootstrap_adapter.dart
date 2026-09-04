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

/// The app's side of the bootstrap boundary: the container, then the scene,
/// then the art.
///
/// All three are `restart`. There is no reduced game to fall back to — the
/// whole of the play area is these files — and a scene that will not parse is
/// not something a retry fixes. Three jobs rather than one so the splash bar
/// moves and a failure names the step that failed.
///
/// How long the brand screen is held is not one of them: that is the kit's
/// `minDuration`, set where the page is built.
class BootstrapAdapter implements BootstrapPort {
  const BootstrapAdapter();

  @override
  List<BootstrapJob> jobs() => [
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
    // Landscape only, and no system bars. The counter is measured in one
    // fixed 1024x576 space; a rotation would letterbox it into a strip, and a
    // gesture bar sits exactly where the waiting shelves are.
    BootstrapJob('display', () async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }, errorPolicy: BootstrapErrorPolicy.skip),
  ];

  /// `replaceAll` rather than a push: there is nothing to go back to, and a
  /// back gesture onto a finished bootstrap would re-run it.
  @override
  void bootstrapFinished() =>
      unawaited(getIt<AppRouter>().replaceAll([firstRoute()]));

  /// Two doors, and which one opens says whether this device has ever
  /// answered the language question.
  ///
  /// Nothing of ours is stored to decide it: easy_localization persists the
  /// chosen locale itself, and the absence of that value *is* the first run.
  /// Split out so the order can be asserted — getting it wrong is invisible
  /// until somebody installs the app fresh.
  @visibleForTesting
  static PageRouteInfo<dynamic> firstRoute({bool? chosen}) =>
      (chosen ?? languageChosen) ? const MenuRoute() : LanguageRoute();
}
