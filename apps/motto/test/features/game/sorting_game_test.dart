import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/game/domain/sorting_game.dart';

void main() {
  late Random random;

  setUp(() => random = Random(7));

  SortingGame started() => SortingGame.start(random);

  test('a run starts with three lives and nothing scored', () {
    final game = started();

    expect(game.lives, SortingGame.startingLives);
    expect(game.score, 0);
    expect(game.over, isFalse);
  });

  test('the right bin scores and keeps the run', () {
    final game = started();

    final after = game.sort(game.thing.bin, random);

    expect(after.score, SortingGame.perSort);
    expect(after.lives, SortingGame.startingLives);
    expect(after.sorted, 1);
  });

  test('the wrong bin costs a life and the run, but not the score', () {
    final game = started().sort(started().thing.bin, random);
    final before = game.score;

    final after = game.sort(
      game.thing.bin == Bin.left ? Bin.right : Bin.left,
      random,
    );

    // Taking points away reads as punishment, and this is a toy.
    expect(after.score, before);
    expect(after.lives, SortingGame.startingLives - 1);
    expect(after.sorted, 0);
  });

  test('three mistakes end it', () {
    var game = started();
    for (var i = 0; i < SortingGame.startingLives; i++) {
      game = game.sort(
        game.thing.bin == Bin.left ? Bin.right : Bin.left,
        random,
      );
    }

    expect(game.over, isTrue);
  });

  test('letting one land is the same as getting it wrong', () {
    final game = started();

    final after = game.missed(random);

    // Otherwise waiting is a strategy.
    expect(after.lives, SortingGame.startingLives - 1);
  });

  test('a finished game does not carry on', () {
    var game = started();
    for (var i = 0; i < 5; i++) {
      game = game.sort(
        game.thing.bin == Bin.left ? Bin.right : Bin.left,
        random,
      );
    }

    expect(game.lives, 0);
    expect(game.score, 0);
  });

  test('it speeds up in steps, and stops speeding up', () {
    var game = started();
    final first = game.fall;

    for (var i = 0; i < SortingGame.speedsUpEvery; i++) {
      game = game.sort(game.thing.bin, random);
    }
    expect(game.fall, lessThan(first));

    for (var i = 0; i < 200; i++) {
      game = game.sort(game.thing.bin, random);
    }
    // A game that keeps getting faster is a game that becomes impossible
    // rather than hard.
    expect(game.fall, SortingGame.fastestFall);
  });

  test('the run resets the speed, not the score', () {
    var game = started();
    for (var i = 0; i < SortingGame.speedsUpEvery; i++) {
      game = game.sort(game.thing.bin, random);
    }
    final fast = game.fall;

    game = game.sort(
      game.thing.bin == Bin.left ? Bin.right : Bin.left,
      random,
    );

    expect(game.fall, greaterThan(fast));
    expect(game.score, SortingGame.perSort * SortingGame.speedsUpEvery);
  });
}
