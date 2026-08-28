import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:utility_kit/src/base/effect_channel.dart';
import 'package:utility_kit/src/base/effect_source.dart';

/// Runs [onEffect] once for each effect, and nothing on a rebuild.
///
/// The presentation half of [EffectChannel]. A `BlocListener` with a
/// `listenWhen` comparing two states is the usual way to do this and it is a
/// guess: it asks "did this field change?" when the question is "did this
/// happen?". Rebuilds, an identical state emitted twice, or a screen rebuilt
/// after the fact all give the wrong answer.
///
/// ```dart
/// EffectListener<TestCubit, TestEffect>(
///   bloc: context.read<TestCubit>(),
///   onEffect: (context, effect) => switch (effect) {
///     AnsweringFinished() => context.router.replace(const CalculatingRoute()),
///     _ => null,
///   },
///   child: BlocBuilder<TestCubit, TestState>(builder: …),
/// )
/// ```
class EffectListener<B extends EffectSource<Effect>, Effect>
    extends StatefulWidget {
  const EffectListener({
    required this.bloc,
    required this.onEffect,
    required this.child,
    super.key,
  });

  /// The bloc or cubit to listen to.
  final B bloc;

  final void Function(BuildContext context, Effect effect) onEffect;

  final Widget child;

  @override
  State<EffectListener<B, Effect>> createState() =>
      _EffectListenerState<B, Effect>();
}

class _EffectListenerState<B extends EffectSource<Effect>, Effect>
    extends State<EffectListener<B, Effect>> {
  StreamSubscription<Effect>? _subscription;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(covariant EffectListener<B, Effect> old) {
    super.didUpdateWidget(old);
    if (!identical(old.bloc, widget.bloc)) {
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
