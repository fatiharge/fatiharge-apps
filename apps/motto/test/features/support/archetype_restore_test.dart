import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/support/application/archetype_restore.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockResults extends Mock implements api.ResultResourceApi {}

api.ResultSummary _summary(int id, String archetype, DateTime claimedAt) =>
    api.ResultSummary(
      id: id,
      archetype: api.ArchetypeResponse(
        id: archetype,
        name: 'Gece Nöbetçisi',
        summary: 'Sen fark ettiğinde iş henüz olmamıştır.',
        motto: 'Tetikte olmak da bir güç, dinlenmek de.',
        confident: true,
      ),
      profile: api.ProfileScores(
        openness: 0.5,
        conscientiousness: 0.5,
        extraversion: 0.5,
        agreeableness: 0.5,
        neuroticism: 0.5,
      ),
      claimedAt: claimedAt,
    );

void main() {
  late _MockResults results;
  late LastArchetype last;
  late ArchetypeRestore restore;

  Future<void> build({Map<String, Object> stored = const {}}) async {
    SharedPreferences.setMockInitialValues(stored);
    results = _MockResults();
    last = LastArchetype(await SharedPreferences.getInstance());
    restore = ArchetypeRestore(results, last);
  }

  group('ArchetypeRestore', () {
    test('asks nothing when the phone already knows', () async {
      await build(stored: {'last_archetype': 'night_watch'});

      await restore.ensure();

      // Every launch but the first after a reinstall takes this path, so it
      // must not cost a request.
      verifyNever(() => results.resultHistory());
      expect(last.id, 'night_watch');
    });

    test('takes the newest result back from the server', () async {
      await build();
      when(() => results.resultHistory()).thenAnswer(
        (_) async => api.ResultHistory(
          results: [
            _summary(9, 'night_watch', DateTime(2026, 8, 20)),
            _summary(4, 'quiet_builder', DateTime(2026, 5, 2)),
          ],
        ),
      );

      await restore.ensure();

      // The chain and the results outlive the app; the preference does not,
      // and it is what decides whether the inventory is asked for again.
      expect(last.id, 'night_watch');
      expect(last.resultId, 9);
    });

    test('leaves a device that has never had a result alone', () async {
      await build();
      when(
        () => results.resultHistory(),
      ).thenAnswer((_) async => api.ResultHistory());

      await restore.ensure();

      expect(last.id, isNull);
    });
  });
}
