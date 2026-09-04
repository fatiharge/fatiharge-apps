import 'package:injectable/injectable.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/halo.dart';

/// The two things the counter is drawn from, loaded once at startup.
///
/// The getters throw rather than return null: no screen exists before
/// bootstrap has filled them, so a null is a wiring mistake.
@lazySingleton
class GameWorld {
  SceneData? _scene;
  GameAssets? _art;
  Halos? _halos;

  SceneData get scene => _scene ?? _missing('scene');
  GameAssets get art => _art ?? _missing('art');
  Halos get halos => _halos ?? _missing('halos');

  Future<void> loadScene() async => _scene = await SceneData.load();

  /// Baking the hint glows belongs here rather than at first use: it needs
  /// both the art and the scene, and a blur is not something to pay for on
  /// the frame a hint first lights up.
  Future<void> loadArt() async {
    final art = _art = await GameAssets.load();
    _halos = await Halos.bake(scene, art);
  }

  Never _missing(String what) =>
      throw StateError('GameWorld.$what read before bootstrap loaded it');
}
