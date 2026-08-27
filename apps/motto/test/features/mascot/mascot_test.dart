import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/mascot/application/mascot_controller.dart';
import 'package:motto/features/mascot/presentation/mascot.dart';
import 'package:rive/rive.dart';

void main() {
  group('the rules', () {
    test('being left alone calms it down', () {
      expect(
        MascotRules.decayed(100, const Duration(seconds: 5)),
        100 - MascotRules.decayPerSecond * 5,
      );
    });

    test('and never past calm', () {
      expect(MascotRules.decayed(4, const Duration(seconds: 30)), 0);
    });

    test('four pokes is enough to make it leave', () {
      // Annoyance has to be reachable by poking, or the flee state is
      // unreachable and the file carries an animation nobody sees.
      expect(MascotRules.perPoke * 4, greaterThanOrEqualTo(MascotRules.fleeAt));
    });

    test('it is annoyed before it leaves', () {
      expect(MascotRules.annoyedAt, lessThan(MascotRules.fleeAt));
    });

    test('the game is offered long after the attention nudge', () {
      // Close together they read as one twitchy character.
      expect(
        MascotRules.idleBeforeOffer,
        greaterThan(MascotRules.idleBeforeAttention * 3),
      );
    });
  });

  group('the file', () {
    /// Read as bytes rather than loaded: rive's renderer needs a native
    /// library that `flutter test` does not have, so the artboard cannot be
    /// opened here. What this can still prove is the part that actually
    /// breaks — a file delivered without one of the inputs the app drives,
    /// which would otherwise surface as a crash on the first tap.
    late String contents;

    setUpAll(() {
      contents = File(Mascot.asset).readAsStringSync(encoding: latin1);
    });

    test('carries the state machine the app looks for', () {
      expect(contents, contains(Mascot.machine));
    });

    test('carries every input the app drives', () {
      for (final input in [
        'poke',
        'annoyance',
        'drag',
        'dragX',
        'dragY',
        'flee',
        'attention',
        'offerGame',
        'celebrate',
      ]) {
        expect(contents, contains(input), reason: 'missing input: $input');
      }
    });

    test('is small enough to be worth animating constantly', () {
      // The performance brief said 300 KB. A file that grows past it is one
      // somebody added a bitmap or a blur to.
      expect(File(Mascot.asset).lengthSync(), lessThan(300 * 1024));
    });

    testWidgets('a mascot that cannot load leaves the screen alone', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Mascot(
            loadFile: (_) => Future<RiveFile>.error(StateError('no renderer')),
          ),
        ),
      );
      await tester.pump();

      // Reported, so a mascot that quietly stops existing on some devices is
      // not something anyone has to notice by eye — and the screen it sits on
      // carries on regardless.
      expect(tester.takeException(), isA<StateError>());
      expect(find.byType(Mascot), findsOneWidget);
    });
  });
}
