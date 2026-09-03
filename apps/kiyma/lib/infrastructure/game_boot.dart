import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';

/// Startup, as two jobs the kit runs and reports on.
///
/// Both are `restart`: a scene file that will not parse or art that will not
/// decode is not something a retry fixes, and there is no reduced game to
/// fall back to — the whole of the play area is these two files.
class GameBoot implements BootstrapPort {
  final ValueNotifier<bool> ready = ValueNotifier(false);

  late SceneData scene;
  late GameAssets assets;

  @override
  List<BootstrapJob> jobs() => [
    BootstrapJob(
      'scene',
      () async => scene = await SceneData.load(),
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
    BootstrapJob(
      'art',
      () async => assets = await GameAssets.load(),
      errorPolicy: BootstrapErrorPolicy.restart,
    ),
  ];

  @override
  void bootstrapFinished() => ready.value = true;
}
