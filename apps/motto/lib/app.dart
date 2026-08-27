import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
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
      // themeMode stays at its default: the phone decides.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router.config(),
      // Above every screen rather than inside one: the mascot is dragged
      // anywhere, and one that resets when a tab changes is one nobody
      // believes in.
      builder: (context, child) => MascotHost(child: child ?? const SizedBox()),
    );
  }
}
