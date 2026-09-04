import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether this device has ever answered the language question.
///
/// A flag of our own rather than easy_localization's saved locale. That one
/// is only reachable through an inherited widget, which would mean asking a
/// widget something the startup port needs to know before any widget exists —
/// and reading its private key instead would tie the first run to somebody
/// else's storage detail.
@lazySingleton
class LanguageChoice {
  const LanguageChoice(this._preferences);

  static const _key = 'language_chosen';

  final SharedPreferences _preferences;

  bool get made => _preferences.getBool(_key) ?? false;

  Future<void> record() => _preferences.setBool(_key, true);
}
