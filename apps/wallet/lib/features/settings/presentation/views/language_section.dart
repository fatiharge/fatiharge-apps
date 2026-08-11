import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/settings/presentation/views/setting_option_tile.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Language picker, backed entirely by easy_localization.
///
/// Stateful because the package's own state cannot answer "is this still the
/// device language": `setLocale` persists the choice but leaves `savedLocale`
/// stale until the next launch, and `deleteSaveLocale` notifies nobody. So the
/// answer is tracked here, seeded once from what was persisted.
class LanguageSection extends StatefulWidget {
  const LanguageSection({super.key});

  @override
  State<LanguageSection> createState() => _LanguageSectionState();
}

class _LanguageSectionState extends State<LanguageSection> {
  /// Each language is written in itself — someone who switched to a language
  /// they cannot read has to be able to find their way back.
  static const _names = {'tr': 'Türkçe', 'en': 'English'};

  /// Lazily, not in `initState`: reading it depends on an inherited widget.
  late bool _followsDevice = context.savedLocale == null;

  Future<void> _useDeviceLanguage() async {
    // Order matters. `resetLocale()` resolves the device language *and saves
    // it*, which would pin the app to whatever the device is today. Clearing
    // the saved value afterwards is what makes "follow the device" outlast
    // this launch.
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
