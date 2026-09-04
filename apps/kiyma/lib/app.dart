import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/presentation/palette.dart';
import 'package:kiyma/route/app_router.dart';

class KiymaApp extends StatelessWidget {
  const KiymaApp({required this.router, super.key});

  final AppRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    key: ValueKey(context.locale.languageCode),
    title: 'Kıyma',
    debugShowCheckedModeBanner: false,
    theme: KiymaPalette.theme,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    routerConfig: router.config(),
  );
}
