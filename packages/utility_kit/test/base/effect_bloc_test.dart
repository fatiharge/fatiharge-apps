import 'package:flutter_test/flutter_test.dart';
import 'package:utility_kit/utility_kit.dart';

sealed class _Event {}

final class _Ping extends _Event {}

enum _Effect { pong }

class _TestBloc extends EffectBloc<_Event, int, _Effect> {
  _TestBloc() : super(0) {
    on<_Ping>((event, emit) {
      emit(state + 1);
      emitEffect(_Effect.pong);
    });
  }
}

void main() {
  group('EffectBloc', () {
    test('emits state and side effect independently', () async {
      final bloc = _TestBloc();
      addTearDown(bloc.close);

      final stateEmitted = expectLater(bloc.stream, emits(1));
      final effectEmitted = expectLater(bloc.effects, emits(_Effect.pong));

      bloc.add(_Ping());

      await Future.wait([stateEmitted, effectEmitted]);
    });

    test('effects is a broadcast stream (allows multiple listeners)', () {
      final bloc = _TestBloc();
      addTearDown(bloc.close);

      expect(bloc.effects.isBroadcast, isTrue);
    });

    test('closes the effects channel on close', () async {
      final bloc = _TestBloc();
      await bloc.close();

      expect(bloc.effects.drain<void>(), completes);
    });
  });
}
