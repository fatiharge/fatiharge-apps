import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/kiyma_game.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/ui/game_page.dart';
import 'package:kiyma/ui/hud.dart';
import 'package:kiyma/ui/panels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The screen resolves what it draws from the container, so the test brings
  // the container up the way bootstrap does rather than handing it fakes.
  setUpAll(() async {
    await getIt.reset();
    await configureDependencies();
    await getIt<GameWorld>().loadScene();
    await getIt<GameWorld>().loadArt();
  });

  tearDownAll(() async => getIt.reset());

  Future<KiymaCubit> open(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: GamePage()));
    return tester.element(find.byType(Scaffold)).read<KiymaCubit>();
  }

  /// Sends everybody home. The engine ticks while the widget is pumped, so a
  /// customer may already have walked in by the time a test gets here.
  void closeUp(KiymaCubit cubit) {
    cubit.run!
      ..kuyruk = 0
      ..musteriler.fillRange(0, cubit.run!.musteriler.length, null)
      ..tick(0.1);
  }

  testWidgets('opens on the day-start card, with no counter yet', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(DayStartPanel), findsOneWidget);
    expect(find.byType(GameWidget<KiymaGame>), findsNothing);
    expect(find.byType(Hud), findsNothing);
  });

  testWidgets('starting the day puts up the counter and the numbers', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Tezgahı aç'));
    await tester.pump();

    expect(find.byType(GameWidget<KiymaGame>), findsOneWidget);
    expect(find.byType(Hud), findsOneWidget);
    expect(find.byType(DayStartPanel), findsNothing);
  });

  testWidgets('the counter stays up behind the day-end card', (tester) async {
    final cubit = await open(tester);
    await tester.tap(find.text('Tezgahı aç'));
    await tester.pump();

    closeUp(cubit);
    await tester.pump();

    expect(find.byType(DayEndPanel), findsOneWidget);
    expect(find.byType(GameWidget<KiymaGame>), findsOneWidget);
    expect(find.byType(Hud), findsNothing);
  });

  testWidgets('a cleared day leads to the shop and then to the next day', (
    tester,
  ) async {
    final cubit = await open(tester);
    await tester.tap(find.text('Tezgahı aç'));
    await tester.pump();

    cubit.progress.kazan(Balance.target(1));
    closeUp(cubit);
    await tester.pump();

    await tester.tap(find.text('Devam'));
    await tester.pump();
    expect(find.byType(ShopPanel), findsOneWidget);

    await tester.tap(find.text('Sonraki güne geç'));
    await tester.pump();
    expect(find.text('Gün 2'), findsOneWidget);
  });
}
