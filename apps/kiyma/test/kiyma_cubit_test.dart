import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/unlocks.dart';
import 'package:kiyma/game/world.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameWorld world;
  setUpAll(() async {
    world = GameWorld();
    await world.loadScene();
  });

  /// Opens the counter and closes it again with nobody left to serve.
  void playEmptyDay(KiymaCubit cubit) {
    cubit.startDay();
    cubit.run!
      ..kuyruk = 0
      ..tick(0.1);
  }

  group('KiymaCubit', () {
    test('opens on day one with the target ahead of it', () {
      final cubit = KiymaCubit(world);
      expect(cubit.state.gun, 1);
      expect(cubit.state.hedef, Balance.target(1));
      expect(cubit.state.ilerleyebilir, isFalse);
      expect(cubit.run, isNull);
    });

    test('a finished run says so and leaves the day where it was', () async {
      final cubit = KiymaCubit(world);
      final effects = <DayEvent>[];
      cubit.effects.listen(effects.add);

      playEmptyDay(cubit);

      expect(cubit.state.gunBitti, isTrue);
      expect(cubit.state.gun, 1, reason: 'the day is a counter, not a gate');
      await Future<void>.delayed(Duration.zero);
      expect(effects, contains(DayEvent.gunBitti));
    });

    test('the counter can be opened again on the same day', () {
      final cubit = KiymaCubit(world);
      playEmptyDay(cubit);
      final first = cubit.run;
      cubit.startDay();
      expect(cubit.run, isNot(same(first)));
      expect(cubit.state.gunBitti, isFalse);
      expect(cubit.state.gun, 1);
    });

    test('moving on is refused until the target is met', () {
      final cubit = KiymaCubit(world)..advanceDay();
      expect(cubit.state.gun, 1);

      cubit.progress.kazan(Balance.target(1) - 1);
      cubit.advanceDay();
      expect(cubit.state.gun, 1);
      expect(cubit.state.ilerleyebilir, isFalse);
    });

    test('moving on advances the day and keeps the money', () {
      final cubit = KiymaCubit(world);
      cubit.progress.kazan(Balance.target(1));
      playEmptyDay(cubit);

      expect(cubit.state.ilerleyebilir, isTrue);
      cubit.advanceDay();

      expect(cubit.state.gun, 2);
      expect(cubit.state.para, Balance.target(1));
      expect(cubit.state.toplamKazanc, Balance.target(1));
      expect(cubit.run, isNull, reason: 'the finished run is left behind');
      expect(cubit.state.hedef, Balance.target(2));
    });

    test('a target met once stays met until it is used', () {
      final cubit = KiymaCubit(world);
      cubit.progress.kazan(Balance.target(1));
      playEmptyDay(cubit);
      playEmptyDay(cubit);
      expect(cubit.state.ilerleyebilir, isTrue);
    });

    test('buying takes the money and opens the lock', () {
      final cubit = KiymaCubit(world);
      cubit.progress.kazan(200);

      cubit.buy(const Unlock('malzeme_biber', 150));
      expect(cubit.state.para, 50);
      expect(cubit.progress.unlocks.has('malzeme_biber'), isTrue);

      cubit.buy(const Unlock('malzeme_tursu', 250));
      expect(cubit.state.para, 50, reason: 'not enough for the next one');
    });
  });
}
