import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/application/game_store.dart';
import 'package:motto/features/game/domain/sorting_game.dart';
import 'package:motto/route/app_router.gr.dart';

/// The rules, before the first game and never again.
///
/// Explained rather than discovered: three lives is short enough that learning
/// the game by losing it is learning that it is not worth playing.
@RoutePage()
class GameRulesPage extends StatelessWidget {
  const GameRulesPage({this.onStart, super.key});

  final Future<void> Function(BuildContext)? onStart;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('gameRules.title'.tr())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Rule(
                title: 'gameRules.sortTitle'.tr(),
                body: 'gameRules.sortBody'.tr(),
                text: text,
              ),
              _Rule(
                title: 'gameRules.livesTitle'.tr(),
                body: 'gameRules.livesBody'.tr(),
                text: text,
              ),
              _Rule(
                title: 'gameRules.pointsTitle'.tr(
                  namedArgs: {'points': '${SortingGame.perSort}'},
                ),
                body: 'gameRules.pointsBody'.tr(
                  namedArgs: {'every': '${SortingGame.speedsUpEvery}'},
                ),
                text: text,
              ),
              const Spacer(),
              Text(
                'gameRules.rewardNote'.tr(),
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await getIt<GameStore>().markRulesSeen();
                  if (!context.mounted) return;
                  final start = onStart ?? _push;
                  await start(context);
                },
                child: Text('gameRules.start'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _push(BuildContext context) =>
      context.router.replace(GameRoute());
}

class _Rule extends StatelessWidget {
  const _Rule({required this.title, required this.body, required this.text});

  final String title;
  final String body;
  final TextTheme text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleMedium),
        const SizedBox(height: 6),
        Text(body, style: text.bodyMedium),
      ],
    ),
  );
}
