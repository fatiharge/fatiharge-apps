import 'package:api_client_motto/api.dart' as api;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/features/support/application/support_context.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';

enum FeedbackStatus { editing, sending, sent, failed }

@immutable
class FeedbackState {
  const FeedbackState({
    this.kind = api.FeedbackKind.SUGGESTION,
    this.status = FeedbackStatus.editing,
  });

  final api.FeedbackKind kind;
  final FeedbackStatus status;

  FeedbackState copyWith({api.FeedbackKind? kind, FeedbackStatus? status}) =>
      FeedbackState(kind: kind ?? this.kind, status: status ?? this.status);
}

/// Sends what someone wrote.
@injectable
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit(this._feedback, this._context, this._analytics)
    : super(const FeedbackState());

  final api.FeedbackResourceApi _feedback;
  final SupportContext _context;
  final Analytics _analytics;

  void chooseKind(api.FeedbackKind kind) => emit(state.copyWith(kind: kind));

  Future<void> send({required String message, String? email}) async {
    emit(state.copyWith(status: FeedbackStatus.sending));

    try {
      await _feedback.submitFeedback(
        api.FeedbackRequest(
          kind: state.kind,
          message: message,
          email: email,
          context: await _context.collect(),
        ),
      );
      emit(state.copyWith(status: FeedbackStatus.sent));
      await _analytics.record(
        MottoEvent.feedbackSubmit,
        properties: {'type': state.kind.name.toLowerCase()},
      );
    } on Object {
      emit(state.copyWith(status: FeedbackStatus.failed));
    }
  }

  /// The rejection is feedback with a fixed kind and no form around it: asking
  /// someone who just said "this is not me" to write an essay gets nothing.
  Future<void> rejectArchetype(String reason) async {
    emit(state.copyWith(kind: api.FeedbackKind.ARCHETYPE_REJECTED));
    await send(message: reason);
    await _analytics.record(MottoEvent.archetypeRejected);
  }
}
