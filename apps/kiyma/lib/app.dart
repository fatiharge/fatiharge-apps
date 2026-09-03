import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/infrastructure/game_boot.dart';
import 'package:kiyma/ui/game_screen.dart';
import 'package:kiyma/ui/palette.dart';
import 'package:kiyma/ui/splash.dart';

class KiymaApp extends StatelessWidget {
  const KiymaApp({required this.boot, super.key});

  final GameBoot boot;

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
    home: ValueListenableBuilder<bool>(
      valueListenable: boot.ready,
      builder: (context, ready, _) => ready
          ? GameScreen(scene: boot.scene, assets: boot.assets)
          : BootstrapPage.withProgress(
              port: boot,
              runningBuilder: (context, state) =>
                  SplashView(progress: state.progress),
            ),
    ),
  );
}
