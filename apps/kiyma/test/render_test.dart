import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/balance.dart';
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
          // One standing at the counter, one still walking in from each
          // side: the card and the meter only exist for the first.
          ..musteriler[0] = (Customer(
            order: Order(
              tip: UrunTipi.durum,
              ister: {Malzeme.domates.id},
              istemez: {Malzeme.sogan.id},
              tatli: Tatli.baklava,
              icecek: Icecek.ayran,
            ),
            day: 1,
          )..varis = 1)
          ..musteriler[1] = Customer(
            order: Order(
              tip: UrunTipi.porsiyon,
              ister: {Bilesen.ezme.id},
              istemez: const {},
            ),
            day: 1,
          )
          ..musteriler[2] = Customer(
            order: Order(
              tip: UrunTipi.durum,
              ister: const {},
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
      ..bardakBekletme[1] = (Bardak()..icerik = Icecek.kola)
      // A pile of each kind, and one about to be swept.
      ..altin[0] = Altin(12)
      ..altin[1] = Altin(30, tip: 1)
      ..altin[2] = (Altin(7, tip: 2)..kalan = 1)
      // Every grill badge at once: raw, cooking, ready, burnt.
      ..mangal[1].tick(3, 1)
      ..mangal[2].tick(6.5, 1)
      // Somebody on the way out, in each of the three moods.
      ..ayrilanlar.addAll([
        for (final hal in [
          MusteriHali.gidiyorMutlu,
          MusteriHali.gidiyorStabil,
          MusteriHali.gidiyorKizgin,
        ])
          Ayrilan(slot: 0, hal: hal, hiz: 1)..gidis = 0.4,
      ]);

    await tester.pumpWidget(
      MaterialApp(
        home: GameWidget(
          game: KiymaGame(
            scene: scene,
            art: assets,
            run: run,
            onPause: () {},
          ),
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
    final run =
        DayRun(
            scene: scene,
            progress: Progress(),
            onEvent: (_) {},
            onChanged: () {},
            random: math.Random(12),
          )
          ..bosMangal = Balance.idleGrill
          ..bosDurum = Balance.idleWrap
          ..bekleyenYanik = Balance.idleBurnt
          ..kagitCagiriyor = Balance.hintFor;
    await tester.pumpWidget(
      MaterialApp(
        home: GameWidget(
          game: KiymaGame(
            scene: scene,
            art: assets,
            run: run,
            onPause: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    expect(tester.takeException(), isNull);
  });
}
