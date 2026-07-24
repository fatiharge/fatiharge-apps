import 'dart:async';

import 'package:bloc/bloc.dart';

/// A [Bloc] that emits one-shot side effects (navigation, snackbar, toast, …)
/// on a separate channel alongside its regular state stream.
///
/// State describes *what to render*; an [Effect] describes *something to do
/// once* and should not be rebuilt from state. Listen to [effects] from the
/// presentation layer and call [emitEffect] from event handlers.
///
/// ```dart
/// class MyBloc extends EffectBloc<MyEvent, MyState, MyEffect> {
///   MyBloc() : super(const MyState.initial()) {
///     on<Submitted>((event, emit) => emitEffect(const MyEffect.showToast()));
///   }
/// }
/// ```
abstract class EffectBloc<Event, State, Effect> extends Bloc<Event, State> {
  EffectBloc(super.initialState);

  final _effects = StreamController<Effect>.broadcast();

  /// One-shot side effects emitted by this bloc.
  Stream<Effect> get effects => _effects.stream;

  /// Pushes a single [effect] to [effects] listeners.
  void emitEffect(Effect effect) => _effects.add(effect);

  @override
  Future<void> close() async {
    await _effects.close();
    return super.close();
  }
}
