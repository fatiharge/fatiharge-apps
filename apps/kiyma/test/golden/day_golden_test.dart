@Tags(['golden'])
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';

import '../support/app_harness.dart';

/// The card that says what today is like. Five numbers move with the day and
/// the arithmetic that produces them is easy to get backwards; a picture is
/// the only thing that notices a red arrow pointing the wrong way.
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

  testWidgets('the day card on a landscape phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(880, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Day five, with enough in the till to reach the cheapest thing left.
    getIt<Progress>()
      ..gun = 5
      ..xp = Balance.floor(5) + 300
      ..para = 500;

    final router = AppRouter();
    await router.replaceAll([const DayRoute()]);
    await pumpApp(tester, router: router);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/day.png'),
    );
  });
}
