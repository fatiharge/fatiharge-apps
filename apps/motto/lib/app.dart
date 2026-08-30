import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/game/presentation/open_game.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:motto/features/mascot/presentation/mascot_route_observer.dart';
import 'package:motto/route/app_router.dart';
import 'package:motto/theme/motto_theme.dart';

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
      // Keyed on the language so that changing it rebuilds everything below.
      // `.tr()` reads the words without a context, which is what lets a cubit
      // and a notification use it — and also means no widget is subscribed to
      // the locale. Without this key, half a screen changes language and the
      // half that was not rebuilt for some other reason does not.
      key: ValueKey(context.locale.languageCode),
      title: 'Motto',
      debugShowCheckedModeBanner: false,
      theme: MottoTheme.light,
      darkTheme: MottoTheme.dark,
      // themeMode stays at its default: the phone decides.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router.config(
        // The mascot's observer says which screen it floats over; the route
        // observer lets a tab notice that the screen covering it went away.
        navigatorObservers: () => [MascotRouteObserver(), AutoRouteObserver()],
      ),
      // Above every screen rather than inside one: the mascot is dragged
      // anywhere, and one that resets when a tab changes is one nobody
      // believes in.
      builder: (context, child) => MascotHost(
        onGameOffered: openGame,
        child: child ?? const SizedBox(),
      ),
    );
  }
}
