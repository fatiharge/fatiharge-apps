import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/settings/presentation/views/setting_option_tile.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Stateful because easy_localization cannot answer "is this still the device
/// language": `savedLocale` stays stale until the next launch.
class LanguageSection extends StatefulWidget {
  const LanguageSection({super.key});

  @override
  State<LanguageSection> createState() => _LanguageSectionState();
}

class _LanguageSectionState extends State<LanguageSection> {
  /// Each written in itself, so someone who switched by accident can get back.
  static const _names = {
    'tr': 'Türkçe',
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'it': 'Italiano',
  };

  /// Lazily, not in `initState`: reading it depends on an inherited widget.
  late bool _followsDevice = context.savedLocale == null;

  Future<void> _useDeviceLanguage() async {
    // Order matters: `resetLocale()` also *saves*, pinning the app to today's
    // device language. Clearing afterwards is what makes it outlast the launch.
    await context.resetLocale();
    if (!mounted) return;
    await context.deleteSaveLocale();
    if (mounted) setState(() => _followsDevice = true);
  }

  Future<void> _select(Locale locale) async {
    await context.setLocale(locale);
    if (mounted) setState(() => _followsDevice = false);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SettingOptionTile(
        icon: Icons.language_outlined,
        label: context.tr(LocaleKeys.settings_language_system),
        selected: _followsDevice,
        onTap: _useDeviceLanguage,
      ),
      for (final locale in context.supportedLocales)
        SettingOptionTile(
          icon: Icons.translate_outlined,
          label: _names[locale.languageCode] ?? locale.languageCode,
          selected: !_followsDevice && locale == context.locale,
          onTap: () => _select(locale),
        ),
    ],
  );
}
