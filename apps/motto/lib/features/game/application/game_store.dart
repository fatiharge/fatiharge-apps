import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the rules have been explained.
///
/// On the device: it is about this installation, and somebody reinstalling has
/// earned the explanation again more than they have earned skipping it.
@lazySingleton
class GameStore {
  GameStore(this._preferences);

  static const _key = 'game_rules_seen';

  final SharedPreferences _preferences;

  bool get rulesSeen => _preferences.getBool(_key) ?? false;

  Future<void> markRulesSeen() => _preferences.setBool(_key, true);
}
