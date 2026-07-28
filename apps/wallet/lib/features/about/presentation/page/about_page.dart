import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet/features/about/about_info.dart';
import 'package:wallet/generated/locale_keys.g.dart';

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
    appBar: AppBar(title: Text(LocaleKeys.about_title.tr())),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _Header(),
        _SectionLabel(LocaleKeys.about_made_by.tr()),
        for (final maintainer in maintainers)
          _CopyTile(
            // FaIcon rather than Icon: Font Awesome glyphs are not square, and
            // the plain Icon box crops and mis-centres them.
            leading: const FaIcon(FontAwesomeIcons.github),
            title: maintainer.name,
            subtitle: maintainer.mention,
            value: maintainer.githubUrl,
          ),
        _SectionLabel(LocaleKeys.about_feedback.tr()),
        _CopyTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: LocaleKeys.about_bug_report.tr(),
          subtitle: LocaleKeys.about_bug_report_hint.tr(),
          value: bugReportUrl,
        ),
        _CopyTile(
          leading: const Icon(Icons.lightbulb_outline),
          title: LocaleKeys.about_feature_request.tr(),
          subtitle: LocaleKeys.about_feature_request_hint.tr(),
          value: featureRequestUrl,
        ),
        _CopyTile(
          leading: const Icon(Icons.code),
          title: LocaleKeys.about_source.tr(),
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
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text('Wariden', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.about_tagline.tr(),
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
    await Clipboard.setData(ClipboardData(text: value));

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(LocaleKeys.about_copied.tr())));
  }
}
