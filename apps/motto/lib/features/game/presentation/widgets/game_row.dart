import 'package:flutter/material.dart';
import 'package:motto/features/chain/application/chain_state.dart';
import 'package:motto/features/game/presentation/open_game.dart';

/// The way into the game, offered once the day is marked.
///
/// On Görevler rather than Bugün, under the button that just closed the day:
/// this is the screen where the work happens, and a reward belongs where it
/// was earned. Shown on a schedule rather than at random, because a card
/// somebody sees once and cannot find again is a card they read as a bug.
///
/// The mascot still offers it. This is the door for the people who switched
/// the mascot off, and for everybody who never sat still long enough to be
/// asked — which, until it was fixed, was everybody.
class GameRow extends StatelessWidget {
  const GameRow._();

  /// Null until today is marked, and null again once the turns are gone.
  ///
  /// A card that answers a tap with "you have none" is worse than a card that
  /// was not there: the reward is supposed to be the thing waiting for you,
  /// not a door that opens onto a refusal.
  static Widget? forDay(ChainState chain, DateTime now, {required bool any}) =>
      chain.markedToday(now) && any ? const GameRow._() : null;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: openGame,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUGÜNÜ İŞARETLEDİN',
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Bir tur at', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Haftanın ilk 10 skoru bir derin rapor kazanıyor.',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
