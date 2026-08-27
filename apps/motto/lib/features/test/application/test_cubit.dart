import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/features/test/application/test_draft.dart';
import 'package:motto/features/test/application/test_state.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';

/// Drives the test: fetches the questions, collects the answers, and spends a
/// use at the end.
@injectable
class TestCubit extends Cubit<TestState> {
  TestCubit(
    this._tests,
    this._mottos,
    this._draft,
    this._analytics,
    this._lastArchetype,
  ) : super(const TestState());

  /// Where the glimpse is offered: past halfway, just before the point where
  /// answering starts to feel like it is going nowhere.
  static const glimpseAfter = 10;

  final api.TestResourceApi _tests;
  final api.MottoResourceApi _mottos;
  final TestDraft _draft;
  final Analytics _analytics;
  final LastArchetype _lastArchetype;

  void unawaitedStart() => unawaited(start());

  void unawaitedSubmit() => unawaited(submitSaved());

  Future<void> start() async {
    emit(state.copyWith(status: TestStatus.loading, clearError: true));

    try {
      final response = await _tests.testQuestions();
      final questions = response?.questions ?? const [];
      final resumed = _draft.read();

      emit(
        state.copyWith(
          status: TestStatus.asking,
          questions: questions,
          answers: resumed,
          // Asking the same twenty questions twice abandons the test.
          index: _firstUnanswered(questions, resumed),
        ),
      );

      // A resumed test was counted when it began; counting it twice would
      // widen the funnel at the step where people drop out.
      if (resumed.isEmpty) {
        await _analytics.record(MottoEvent.testStart);
      }
    } on Object {
      emit(
        state.copyWith(
          status: TestStatus.failed,
          errorCode: 'questions_unavailable',
        ),
      );
    }
  }

  /// Records an answer and moves on, asking for the glimpse when it is due.
  Future<void> answer(int value) async {
    final question = state.current;
    if (question == null) return;

    final answers = {...state.answers, question.id: value};
    await _draft.write(answers);

    final index = state.index + 1;
    emit(state.copyWith(answers: answers, index: index, clearGlimpse: true));

    await _analytics.record(
      MottoEvent.questionAnswered,
      properties: {'n': '$index'},
    );

    if (index == glimpseAfter) {
      await _peek(answers);
    }
  }

  void back() {
    if (state.index == 0) return;
    emit(state.copyWith(index: state.index - 1, clearGlimpse: true));
  }

  void dismissGlimpse() => emit(state.copyWith(clearGlimpse: true));

  /// The answers come from the draft rather than being carried between routes,
  /// so no cubit has to survive the route change.
  Future<void> submitSaved({bool spendSkip = false}) async {
    emit(state.copyWith(answers: _draft.read()));
    await submit(spendSkip: spendSkip);
  }

  /// Spends a use and returns the motto.
  Future<void> submit({bool spendSkip = false}) async {
    emit(state.copyWith(status: TestStatus.submitting, clearError: true));

    try {
      final result = await _mottos.claimMotto(
        api.AnswerSubmission(answers: state.answers, spendSkip: spendSkip),
      );
      // A draft that outlived a successful claim could be resumed into a
      // second charge.
      await _draft.clear();
      emit(state.copyWith(status: TestStatus.asking, result: result));

      if (result?.archetype.id case final String archetype) {
        await _lastArchetype.remember(archetype);
      }

      // The form names itself by its length, so a longer one later reports as
      // a different type without anyone inventing a word for it.
      await _analytics.record(
        MottoEvent.testComplete,
        properties: {'form_type': '${state.answers.length}_item'},
      );
    } on api.ApiException catch (failure) {
      emit(
        state.copyWith(
          status: TestStatus.failed,
          errorCode: _codeOf(failure) ?? 'claim_failed',
        ),
      );
    } on Object {
      emit(
        state.copyWith(status: TestStatus.failed, errorCode: 'claim_failed'),
      );
    }
  }

  /// Never blocks the flow: if it fails the overlay does not appear.
  Future<void> _peek(Map<String, int> answers) async {
    try {
      final glimpse = await _tests.partialResult(
        api.AnswerSubmission(answers: answers, spendSkip: false),
      );
      if (glimpse != null) emit(state.copyWith(glimpse: glimpse));
    } on Object {
      // Deliberately silent.
    }
  }

  static int _firstUnanswered(
    List<api.Question> questions,
    Map<String, int> answers,
  ) {
    for (var i = 0; i < questions.length; i++) {
      if (!answers.containsKey(questions[i].id)) return i;
    }
    return questions.length;
  }

  /// The API answers with a stable code; the message is for a log.
  static String? _codeOf(api.ApiException failure) {
    final body = failure.message;
    if (body == null) return null;
    final match = RegExp(r'"code"\s*:\s*"([a-z_]+)"').firstMatch(body);
    return match?.group(1);
  }
}
