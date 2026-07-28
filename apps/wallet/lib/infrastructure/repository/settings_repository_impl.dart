import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// SharedPreferences-backed [SettingsRepository].
///
/// Takes an already-loaded [SharedPreferences] rather than calling
/// `getInstance()` itself, which is what lets [readTheme] be synchronous. It
/// is registered by hand in `main.dart` for the same reason the router is:
/// the theme is needed before the DI container is built.
///
/// Not annotated for injectable — a generated registration would resolve too
/// late to be of any use here.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._preferences);

  /// Namespaced because easy_localization keeps its own `locale` key in this
  /// same store.
  static const String themeKey = 'settings.theme';

  final SharedPreferences _preferences;

  @override
  ThemePreference readTheme() =>
      ThemePreference.fromStorage(_preferences.getString(themeKey));

  @override
  Future<void> writeTheme(ThemePreference preference) =>
      _preferences.setString(themeKey, preference.storageKey);
}
