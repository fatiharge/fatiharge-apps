import 'dart:async';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// The app's side of the bootstrap boundary: the container, then the scene,
/// then the art, and a floor under how briefly the brand screen can flash.
///
/// The three real jobs are `restart`. There is no reduced game to fall back
/// to — the whole of the play area is those files — and a scene that will not
/// parse is not something a retry fixes. Three rather than one so the splash
/// bar moves and a failure names the step that failed.
class BootstrapAdapter implements BootstrapPort {
  BootstrapAdapter();

  /// How long the brand screen stays up even when there is nothing left to
  /// wait for.
  ///
  /// Everything loads off the device in a couple of hundred milliseconds, so
  /// without a floor the splash is a flicker between the launch image and the
  /// counter — the wordmark may as well not exist.
  static const _minSplash = Duration(seconds: 3);

  final _elapsed = Stopwatch();

  @override
  List<BootstrapJob> jobs() {
    // Started here, not in the constructor: the cubit asks for the job list
    // once per run, and this has to be measuring *this* run.
    _elapsed
      ..reset()
      ..start();

    return [
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
      // Last, and only the remainder. A wait placed first would be a wait the
      // real work then queues up behind, which turns a three second floor
      // into three seconds plus however long loading takes.
      BootstrapJob('splash', () async {
        final left = _minSplash - _elapsed.elapsed;
        if (left > Duration.zero) await Future<void>.delayed(left);
      }),
    ];
  }

  /// `replaceAll` rather than a push: there is nothing to go back to, and a
  /// back gesture onto a finished bootstrap would re-run it.
  @override
  void bootstrapFinished() =>
      unawaited(getIt<AppRouter>().replaceAll([const GameRoute()]));
}
