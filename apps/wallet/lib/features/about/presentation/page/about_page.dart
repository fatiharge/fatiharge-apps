import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/about/about_info.dart';
import 'package:wallet/features/about/domain/app_version_port.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/theme/app_mark.dart';

/// Credits and where to file issues.
///
/// Reached from settings rather than a navigation destination — visible, but
/// not competing with the three tabs.
///
/// Every row copies rather than opens: launching a browser would mean adding
/// `url_launcher` to an app that otherwise has no platform channels at all,
/// and a copied link gets the user just as far.
@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr(LocaleKeys.about_title))),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _Header(),
        _SectionLabel(context.tr(LocaleKeys.about_made_by)),
        for (final maintainer in maintainers)
          _CopyTile(
            // FaIcon rather than Icon: Font Awesome glyphs are not square, and
            // the plain Icon box crops and mis-centres them.
            leading: const FaIcon(FontAwesomeIcons.github),
            title: maintainer.name,
            subtitle: maintainer.mention,
            value: maintainer.githubUrl,
          ),
        _SectionLabel(context.tr(LocaleKeys.about_feedback)),
        _CopyTile(
          leading: const Icon(Icons.bug_report_outlined),
            title: context.tr(LocaleKeys.about_bug_report),
          subtitle: context.tr(LocaleKeys.about_bug_report_hint),
          value: bugReportUrl,
        ),
        _CopyTile(
          leading: const Icon(Icons.lightbulb_outline),
          title: context.tr(LocaleKeys.about_feature_request),
          subtitle: context.tr(LocaleKeys.about_feature_request_hint),
          value: featureRequestUrl,
        ),
        _CopyTile(
          leading: const Icon(Icons.code),
          title: context.tr(LocaleKeys.about_source),
          subtitle: repositoryUrl,
          value: repositoryUrl,
        ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          const AppMark(size: 76),
          const SizedBox(height: 12),
          Text('Warizo', style: theme.textTheme.headlineSmall),
          const _Version(),
          const SizedBox(height: 4),
          Text(
            context.tr(LocaleKeys.about_tagline),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// The installed version, which can differ from pubspec after a store update.
class _Version extends StatelessWidget {
  const _Version();

  @override
  Widget build(BuildContext context) => FutureBuilder<AppVersion>(
    future: getIt<AppVersionPort>().read(),
    builder: (context, snapshot) {
      final version = snapshot.data;
      return Text(
        version?.toString() ?? '',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    },
  );
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

/// A row that puts [value] on the clipboard and says so.
class _CopyTile extends StatelessWidget {
  const _CopyTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: leading,
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.copy_outlined, size: 18),
    onTap: () => _copy(context),
  );

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmation = context.tr(LocaleKeys.about_copied);

    await Clipboard.setData(ClipboardData(text: value));

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(confirmation)));
  }
}
