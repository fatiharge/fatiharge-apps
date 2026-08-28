import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utility_kit/utility_kit.dart';

class _Counter extends EffectCubit<int, String> {
  _Counter() : super(0);

  void shout(String what) => emitEffect(what);
}

void main() {
  testWidgets('it runs once per effect and not on a rebuild', (tester) async {
    final cubit = _Counter();
    final heard = <String>[];

    Widget tree(String label) => MaterialApp(
      home: EffectListener<_Counter, String>(
        bloc: cubit,
        onEffect: (_, effect) => heard.add(effect),
        child: Text(label, textDirection: TextDirection.ltr),
      ),
    );

    await tester.pumpWidget(tree('one'));
    cubit.shout('go');
    await tester.pump();

    // Rebuilding is not an event. This is the whole reason the channel exists.
    await tester.pumpWidget(tree('two'));
    await tester.pump();

    expect(heard, ['go']);
    await cubit.close();
  });

  testWidgets('an effect fired before the first frame is not lost', (
    tester,
  ) async {
    final cubit = _Counter()..shout('early');
    final heard = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: EffectListener<_Counter, String>(
          bloc: cubit,
          onEffect: (_, effect) => heard.add(effect),
          child: const SizedBox(),
        ),
      ),
    );
    await tester.pump();

    expect(heard, ['early']);
    await cubit.close();
  });

  testWidgets('it follows a new bloc when it is given one', (tester) async {
    final first = _Counter();
    final second = _Counter();
    final heard = <String>[];

    Widget tree(_Counter bloc) => MaterialApp(
      home: EffectListener<_Counter, String>(
        bloc: bloc,
        onEffect: (_, effect) => heard.add(effect),
        child: const SizedBox(),
      ),
    );

    await tester.pumpWidget(tree(first));
    await tester.pumpWidget(tree(second));
    second.shout('from the second');
    await tester.pump();

    expect(heard, ['from the second']);
    await first.close();
    await second.close();
  });
}
