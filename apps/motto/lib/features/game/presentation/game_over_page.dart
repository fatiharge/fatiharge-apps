import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/application/turns_repository.dart';
import 'package:motto/features/game/presentation/no_turns_sheet.dart';
import 'package:motto/route/app_router.gr.dart';

/// The score, and where it sits.
///
/// The board is shown even when the score did not reach it: a leaderboard you
/// only see when you win is a leaderboard that tells you nothing about whether
/// playing again is worth it.
@RoutePage()
class GameOverPage extends StatelessWidget {
  const GameOverPage({required this.score, this.board, super.key});

  final int score;
  final api.Leaderboard? board;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final entries = board?.entries ?? const <api.LeaderboardEntry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Skor')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Text('$score', style: text.displaySmall),
            const SizedBox(height: 4),
            Text(
              'puan',
              style: text.titleMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            if (board == null)
              Text(
                'Skor gönderilemedi. Bağlantın gelince tekrar dene.',
                style: text.bodyMedium?.copyWith(color: scheme.error),
              )
            else ...[
              Text('Bu hafta', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${entry.rank}.',
                        style: entry.you
                            ? text.titleMedium?.copyWith(color: scheme.primary)
                            : text.bodyLarge,
                      ),
                      Text(
                        '${entry.points}',
                        style: entry.you
                            ? text.titleMedium?.copyWith(color: scheme.primary)
                            : text.bodyLarge,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'İlk ${board!.rewardedRanks} bir derin rapor kazanıyor.',
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              // A second game is a second turn. Replacing the route without
              // paying for it would make the first turn the only one anybody
              // ever spends.
              onPressed: () => unawaited(_again(context)),
              child: const Text('Tekrar oyna'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.router.maybePop(),
              child: const Text('Bitir'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _again(BuildContext context) async {
    final router = context.router;
    final turns = getIt<TurnsRepository>();

    try {
      if (!await turns.spend()) {
        if (!context.mounted) return;
        final left = await turns.today();
        if (!context.mounted) return;
        // Both halves, not just the tasks: a day whose three things are done
        // but whose mark is still outstanding has a turn waiting in it.
        await NoTurnsSheet.show(
          context,
          nothingLeftToEarn:
              (left?.dayMarked ?? false) && (left?.tasksDone ?? false),
        );
        return;
      }
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyunu şu an açamıyorum.')),
      );
      return;
    }

    await router.replace(GameRoute());
  }
}
