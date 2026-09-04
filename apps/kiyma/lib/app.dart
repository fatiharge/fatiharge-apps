import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/ui/palette.dart';

class KiymaApp extends StatelessWidget {
  const KiymaApp({required this.router, super.key});

  final AppRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
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
    // The first route is the startup page; what it opens once the jobs are
    // done is the bootstrap port's business, not this widget's.
    routerConfig: router.config(),
  );
}
