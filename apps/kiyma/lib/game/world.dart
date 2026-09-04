import 'package:injectable/injectable.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';

/// The two things the counter is drawn from, loaded once at startup.
///
/// The getters throw rather than return null: no screen exists before
/// bootstrap has filled them, so a null is a wiring mistake.
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
