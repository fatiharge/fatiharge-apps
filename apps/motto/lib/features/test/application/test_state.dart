import 'package:api_client_motto/api.dart' as api;

enum TestStatus { idle, loading, asking, submitting, failed }

/// What the test flow is doing and what it has collected so far.
class TestState {
  const TestState({
    this.status = TestStatus.idle,
    this.questions = const [],
    this.answers = const {},
    this.index = 0,
    this.glimpse,
    this.result,
    this.errorCode,
  });

  final TestStatus status;
  final List<api.Question> questions;

  /// Item id to a point on the scale. A map rather than a list so that a draft
  /// stays readable when the question order changes.
  final Map<String, int> answers;

  final int index;

  /// The look shown partway through. It costs nothing, which is the point.
  final api.ArchetypeResponse? glimpse;

  final api.ResultResponse? result;
  final String? errorCode;

  bool get isFinished => questions.isNotEmpty && index >= questions.length;

  api.Question? get current =>
      index < questions.length ? questions[index] : null;

  double get progress =>
      questions.isEmpty ? 0 : (index / questions.length).clamp(0, 1);

  TestState copyWith({
    TestStatus? status,
    List<api.Question>? questions,
    Map<String, int>? answers,
    int? index,
    api.ArchetypeResponse? glimpse,
    api.ResultResponse? result,
    String? errorCode,
    bool clearGlimpse = false,
    bool clearError = false,
  }) => TestState(
    status: status ?? this.status,
    questions: questions ?? this.questions,
    answers: answers ?? this.answers,
    index: index ?? this.index,
    glimpse: clearGlimpse ? null : (glimpse ?? this.glimpse),
    result: result ?? this.result,
    errorCode: clearError ? null : (errorCode ?? this.errorCode),
  );
}
