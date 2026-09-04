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

  /// Opens the counter and lets the clock run out.
  void playOut(KiymaCubit cubit) {
    cubit.startDay();
    cubit.run!.tick(Balance.runLength(cubit.state.gun).inSeconds + 1);
  }

  group('KiymaCubit', () {
    test('opens on day one with nothing behind it', () {
      final cubit = KiymaCubit(world);
      expect(cubit.state.gun, 1);
      expect(cubit.state.xp, 0);
      expect(cubit.state.hedef, Balance.target(1));
      expect(cubit.state.oturum, isNull);
      expect(cubit.run, isNull);
    });

    test('a finished run is banked and reported', () async {
      final cubit = KiymaCubit(world);
      final effects = <DayEvent>[];
      cubit.effects.listen(effects.add);

      cubit.startDay();
      cubit.progress.kazan(30);
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);

      expect(cubit.run, isNull);
      expect(cubit.state.gunBitti, isTrue);
      expect(cubit.state.oturum!.kazanc, 30);
      expect(cubit.state.oturum!.seviyeAtladi, isFalse);
      expect(cubit.state.gun, 1);
      await Future<void>.delayed(Duration.zero);
      expect(effects, contains(DayEvent.gunBitti));
    });

    test('crossing the level takes the day with it', () {
      final cubit = KiymaCubit(world)..startDay();
      cubit.progress.kazan(Balance.target(1));
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);

      final summary = cubit.state.oturum!;
      expect(summary.seviyeAtladi, isTrue);
      expect(summary.gunOnce, 1);
      expect(summary.atlananGun, 1);
      expect(cubit.state.gun, 2);
      expect(cubit.state.hedef, Balance.target(2));
    });

    test('a run big enough crosses more than one level', () {
      final cubit = KiymaCubit(world)..startDay();
      cubit.progress.kazan(Balance.target(3));
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);

      expect(cubit.state.oturum!.atlananGun, 3);
      expect(cubit.state.gun, 4);
    });

    test('spending never costs a level', () {
      final cubit = KiymaCubit(world)..startDay();
      cubit.progress.kazan(300);
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);
      expect(cubit.state.gun, 4, reason: '300 clears the first three');

      cubit.buy(const Unlock('malzeme_biber', 150));
      expect(cubit.state.gun, 4, reason: 'spending is not levelling');
      expect(cubit.state.xp, 300);
      expect(cubit.state.para, 150);
    });

    test('leaving the counter ends the run and reports what it took', () {
      final cubit = KiymaCubit(world)..startDay();
      cubit.progress.kazan(26);

      cubit.abandonRun();
      expect(cubit.run, isNull, reason: 'stepping out is not a pause');
      expect(cubit.state.oturum!.kazanc, 26);
      expect(cubit.state.para, 26, reason: 'money banks as it is earned');
    });

    test('a new run clears the last summary', () {
      final cubit = KiymaCubit(world);
      playOut(cubit);
      expect(cubit.state.oturum, isNotNull);

      cubit.startDay();
      expect(cubit.state.oturum, isNull);
      expect(cubit.state.gunBitti, isFalse);
    });

    test('abandoning nothing does nothing', () {
      final cubit = KiymaCubit(world)..abandonRun();
      expect(cubit.run, isNull);
      expect(cubit.state.oturum, isNull);
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
