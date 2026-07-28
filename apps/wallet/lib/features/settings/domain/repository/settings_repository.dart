import 'package:wallet/features/settings/domain/theme_preference.dart';

/// Storage contract for the app's scalar preferences.
///
/// [readTheme] is synchronous on purpose. The theme has to be known before the
/// first frame or the app opens in the wrong one, and an async read would make
/// that impossible to express — the adapter loads its store before `runApp`
/// instead, and every read afterwards is from memory.
abstract interface class SettingsRepository {
  ThemePreference readTheme();

  Future<void> writeTheme(ThemePreference preference);
}
