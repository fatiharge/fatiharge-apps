import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:utility_kit/src/base/effect_source.dart';

/// A one-shot channel beside the state, for a [Bloc] or a [Cubit].
///
/// State describes *what to render*; an effect describes *something to do
/// once* — navigate, open a sheet, show a snackbar. Deriving those from a
/// state difference infers an event from its own aftermath, and the aftermath
/// outlives the event: a flag saying "there is a result" stays true long after
/// the result was opened, so nothing downstream can tell "just arrived" from
/// "arrived a while ago".
mixin EffectChannel<Effect, State> on BlocBase<State>
    implements EffectSource<Effect> {
  /// Single-subscription on purpose, not broadcast.
  ///
  /// A broadcast stream drops whatever is emitted before somebody is
  /// listening, and the gap between a bloc being built and its screen
  /// subscribing is exactly where the first effect lands. This one holds what
  /// it has until the screen arrives. One screen listens to one bloc, so the
  /// single subscription costs nothing.
  final _effects = StreamController<Effect>();

  /// One-shot side effects. Listen once, from the presentation layer.
  @override
  Stream<Effect> get effects => _effects.stream;

  /// Pushes a single [effect] to whoever is — or will be — listening.
  void emitEffect(Effect effect) {
    if (!_effects.isClosed) _effects.add(effect);
  }

  @override
  Future<void> close() {
    // Not awaited: closing a single-subscription controller that nobody ever
    // listened to does not complete until somebody does, so awaiting it hangs
    // the close of any bloc whose screen was never opened.
    unawaited(_effects.close());
    return super.close();
  }
}
