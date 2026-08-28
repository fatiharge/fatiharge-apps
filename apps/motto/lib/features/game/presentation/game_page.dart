import 'dart:async';
import 'dart:math';

import 'package:api_client_motto/api.dart' as api;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/domain/sorting_game.dart';
import 'package:motto/route/app_router.gr.dart';

/// The game itself.
///
/// One thing falls at a time and the whole screen is the control: two bins,
/// tap the side it belongs on. A drag target on a falling object is a game
/// about dexterity, and this one is about noticing.
@RoutePage()
class GamePage extends StatefulWidget {
  const GamePage({this.random, super.key});

  /// Seedable, so a test can play a known round.
  final Random? random;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late final Random _random = widget.random ?? Random();
  late SortingGame _game = SortingGame.start(_random);
  late final AnimationController _fall = AnimationController(vsync: this)
    ..addStatusListener(_onLanded);

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _drop();
  }

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  void _drop() {
    _fall.duration = _game.fall;
    unawaited(_fall.forward(from: 0));
  }

  void _onLanded(AnimationStatus status) {
    if (status != AnimationStatus.completed || _game.over) return;
    setState(() => _game = _game.missed(_random));
    _afterMove();
  }

  void _sort(Bin into) {
    if (_game.over) return;
    setState(() => _game = _game.sort(into, _random));
    _afterMove();
  }

  void _afterMove() {
    if (_game.over) {
      _fall.stop();
      unawaited(_finish());
      return;
    }
    _drop();
  }

  Future<void> _finish() async {
    if (_submitted) return;
    _submitted = true;

    api.Leaderboard? board;
    try {
      board = await getIt<api.ScoreResourceApi>().recordScore(
        api.ScoreSubmission(points: _game.score),
      );
    } on Object {
      // A score that could not be sent is still a score somebody made. The
      // board simply has nothing to show.
      board = null;
    }

    if (!mounted) return;
    await context.router.replace(
      GameOverRoute(score: _game.score, board: board),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final left = _game.thing.bin == Bin.left;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_game.score}', style: text.headlineSmall),
                  Row(
                    children: [
                      for (var life = 0;
                          life < SortingGame.startingLives;
                          life++)
                        Icon(
                          life < _game.lives
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: scheme.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _Half(
                      bin: Bin.left,
                      onTap: () => _sort(Bin.left),
                      falling: _fall,
                      showThing: left,
                      colour: scheme.primary,
                      label: 'Sol',
                      scheme: scheme,
                      text: text,
                    ),
                  ),
                  Expanded(
                    child: _Half(
                      bin: Bin.right,
                      onTap: () => _sort(Bin.right),
                      falling: _fall,
                      showThing: !left,
                      colour: scheme.tertiary,
                      label: 'Sağ',
                      scheme: scheme,
                      text: text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({
    required this.bin,
    required this.onTap,
    required this.falling,
    required this.showThing,
    required this.colour,
    required this.label,
    required this.scheme,
    required this.text,
  });

  final Bin bin;
  final VoidCallback onTap;
  final Animation<double> falling;
  final bool showThing;
  final Color colour;
  final String label;
  final ColorScheme scheme;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: colour, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(label, style: text.labelLarge),
              ),
            ),
          ),
          if (showThing)
            AnimatedBuilder(
              animation: falling,
              builder: (context, _) => Align(
                alignment: Alignment(0, -1 + 1.7 * falling.value),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colour,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
