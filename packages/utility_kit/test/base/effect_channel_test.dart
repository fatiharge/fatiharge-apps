import 'package:flutter_test/flutter_test.dart';
import 'package:utility_kit/utility_kit.dart';

class _Counter extends EffectCubit<int, String> {
  _Counter() : super(0);

  void shout(String what) => emitEffect(what);
}

void main() {
  test('an effect fired before anybody listens is still delivered', () async {
    // The gap between a cubit being built and its screen subscribing is where
    // the first effect lands. A broadcast channel drops it and the screen sits
    // waiting for something that already happened.
    final cubit = _Counter()..shout('early');

    expect(await cubit.effects.first, 'early');
    await cubit.close();
  });

  test('effects arrive in the order they were fired', () async {
    final cubit = _Counter()
      ..shout('one')
      ..shout('two');

    expect(await cubit.effects.take(2).toList(), ['one', 'two']);
    await cubit.close();
  });

  // Closing a single-subscription channel nobody listened to does not complete
  // until somebody does, so awaiting it would hang the close of every bloc
  // whose screen was never opened.
  test('a cubit nobody listened to still closes', () async {
    final cubit = _Counter()..shout('into the void');

    await expectLater(cubit.close(), completes);
  });

  test('an effect after close is dropped rather than thrown', () async {
    final cubit = _Counter();
    await cubit.close();

    expect(() => cubit.shout('too late'), returnsNormally);
  });
}
