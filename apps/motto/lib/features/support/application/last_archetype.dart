import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The archetype the last test produced.
///
/// Kept only so a bug report or a rejection knows what it is about. Feedback
/// that says "this is wrong" without saying wrong about what is feedback
/// nobody can act on.
@lazySingleton
class LastArchetype {
  LastArchetype(this._preferences);

  static const _key = 'last_archetype';

  final SharedPreferences _preferences;

  String? get id => _preferences.getString(_key);

  Future<void> remember(String archetypeId) =>
      _preferences.setString(_key, archetypeId);

  Future<void> forget() => _preferences.remove(_key);
}
