import 'package:injectable/injectable.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';

/// The two things the counter is drawn from, loaded once at startup.
///
/// One holder rather than two, because they are loaded by two jobs and read
/// as a pair everywhere else: there is no state of the app where the scene is
/// meaningful without the art. Both stay null until the startup jobs have
/// filled them, which is why the getters throw rather than return null — no
/// screen exists before bootstrap finishes, so a null here is a wiring
/// mistake rather than a case to handle.
@lazySingleton
class GameWorld {
  SceneData? _scene;
  GameAssets? _art;

  SceneData get scene => _scene ?? _missing('scene');
  GameAssets get art => _art ?? _missing('art');

  Future<void> loadScene() async => _scene = await SceneData.load();

  Future<void> loadArt() async => _art = await GameAssets.load();

  Never _missing(String what) =>
      throw StateError('GameWorld.$what read before bootstrap loaded it');
}
