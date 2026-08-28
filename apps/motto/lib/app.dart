import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/application/game_store.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:motto/features/mascot/presentation/mascot_route_observer.dart';
import 'package:motto/route/app_router.dart';
import 'package:motto/route/app_router.gr.dart';
import 'package:motto/theme/motto_theme.dart';

/// The rules come first, and only once: three lives is short enough that
/// learning the game by losing it teaches that it is not worth playing.
Future<void> _openGame(AppRouter router) => router.push(
  getIt<GameStore>().rulesSeen ? GameRoute() : GameRulesRoute(),
);

class MottoApp extends StatefulWidget {
  const MottoApp({required this.router, super.key});

  final AppRouter router;

  @override
  State<MottoApp> createState() => _MottoAppState();
}

class _MottoAppState extends State<MottoApp> {
  @override
  Widget build(BuildContext context) {
    final router = widget.router;
    return MaterialApp.router(
      title: 'Motto',
      debugShowCheckedModeBanner: false,
      theme: MottoTheme.light,
      darkTheme: MottoTheme.dark,
      // themeMode stays at its default: the phone decides.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router.config(
        navigatorObservers: () => [MascotRouteObserver()],
      ),
      // Above every screen rather than inside one: the mascot is dragged
      // anywhere, and one that resets when a tab changes is one nobody
      // believes in.
      builder: (context, child) => MascotHost(
        onGameOffered: () => _openGame(router),
        child: child ?? const SizedBox(),
      ),
    );
  }
}
