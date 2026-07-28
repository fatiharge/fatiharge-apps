import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// The widget-layer view of [ThemePreference].
///
/// Kept out of `domain/`, which may not import Flutter — [ThemeMode] and
/// [IconData] both come from the framework.
extension ThemePreferenceView on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  IconData get icon => switch (this) {
    ThemePreference.system => Icons.brightness_auto_outlined,
    ThemePreference.light => Icons.light_mode_outlined,
    ThemePreference.dark => Icons.dark_mode_outlined,
  };

  String get label => switch (this) {
    ThemePreference.system => LocaleKeys.settings_theme_system.tr(),
    ThemePreference.light => LocaleKeys.settings_theme_light.tr(),
    ThemePreference.dark => LocaleKeys.settings_theme_dark.tr(),
  };
}
