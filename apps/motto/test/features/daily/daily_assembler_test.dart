import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/daily/domain/content_pack.dart';
import 'package:motto/features/daily/domain/daily_assembler.dart';

/// The real package, not a fixture: a test that invents its own content proves
/// the assembler works on content nobody ships.
ContentPack loadPack() => ContentPack.fromJson(
  jsonDecode(File('assets/content/bundle.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  late ContentPack pack;
  late List<String> archetypes;

  setUp(() {
    pack = loadPack();
    archetypes = {for (final f in pack.fragments) f.archetypeId}.toList()
      ..sort();
  });

  group('the day index', () {
    test('a chain that has not started is on day one', () {
      expect(DailyAssembler.dayIndex(0), 1);
    });

    test('it follows the chain', () {
      expect(DailyAssembler.dayIndex(1), 1);
      expect(DailyAssembler.dayIndex(7), 7);
      expect(DailyAssembler.dayIndex(14), 14);
    });

    test('it wraps rather than running out', () {
      // A chain that outlives the content is a good problem; repeating beats
      // stopping.
      expect(DailyAssembler.dayIndex(15), 1);
      expect(DailyAssembler.dayIndex(28), 14);
    });
  });

  group('assembly', () {
    test('nothing is said to someone who has not taken the inventory', () {
      final day = DailyAssembler.assemble(
        pack: pack,
        archetypeId: null,
        daysMarked: 1,
      );

      expect(day, isNull);
    });

    test('all 112 combinations read, and none of them is empty', () {
      for (final archetype in archetypes) {
        for (var marked = 1; marked <= DailyAssembler.cycleDays; marked++) {
          final day = DailyAssembler.assemble(
            pack: pack,
            archetypeId: archetype,
            daysMarked: marked,
          );

          expect(day, isNotNull, reason: '$archetype day $marked');
          expect(day!.title.trim(), isNotEmpty);
          expect(day.body.trim(), isNotEmpty);
          expect(day.connector.trim(), isNotEmpty);
          expect(day.fragment.trim(), isNotEmpty);
          expect(day.action.trim(), isNotEmpty);
          expect(day.motto.trim(), isNotEmpty);
        }
      }
    });

    test('fourteen days are fourteen different days', () {
      for (final archetype in archetypes) {
        final texts = [
          for (var marked = 1; marked <= DailyAssembler.cycleDays; marked++)
            DailyAssembler.assemble(
              pack: pack,
              archetypeId: archetype,
              daysMarked: marked,
            )!.text,
        ];

        // The whole promise of this feature is daily freshness. Two identical
        // days inside one run is the failure that would only be noticed by
        // someone who already stopped opening the app.
        expect(
          texts.toSet(),
          hasLength(DailyAssembler.cycleDays),
          reason: archetype,
        );
      }
    });

    test('the same fragment never lands two days running', () {
      for (final archetype in archetypes) {
        String? previous;
        for (var marked = 1; marked <= DailyAssembler.cycleDays; marked++) {
          final fragment = DailyAssembler.assemble(
            pack: pack,
            archetypeId: archetype,
            daysMarked: marked,
          )!.fragment;

          expect(fragment, isNot(previous), reason: '$archetype day $marked');
          previous = fragment;
        }
      }
    });

    test('each archetype hears only its own fragments', () {
      for (final archetype in archetypes) {
        final mine = {
          for (final fragment in pack.fragmentsFor(archetype)) fragment.text,
        };
        for (var marked = 1; marked <= DailyAssembler.cycleDays; marked++) {
          final day = DailyAssembler.assemble(
            pack: pack,
            archetypeId: archetype,
            daysMarked: marked,
          )!;

          expect(mine, contains(day.fragment));
        }
      }
    });

    test('the motto is the one on their card, and it does not move', () {
      for (final archetype in archetypes) {
        final mottos = {
          for (var marked = 1; marked <= DailyAssembler.cycleDays; marked++)
            DailyAssembler.assemble(
              pack: pack,
              archetypeId: archetype,
              daysMarked: marked,
            )!.motto,
        };

        // The day changes; the motto is the thing that does not.
        expect(mottos, hasLength(1), reason: archetype);
      }
    });

    test('an archetype nobody wrote for says nothing at all', () {
      final day = DailyAssembler.assemble(
        pack: pack,
        archetypeId: 'no_such_archetype',
        daysMarked: 3,
      );

      expect(day, isNull);
    });
  });
}
