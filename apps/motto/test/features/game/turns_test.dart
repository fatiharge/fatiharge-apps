import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/game/application/turns_repository.dart';
import 'package:motto/features/game/presentation/no_turns_sheet.dart';

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

    test('is refused rather than thrown when there is none', () async {
      when(() => api_.spendGameTurn(today: any(named: 'today'))).thenThrow(
        api.ApiException(409, 'no_turns_left'),
      );

      // The screen has something to say about this one, so it is an answer
      // rather than a failure.
      expect(await turns.spend(), isFalse);
    });

    test('a failure that is not a refusal stays a failure', () async {
      when(
        () => api_.spendGameTurn(today: any(named: 'today')),
      ).thenThrow(api.ApiException(500, 'boom'));

      expect(turns.spend(), throwsA(isA<api.ApiException>()));
    });
  });

  group('when there is no turn left', () {
    Future<void> open(
      WidgetTester tester, {
      required bool nothingLeftToEarn,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => NoTurnsSheet.show(
                    context,
                    nothingLeftToEarn: nothingLeftToEarn,
                  ),
                  child: const Text('aç'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('aç'));
      await tester.pumpAndSettle();
    }

    testWidgets('somebody with something still to earn is sent to it', (
      tester,
    ) async {
      await open(tester, nothingLeftToEarn: false);

      // There is still something to earn today, so sending them away with
      // "come back tomorrow" would be sending them away from the answer.
      expect(find.text('Önce görevini bitir, hakkını kazan.'), findsOneWidget);
      expect(find.text('Görevlere git'), findsOneWidget);
    });

    testWidgets('somebody who has finished is told to come back', (
      tester,
    ) async {
      await open(tester, nothingLeftToEarn: true);

      expect(
        find.text(
          'Bugünlük tüm haklarını bitirdin. Yeni hak için yarınki '
          'görevlerini bekle.',
        ),
        findsOneWidget,
      );
      expect(find.text('Görevlere git'), findsNothing);
    });
  });
}
