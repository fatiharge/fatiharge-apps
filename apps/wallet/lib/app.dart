import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/route/app_router.dart';
import 'package:wallet/theme/app_theme.dart';

/// The root widget: theme, localization and the router.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolved from get_it rather than constructed here: the bootstrap adapter
    // navigates through the same instance once startup finishes.
    final router = getIt<RouteManager>();

    return MaterialApp.router(
      title: 'Wariden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router.config(),
    );
  }
}
