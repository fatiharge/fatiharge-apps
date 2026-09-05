import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/effects.dart';

/// The pool holds no Flame and no widgets, which is the point of it: an
/// effect is age, life and a draw call, so its lifecycle is checkable here
/// rather than by watching a phone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameAssets art;
  setUpAll(() async => art = await GameAssets.load());

  test('an effect lives its life and then is gone', () {
    final fx = Effects(art)
      ..ring(at: Offset.zero, colour: const Color(0xFFFFFFFF), life: 0.3);
    expect(fx.length, 1);

    fx.update(0.2);
    expect(fx.length, 1, reason: 'still going');

    fx.update(0.2);
    expect(fx.length, 0, reason: 'and then not');
  });

  test('a burst is a fan, not one speck', () {
    final fx = Effects(art)
      ..burst(at: Offset.zero, colour: const Color(0xFFFFFFFF), count: 12);
    expect(fx.length, 12);
  });

  test('the pool refuses to grow past its cap', () {
    final fx = Effects(art);
    for (var i = 0; i < 40; i++) {
      fx.burst(at: Offset.zero, colour: const Color(0xFFFFFFFF), count: 20);
    }
    expect(fx.length, Effects.cap);
  });

  test('every layer is drawn on its own pass', () {
    final fx = Effects(art)
      ..puff(at: const Offset(200, 300), asset: 'duman')
      ..ring(at: Offset.zero, colour: const Color(0xFFFFFFFF))
      ..floater(
        at: Offset.zero,
        text: '+1',
        colour: const Color(0xFFFFFFFF),
      );

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (final layer in EffectLayer.values) {
      fx.render(canvas, layer);
    }
    recorder.endRecording().dispose();
    expect(fx.length, 3);
  });

  test('drawing a whole pool never throws', () {
    final fx = Effects(art)
      ..puff(at: const Offset(200, 300), asset: 'duman')
      ..puff(at: const Offset(200, 300), asset: 'buhar')
      ..burst(at: const Offset(400, 300), colour: const Color(0xFFFFFFFF))
      ..burst(
        at: const Offset(400, 300),
        colour: const Color(0xFFFFFFFF),
        asset: 'kivilcim',
      )
      ..ring(at: const Offset(400, 300), colour: const Color(0xFFFFFFFF))
      ..floater(
        at: const Offset(400, 300),
        text: '+120',
        colour: const Color(0xFFFFFFFF),
      )
      ..flight(
        from: const Offset(100, 400),
        to: const Offset(500, 200),
        asset: 'doner_bekleme',
        width: 70,
      )
      ..coins(from: const Offset(500, 260), to: const Offset(140, 60));

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (var frame = 0; frame < 30; frame++) {
      fx.update(1 / 60);
      for (final layer in EffectLayer.values) {
        fx.render(canvas, layer);
      }
    }
    recorder.endRecording().dispose();
    expect(fx.length, greaterThan(0));
  });
}
