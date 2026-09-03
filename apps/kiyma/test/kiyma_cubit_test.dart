import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/unlocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SceneData scene;
  setUpAll(() async => scene = await SceneData.load());

  /// Opens the counter and closes it again with nobody left to serve.
  void playEmptyDay(KiymaCubit cubit) {
    cubit.startDay();
    cubit.run!
      ..kuyruk = 0
      ..tick(0.1);
  }

  group('KiymaCubit', () {
    test('opens on the day-start card', () {
      final cubit = KiymaCubit(scene);
      expect(cubit.state.phase, GamePhase.gunBasi);
      expect(cubit.state.gun, 1);
      expect(cubit.state.hedef, Balance.target(1));
    });

    test('a finished day shows the day-end card', () async {
      final cubit = KiymaCubit(scene);
      final effects = <DayEvent>[];
      cubit.effects.listen(effects.add);

      playEmptyDay(cubit);
      expect(cubit.state.phase, GamePhase.gunSonu);
      await Future<void>.delayed(Duration.zero);
      expect(effects, contains(DayEvent.gunBitti));
    });

    test('a missed target replays the day and restores reputation', () {
      final cubit = KiymaCubit(scene)..startDay();
      cubit.progress.itibar = 42;
      cubit.run!
        ..kuyruk = 0
        ..tick(0.1);

      expect(cubit.state.gunGecildi, isFalse);
      expect(cubit.progress.itibar, Balance.startingReputation);

      cubit.continueFromEnd();
      expect(cubit.state.phase, GamePhase.gunBasi);
      expect(cubit.state.gun, 1, reason: 'the same day again');
    });

    test('a missed target keeps the money that was made', () {
      final cubit = KiymaCubit(scene)..startDay();
      cubit.progress.kazan(30);
      cubit.run!
        ..kuyruk = 0
        ..tick(0.1);
      cubit.continueFromEnd();
      expect(cubit.state.para, 30);
      expect(cubit.state.toplamKazanc, 30);
    });

    test('a met target advances the day and opens the shop', () {
      final cubit = KiymaCubit(scene)..startDay();
      cubit.progress
        ..itibar = 88
        ..kazan(Balance.target(1));
      cubit.run!
        ..kuyruk = 0
        ..tick(0.1);

      expect(cubit.state.gunGecildi, isTrue);
      expect(cubit.progress.itibar, 88, reason: 'a passed day keeps standing');

      cubit.continueFromEnd();
      expect(cubit.state.phase, GamePhase.magaza);
      expect(cubit.state.gun, 2);

      cubit.closeShop();
      expect(cubit.state.phase, GamePhase.gunBasi);
    });

    test('buying takes the money and opens the lock', () {
      final cubit = KiymaCubit(scene);
      cubit.progress.kazan(200);
      const biber = Unlock('malzeme_biber', 150);

      cubit.buy(biber);
      expect(cubit.state.para, 50);
      expect(cubit.progress.unlocks.has('malzeme_biber'), isTrue);

      cubit.buy(const Unlock('malzeme_tursu', 250));
      expect(cubit.state.para, 50, reason: 'not enough for the next one');
    });

    test('the day the second time starts from that day reputation', () {
      final cubit = KiymaCubit(scene);
      playEmptyDay(cubit);
      cubit
        ..continueFromEnd()
        ..startDay();
      cubit.progress.itibar = 51;
      cubit.run!
        ..kuyruk = 0
        ..tick(0.1);
      expect(cubit.progress.itibar, Balance.startingReputation);
    });
  });
}
