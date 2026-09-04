import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/kiyma_game.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/order.dart';
import 'package:kiyma/game/model/products.dart';
import 'package:kiyma/game/progress.dart';
import 'package:kiyma/game/unlocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  late GameAssets assets;

  setUpAll(() async {
    scene = await SceneData.load();
    assets = await GameAssets.load();
  });

  /// One frame of the counter with everything on it at once. It is a smoke
  /// test, but the draw path is where a missing asset or a bad quad shows up,
  /// and none of the rules tests touch a canvas.
  testWidgets('draws a full counter without throwing', (tester) async {
    final progress = Progress();
    for (final unlock in Unlocks.catalogue) {
      progress.unlocks.open(unlock.id);
    }

    // Something in every state the renderer knows how to draw.
    final run =
        DayRun(
            scene: scene,
            progress: progress,
            onEvent: (_) {},
            onChanged: () {},
            random: math.Random(11),
          )
          ..musteriler[0] = Customer(
            order: Order(
              tip: UrunTipi.durum,
              ister: {Malzeme.domates.id},
              istemez: {Malzeme.sogan.id},
              tatli: Tatli.baklava,
              icecek: Icecek.ayran,
            ),
            day: 1,
          )
          ..musteriler[1] = Customer(
            order: Order(
              tip: UrunTipi.porsiyon,
              ister: {Bilesen.ezme.id},
              istemez: const {},
            ),
            day: 1,
          );
    for (var i = 0; i < 4; i++) {
      run.mangal[i].koy();
    }
    run.mangal[3].tick(30, 1);
    run
      ..durumIstasyonu = (Durum()
        ..etli = true
        ..malzemeler.addAll(Malzeme.values))
      ..tabakIstasyonu = (Porsiyon()
        ..lavasli = true
        ..etli = true
        ..bilesenler.addAll(Bilesen.values))
      ..bekleme[0] = DurumUrun(Durum()..sarili = true)
      ..bekleme[0] = PorsiyonUrun(Porsiyon())
      ..bardakBekletme[0] = (Bardak()..doldur(Icecek.ayran))
      ..bardakBekletme[1] = (Bardak()..icerik = Icecek.kola);

    await tester.pumpWidget(
      MaterialApp(
        home: GameWidget(
          game: KiymaGame(scene: scene, art: assets, run: run),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));

    expect(tester.takeException(), isNull);
  });

  testWidgets('draws a locked day-one counter without throwing', (
    tester,
  ) async {
    final run = DayRun(
      scene: scene,
      progress: Progress(),
      onEvent: (_) {},
      onChanged: () {},
      random: math.Random(12),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: GameWidget(
          game: KiymaGame(scene: scene, art: assets, run: run),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    expect(tester.takeException(), isNull);
  });
}
