import 'dart:math';

import 'package:meta/meta.dart';

/// Which bin a falling thing belongs in.
enum Bin { left, right }

@immutable
class FallingThing {
  const FallingThing({required this.bin, required this.seed});

  final Bin bin;

  /// Decides its shape and colour, so the same round looks the same twice.
  final int seed;
}

/// The whole game, without a frame in sight.
///
/// Every rule that decides whether somebody won is here rather than in the
/// widget: a game whose scoring lives in a build method is a game that cannot
/// be argued with in a test.
@immutable
class SortingGame {
  const SortingGame({
    required this.thing,
    required this.next,
    this.score = 0,
    this.lives = startingLives,
    this.sorted = 0,
  });

  factory SortingGame.start(Random random) => SortingGame(
    thing: _spawn(random),
    next: _spawn(random),
  );

  static const startingLives = 3;

  /// What one correct sort is worth before the run bonus.
  static const perSort = 10;

  /// Every this many in a row, the thing falls faster.
  static const speedsUpEvery = 5;

  static const firstFall = Duration(milliseconds: 1600);
  static const fastestFall = Duration(milliseconds: 520);

  final FallingThing thing;
  final FallingThing next;
  final int score;
  final int lives;

  /// Correct sorts in this run. Speed comes off this, not off the score, so a
  /// long careful run and a short lucky one are not the same thing.
  final int sorted;

  bool get over => lives <= 0;

  /// How long this thing takes to fall. Shortens in steps rather than
  /// continuously: a difficulty that creeps is a difficulty nobody notices,
  /// and noticing it is the game.
  Duration get fall {
    final steps = sorted ~/ speedsUpEvery;
    final ms = firstFall.inMilliseconds - steps * 140;
    return Duration(
      milliseconds: max(fastestFall.inMilliseconds, ms),
    );
  }

  SortingGame sort(Bin into, Random random) {
    if (over) return this;

    if (into != thing.bin) {
      // A wrong answer costs a life and the run, but not the score: taking
      // points away for a mistake reads as punishment, and this is a toy.
      return SortingGame(
        thing: next,
        next: _spawn(random),
        score: score,
        lives: lives - 1,
      );
    }

    return SortingGame(
      thing: next,
      next: _spawn(random),
      score: score + perSort,
      lives: lives,
      sorted: sorted + 1,
    );
  }

  /// Letting one land is the same as putting it in the wrong bin. Otherwise
  /// waiting is a strategy.
  SortingGame missed(Random random) => sort(
    thing.bin == Bin.left ? Bin.right : Bin.left,
    random,
  );

  static FallingThing _spawn(Random random) => FallingThing(
    bin: random.nextBool() ? Bin.left : Bin.right,
    seed: random.nextInt(1 << 30),
  );
}
