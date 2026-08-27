import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/route/app_router.dart';
import 'package:motto/theme/motto_theme.dart';

class MottoApp extends StatelessWidget {
  const MottoApp({required this.router, super.key});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Motto',
      debugShowCheckedModeBanner: false,
      theme: MottoTheme.light,
      darkTheme: MottoTheme.dark,
      // themeMode is left at its default, which is ThemeMode.system: the phone
      // decides. See the note in MottoTheme for why that is worth the second
      // pass over every screen.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router.config(),
    );
  }
}
