import 'dart:async';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// The app's side of the bootstrap boundary: the container, then the scene,
/// then the art.
///
/// All three are `restart`. There is no reduced game to fall back to — the
/// whole of the play area is these files — and a scene that will not parse is
/// not something a retry fixes. Three jobs rather than one so the splash bar
/// moves and a failure names the step that failed.
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
  ];

  /// `replaceAll` rather than a push: there is nothing to go back to, and a
  /// back gesture onto a finished bootstrap would re-run it.
  @override
  void bootstrapFinished() =>
      unawaited(getIt<AppRouter>().replaceAll([const GameRoute()]));
}
