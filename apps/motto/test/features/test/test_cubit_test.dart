import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/features/test/application/test_cubit.dart';
import 'package:motto/features/test/application/test_draft.dart';
import 'package:motto/features/test/application/test_state.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockTests extends Mock implements api.TestResourceApi {}

class _MockMottos extends Mock implements api.MottoResourceApi {}

class _MockEvents extends Mock implements api.EventResourceApi {}

/// spendSkip has no default in the generated constructor, so it is named here;
/// answers does, so it is not.
api.AnswerSubmission _submission() => api.AnswerSubmission(spendSkip: false);

api.QuestionResponse _questions(int count) => api.QuestionResponse(
  likertPoints: 5,
  questions: [
    for (var i = 1; i <= count; i++) api.Question(id: 'q$i', text: 'soru $i'),
  ],
);

void main() {
  late _MockTests tests;
  late _MockMottos mottos;
  late TestDraft draft;
  late _MockEvents events;
  late TestCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    tests = _MockTests();
    mottos = _MockMottos();
    events = _MockEvents();
    draft = TestDraft(preferences);

    registerFallbackValue(_submission());
    registerFallbackValue(api.EventBatch());

    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );

    // The real Analytics rather than a mock: nothing a screen does should get
    // slower or fail because a measurement could not be sent, and the only way
    // these tests can prove that is by having it in the way.
    cubit = TestCubit(
      tests,
      mottos,
      draft,
      Analytics(EventQueue(preferences), events),
      LastArchetype(preferences),
    );
  });

  group('start', () {
    test('asks the server for the questions', () async {
      when(() => tests.testQuestions()).thenAnswer((_) async => _questions(3));

      await cubit.start();

      expect(cubit.state.status, TestStatus.asking);
      expect(cubit.state.questions, hasLength(3));
    });

    test('resumes at the first unanswered question', () async {
      when(() => tests.testQuestions()).thenAnswer((_) async => _questions(5));
      await draft.write({'q1': 4, 'q2': 2});

      await cubit.start();

      // Asking the same twenty questions twice is how a half-finished test
      // becomes an abandoned one.
      expect(cubit.state.index, 2);
      expect(cubit.state.answers, {'q1': 4, 'q2': 2});
    });

    test('a server that will not answer leaves a retryable failure', () async {
      when(() => tests.testQuestions()).thenThrow(Exception('offline'));

      await cubit.start();

      expect(cubit.state.status, TestStatus.failed);
      expect(cubit.state.errorCode, 'questions_unavailable');
    });
  });

  group('answering', () {
    setUp(() {
      when(() => tests.testQuestions()).thenAnswer((_) async => _questions(20));
    });

    test('records the answer and moves on', () async {
      await cubit.start();

      await cubit.answer(5);

      expect(cubit.state.answers, {'q1': 5});
      expect(cubit.state.index, 1);
      expect(draft.read(), {'q1': 5});
    });

    test('the glimpse is offered once, partway through', () async {
      when(() => tests.partialResult(any())).thenAnswer(
        (_) async => api.ArchetypeResponse(
          id: 'spark',
          name: 'Kıvılcım',
          summary: 'özet',
          motto: 'motto',
          confident: false,
        ),
      );
      await cubit.start();

      for (var i = 0; i < TestCubit.glimpseAfter; i++) {
        await cubit.answer(4);
      }

      expect(cubit.state.glimpse?.name, 'Kıvılcım');
      verify(() => tests.partialResult(any())).called(1);
    });

    test('a glimpse that fails does not stop the test', () async {
      when(() => tests.partialResult(any())).thenThrow(Exception('offline'));
      await cubit.start();

      for (var i = 0; i < TestCubit.glimpseAfter; i++) {
        await cubit.answer(4);
      }

      expect(cubit.state.glimpse, isNull);
      expect(cubit.state.index, TestCubit.glimpseAfter);
      expect(cubit.state.status, TestStatus.asking);
    });

    test('going back does not go before the first question', () async {
      await cubit.start();

      cubit.back();

      expect(cubit.state.index, 0);
    });
  });

  group('submitting', () {
    test('the draft is cleared only once the answers are spent', () async {
      await draft.write({'q1': 3});
      when(() => mottos.claimMotto(any())).thenAnswer(
        (_) async => api.ResultResponse(
          id: 1,
          archetype: api.ArchetypeResponse(
            id: 'spark',
            name: 'Kıvılcım',
            summary: 'özet',
            motto: 'motto',
            confident: true,
          ),
          entitlement: api.EntitlementResponse(
            remainingUses: 1,
            skipsLeft: 1,
            premium: false,
          ),
        ),
      );

      await cubit.submitSaved();

      expect(cubit.state.result, isNotNull);
      // A draft that outlived a successful claim could be resumed into a
      // second charge.
      expect(draft.read(), isEmpty);
    });

    test(
      'a refusal keeps its code, so the app can say which rule refused',
      () async {
        await draft.write({'q1': 3});
        when(() => mottos.claimMotto(any())).thenThrow(
          api.ApiException(409, '{"code":"cooldown_open","message":"x"}'),
        );

        await cubit.submitSaved();

        expect(cubit.state.status, TestStatus.failed);
        expect(cubit.state.errorCode, 'cooldown_open');
      },
    );
  });
}
