import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/route/app_navigator.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:kiyma/ui/splash.dart';

class KiymaApp extends StatelessWidget {
  const KiymaApp({required this.port, required this.navigator, super.key});

  final BootstrapPort port;
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => MaterialApp(
    // Keyed on the language so a change rebuilds everything below it: `.tr()`
    // reads the words without a context, so no widget is subscribed to the
    // locale on its own.
    key: ValueKey(context.locale.languageCode),
    title: 'Kıyma',
    debugShowCheckedModeBanner: false,
    theme: KiymaPalette.theme,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    navigatorKey: navigator.key,
    // The splash is the home, and the port replaces it once the jobs are
    // done. Nothing here watches for that: what startup opens is the port's
    // business, which is the whole point of the boundary.
    home: BootstrapPage.withProgress(
      port: port,
      runningBuilder: (context, state) => SplashView(progress: state.progress),
    ),
  );
}
