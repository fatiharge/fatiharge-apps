import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/route/app_router.gr.dart';

/// The way to settings, in the bar of every screen that has one.
///
/// One definition rather than four: a button that has to be remembered on each
/// new screen is a button the next screen will not have.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () => context.router.push(const SettingsRoute()),
    icon: const Icon(Icons.settings_outlined),
    tooltip: 'settings.title'.tr(),
  );
}
