import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The archetype the last test produced, and which result it was.
///
/// Kept so a bug report knows what it is about — and so the way into the
/// result survives a dead network. The row that opens it used to come from the
/// server, so the door to the deep report closed whenever the connection did.
@lazySingleton
class LastArchetype {
  LastArchetype(this._preferences);

  static const _key = 'last_archetype';
  static const _resultKey = 'last_result_id';

  final SharedPreferences _preferences;

  String? get id => _preferences.getString(_key);

  /// The result the archetype came from, so it can be opened offline.
  int? get resultId => _preferences.getInt(_resultKey);

  Future<void> remember(String archetypeId, {int? resultId}) async {
    await _preferences.setString(_key, archetypeId);
    if (resultId != null) await _preferences.setInt(_resultKey, resultId);
  }

  Future<void> forget() async {
    await _preferences.remove(_key);
    await _preferences.remove(_resultKey);
  }
}
