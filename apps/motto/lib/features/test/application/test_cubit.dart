import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/features/test/application/test_draft.dart';
import 'package:motto/features/test/application/test_state.dart';

/// Drives the test: fetches the questions, collects the answers, and spends a
/// use at the end.
@injectable
class TestCubit extends Cubit<TestState> {
  TestCubit(this._tests, this._mottos, this._draft) : super(const TestState());

  /// Where the glimpse is offered. Early enough that it arrives before anyone
  /// gets bored, late enough that it is not noise: drop-off in a quiz runs a
  /// few percent per question, and this is the answer to it.
  static const glimpseAfter = 5;

  final api.TestResourceApi _tests;
  final api.MottoResourceApi _mottos;
  final TestDraft _draft;

  /// For call sites that cannot await — a widget constructor, a callback.
  /// Named rather than silently discarded so that "nobody is waiting for this"
  /// is a decision on the page rather than a lint suppressed in passing.
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
          // Resuming lands on the first unanswered question rather than at the
          // start: asking someone the same twenty questions twice is how a
          // half-finished test becomes an abandoned one.
          index: _firstUnanswered(questions, resumed),
        ),
      );
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

    if (index == glimpseAfter) {
      await _peek(answers);
    }
  }

  void back() {
    if (state.index == 0) return;
    emit(state.copyWith(index: state.index - 1, clearGlimpse: true));
  }

  void dismissGlimpse() => emit(state.copyWith(clearGlimpse: true));

  /// Submits what a previous screen collected.
  ///
  /// The answers come from the draft rather than being carried between routes:
  /// the flow spans two pages, and a cubit that has to survive a route change
  /// is a cubit that has to be hoisted above both of them for no other reason.
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
      // Cleared only once the answers have been spent: a draft that outlived a
      // successful claim could be resumed into a second charge.
      await _draft.clear();
      emit(state.copyWith(status: TestStatus.asking, result: result));
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

  /// The glimpse never blocks the flow: if it fails, the overlay simply does
  /// not appear and the person keeps answering.
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

  /// The API answers with a stable code; the message is for a log, not a user.
  static String? _codeOf(api.ApiException failure) {
    final body = failure.message;
    if (body == null) return null;
    final match = RegExp(r'"code"\s*:\s*"([a-z_]+)"').firstMatch(body);
    return match?.group(1);
  }
}
