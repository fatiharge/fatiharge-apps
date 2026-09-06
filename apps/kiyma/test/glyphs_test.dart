import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/presentation/render/glyphs.dart';

void main() {
  /// Every id the order card can print has to have a mark.
  ///
  /// A missing one is silent: the well draws, the ring draws, and the space
  /// where the ingredient should be is simply empty — which reads as an
  /// order with a blank in it rather than as a bug. Adding an ingredient
  /// without adding its mark is exactly the change that would do this, so
  /// the enums are the list rather than a hand-written one.
  test('every ingredient, extra and product has a mark', () {
    for (final id in [
      ...Malzeme.values.map((m) => m.id),
      ...Bilesen.values.map((b) => b.id),
      ...Tatli.values.map((t) => t.id),
      ...Icecek.values.map((i) => i.id),
      'durum',
      'porsiyon',
      'et',
    ]) {
      expect(hasGlyph(id), isTrue, reason: '$id has no glyph');
    }
  });

  test('an unknown id draws nothing rather than throwing', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    expect(
      () => drawGameGlyph(canvas, 'yok_boyle_bir_sey', Offset.zero, 20),
      returnsNormally,
    );
  });

  test('every mark draws, at full and at reduced opacity', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (final id in [
      ...Malzeme.values.map((m) => m.id),
      ...Bilesen.values.map((b) => b.id),
      ...Tatli.values.map((t) => t.id),
      ...Icecek.values.map((i) => i.id),
      'durum',
      'porsiyon',
      'et',
    ]) {
      drawGameGlyph(canvas, id, const Offset(30, 30), 21);
      drawGameGlyph(canvas, id, const Offset(60, 30), 21, alpha: 0.3);
    }
    expect(recorder.endRecording(), isNotNull);
  });
}
