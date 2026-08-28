import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
              onPressed: () => context.router.replace(GameRoute()),
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
}
