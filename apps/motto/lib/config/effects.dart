import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

/// A one-shot channel beside the state.
///
/// Navigation, sheets and snackbars are not state: they happen once and then
/// they are over. Deriving them from a state difference — `listenWhen` with
/// `previous.x != current.x` — is inferring an event from its own aftermath,
/// and the aftermath outlives the event. `result != null` stays true long
/// after the result was opened, so nothing downstream can tell "just arrived"
/// from "arrived a while ago", and a state emitted twice either fires twice or
/// not at all.
mixin Effects<E, S> on BlocBase<S> {
  final _effects = StreamController<E>.broadcast();

  Stream<E> get effects => _effects.stream;

  void effect(E effect) {
    if (!_effects.isClosed) _effects.add(effect);
  }

  @override
  Future<void> close() async {
    await _effects.close();
    await super.close();
  }
}

/// Runs [onEffect] for each effect and nothing on a rebuild.
class EffectListener<B extends Effects<E, Object?>, E> extends StatefulWidget {
  const EffectListener({
    required this.bloc,
    required this.onEffect,
    required this.child,
    super.key,
  });

  final B bloc;
  final void Function(BuildContext, E) onEffect;
  final Widget child;

  @override
  State<EffectListener<B, E>> createState() => _EffectListenerState<B, E>();
}

class _EffectListenerState<B extends Effects<E, Object?>, E>
    extends State<EffectListener<B, E>> {
  StreamSubscription<E>? _subscription;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(covariant EffectListener<B, E> old) {
    super.didUpdateWidget(old);
    if (old.bloc != widget.bloc) {
      unawaited(_subscription?.cancel());
      _listen();
    }
  }

  void _listen() {
    _subscription = widget.bloc.effects.listen((effect) {
      if (mounted) widget.onEffect(context, effect);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
