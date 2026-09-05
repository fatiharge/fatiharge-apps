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

import 'support/app_harness.dart';

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

  for (final ms in [120, 300, 600, 1100]) {
    testWidgets('frame $ms', (tester) async {
      await getIt.reset();
      await configureDependencies();
      await getIt<GameWorld>().loadScene();
      await getIt<GameWorld>().loadArt();
      await tester.binding.setSurfaceSize(const Size(880, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const day = 5;
      final opening = Balance.floor(day);
      getIt<Progress>()
        ..gun = day
        ..xp = opening + 500
        ..sonOturum = RunSummary(
          kazanc: 500,
          musteri: 7,
          xpOnce: opening,
          gunOnce: day,
          atlananGun: 0,
          zirveTempo: TempoHali.ates,
        );

      final router = AppRouter();
      await router.replaceAll([const SummaryRoute()]);
      await pumpApp(tester, router: router);
      await tester.pump(Duration(milliseconds: ms));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/frame_$ms.png'),
      );
    });
  }
}
