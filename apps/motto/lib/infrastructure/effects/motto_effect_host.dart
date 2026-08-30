import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/presentation/open_game.dart';
import 'package:motto/infrastructure/effects/effect.dart';
import 'package:motto/infrastructure/effects/effect_host.dart';
import 'package:motto/infrastructure/effects/refresh_requests.dart';
import 'package:motto/route/app_router.dart';
import 'package:motto/route/app_router.gr.dart';

/// What this app is willing to be asked for, and how it does each of them.
///
/// The engine decides what happens and in what order. This decides what a
/// sheet looks like and where a route leads — the half that is motto's, and
/// the half that stays behind when the engine leaves.
@LazySingleton(as: EffectHost)
class MottoEffectHost implements EffectHost {
  /// Named rather than free: a definition that could name any deep link would
  /// hand whoever writes definitions the app's navigation.
  static const routes = {'gorevler', 'gunler', 'profil', 'ayarlar', 'oyun'};

  /// Requests this app knows how to make on its own behalf.
  static const calls = {'yenile'};

  /// Things the app does to itself. Motto has none — no accounts, so nothing
  /// to sign out of.
  static const methods = <String>{};

  static const permits = EffectPermits(
    routes: routes,
    calls: calls,
    methods: methods,
  );

  AppRouter get _router => getIt<AppRouter>();

  BuildContext? get _where => _router.navigatorKey.currentContext;

  @override
  Future<void> snack(String message) async {
    final context = _where;
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Future<int?> sheet(ShowSheet asked) async {
    final context = _where;
    if (context == null || !context.mounted) return null;

    Widget button(int index, String label) => index == 0
        ? FilledButton(
            onPressed: () => Navigator.of(context).pop(index),
            child: Text(label),
          )
        : TextButton(
            onPressed: () => Navigator.of(context).pop(index),
            child: Text(label),
          );

    Widget body(BuildContext sheet) {
      final text = Theme.of(sheet).textTheme;
      final scheme = Theme.of(sheet).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(asked.title, style: text.titleLarge),
              const SizedBox(height: 12),
              Text(
                asked.body,
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              for (final (index, choice) in asked.choices.indexed)
                button(index, choice.label),
            ],
          ),
        ),
      );
    }

    return asked.bottom
        ? showModalBottomSheet<int>(
            context: context,
            showDragHandle: true,
            builder: body,
          )
        : showDialog<int>(
            context: context,
            builder: (dialog) => Dialog(child: body(dialog)),
          );
  }

  @override
  Future<void> goTo(String route) async {
    switch (route) {
      case 'gorevler':
        await _tab(1);
      case 'gunler':
        await _tab(2);
      case 'profil':
        await _tab(3);
      case 'ayarlar':
        await _router.push(const SettingsRoute());
      case 'oyun':
        await openGame();
    }
  }

  Future<void> _tab(int index) async {
    _router.popUntilRoot();
    _router.innerRouterOf<TabsRouter>(ShellRoute.name)?.setActiveIndex(index);
  }

  @override
  Future<void> call(String name) async {
    // Only one so far, and it is the one a definition actually needs: put the
    // screens back in touch with the server after something was fixed.
    if (name == 'yenile') getIt<RefreshRequests>().ask();
  }

  @override
  Future<void> run(String name) async {}
}
