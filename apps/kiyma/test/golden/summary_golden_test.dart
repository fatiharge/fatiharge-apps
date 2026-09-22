@Tags(['golden'])
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/run_summary.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';

import '../support/app_harness.dart';

/// The summary at the size it is actually read: a phone held sideways.
///
/// The design it follows was drawn for a tablet, where everything fits with
/// room to spare. This is the check that it still fits when the box is short
/// and very wide — the shape a phone gives it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
    await (FontLoader(
      'Rubik',
    )..addFont(rootBundle.load('assets/fonts/Rubik.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
    await getIt<GameWorld>().loadScene();
    await getIt<GameWorld>().loadArt();
  });

  tearDownAll(() async => getIt.reset());

  testWidgets('the run summary on a landscape phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(880, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Two thirds of the way through day five: a partly filled bar, two of
    // three stars, and a run that did not quite turn the day over.
    const day = 5;
    final opening = Balance.floor(day);
    const took = 260;
    final progress = getIt<Progress>()
      ..gun = day
      ..xp = opening + took
      ..para = opening + took
      ..sonOturum = RunSummary(
        kazanc: took,
        musteri: 7,
        xpOnce: opening,
        gunOnce: day,
        atlananGun: 0,
        zirveTempo: TempoBand.ates,
        // The worst case for the layout: a day that earned more badges than
        // the strip shows. It overflowed by eleven pixels on a real phone.
        kritik: Balance.rozetKritik,
        enUzunSeri: Balance.rozetSeri,
        hedef: 5,
        hedefTamam: true,
      );
    expect(progress.gun, day);

    final router = AppRouter();
    await router.replaceAll([const SummaryRoute()]);
    await pumpApp(tester, router: router);
    // Not `pumpAndSettle`: the primary button breathes for as long as the
    // screen is up, so settling never returns. Pump past the entrance and
    // catch it where it has arrived.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/summary.png'),
    );
  });
}
