import 'package:bloc/bloc.dart';
import 'package:utility_kit/src/base/effect_bloc.dart';
import 'package:utility_kit/src/base/effect_channel.dart';

/// A [Cubit] that emits one-shot side effects alongside its state.
///
/// The cubit half of [EffectBloc]: same channel, no events. Most screens here
/// are cubits, and converting one to an event-driven bloc just to be able to
/// navigate once is a large change for a small need.
///
/// ```dart
/// class TestCubit extends EffectCubit<TestState, TestEffect> {
///   TestCubit() : super(const TestState());
///
///   void finish() => emitEffect(const AnsweringFinished());
/// }
/// ```
abstract class EffectCubit<State, Effect> extends Cubit<State>
    with EffectChannel<Effect, State> {
  EffectCubit(super.initialState);
}
