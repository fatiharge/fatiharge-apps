import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/presentation/views/currency_section.dart';
import 'package:wallet/features/settings/presentation/views/language_section.dart';
import 'package:wallet/features/settings/presentation/views/reminder_section.dart';
import 'package:wallet/features/settings/presentation/views/theme_section.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/route/app_router.gr.dart';

/// Reads [SettingsCubit] from above rather than creating one: the same
/// instance drives `MaterialApp.themeMode`, so a second one here would change
/// a theme nobody is watching.
@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr(LocaleKeys.settings_title))),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _SectionLabel(context.tr(LocaleKeys.settings_appearance)),
        const ThemeSection(),
        _SectionLabel(context.tr(LocaleKeys.settings_language)),
        const LanguageSection(),
        _SectionLabel(context.tr(LocaleKeys.settings_currency)),
        _SectionHint(context.tr(LocaleKeys.settings_currency_hint)),
        const CurrencySection(),
        const ReminderSettings(),
        const Divider(height: 32),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: Text(context.tr(LocaleKeys.categories_title)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.router.push(const CategoryRoute()),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(context.tr(LocaleKeys.about_title)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.router.push(const AboutRoute()),
        ),
      ],
    ),
  );
}

class _SectionHint extends StatelessWidget {
  const _SectionHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
