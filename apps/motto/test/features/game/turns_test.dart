import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/game/application/turns_repository.dart';
import 'package:motto/infrastructure/api/outcome.dart';

class _MockTurns extends Mock implements api.PlayResourceApi {}

void main() {
  late _MockTurns api_;
  late TurnsRepository turns;

  setUp(() {
    api_ = _MockTurns();
    turns = TurnsRepository(api_)..now = () => DateTime(2026, 8, 30);
  });

  group('a turn at the game', () {
    test("is spent against the phone's own date", () async {
      when(
        () => api_.spendGameTurn(today: any(named: 'today')),
      ).thenAnswer((_) async => null);

      await turns.spend();

      // A day is only ever a local day, the way the chain counts them.
      verify(() => api_.spendGameTurn(today: '2026-08-30')).called(1);
    });

    test('running out comes back named', () async {
      when(() => api_.spendGameTurn(today: any(named: 'today'))).thenThrow(
        api.ApiException(
          409,
          '{"code":"no_turns_yet","message":"…","traceId":"t"}',
        ),
      );

      // The name is what decides which of the two sentences somebody reads,
      // and the app used to work that out from flags — wrongly, whenever the
      // day was still unmarked.
      final outcome = await turns.spend();
      final trouble = (outcome as Failed<api.PlayCredits?>).trouble;
      expect((trouble as Refused).code, 'no_turns_yet');
    });
  });
}
