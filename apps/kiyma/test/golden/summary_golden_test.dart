@Tags(['golden'])
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/run_summary.dart';
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

    final progress = getIt<Progress>()
      ..gun = 12
      ..xp = 3800
      ..para = 3800
      ..sonOturum = const RunSummary(
        kazanc: 1450,
        musteri: 7,
        xpOnce: 2350,
        gunOnce: 12,
        atlananGun: 0,
      );
    expect(progress.gun, 12);

    final router = AppRouter();
    await router.replaceAll([const SummaryRoute()]);
    await pumpApp(tester, router: router);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/summary.png'),
    );
  });
}
