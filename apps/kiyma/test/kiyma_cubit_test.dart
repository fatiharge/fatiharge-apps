import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/infrastructure/progress_store.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameWorld world;
  late ProgressStore store;

  setUpAll(() async {
    world = GameWorld();
    await world.loadScene();
    SharedPreferences.setMockInitialValues({});
    store = ProgressStore(await SharedPreferences.getInstance());
  });

  /// Opens the counter and lets the clock run out.
  void playOut(KiymaCubit cubit) {
    cubit.startDay();
    cubit.run!.tick(Balance.runLength(cubit.state.gun).inSeconds + 1);
  }

  group('KiymaCubit', () {
    test('opens on day one with nothing behind it', () {
      final cubit = KiymaCubit(world, Progress(), store);
      expect(cubit.state.gun, 1);
      expect(cubit.state.xp, 0);
      expect(cubit.state.hedef, Balance.target(1));
      expect(cubit.state.oturum, isNull);
      expect(cubit.run, isNull);
    });

    test('a finished run is banked and reported', () async {
      final cubit = KiymaCubit(world, Progress(), store);
      final effects = <DayEvent>[];
      cubit.effects.listen(effects.add);

      cubit.startDay();
      // Short of the first day's target, so nothing turns over.
      final under = Balance.target(1) - 5;
      cubit.progress.kazan(under);
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);

      expect(cubit.run, isNull);
      expect(cubit.state.gunBitti, isTrue);
      expect(cubit.state.oturum!.kazanc, under);
      expect(cubit.state.oturum!.seviyeAtladi, isFalse);
      expect(cubit.state.gun, 1);
      await Future<void>.delayed(Duration.zero);
      expect(effects, contains(DayEvent.gunBitti));
    });

    test('a run that burned more than it sold reports a loss', () {
      // Reachable from the second run on: the burn penalty comes off the same
      // xp the run's take is differenced from.
      final progress = Progress()..kazan(200);
      final cubit = KiymaCubit(world, progress, store)..startDay();
      progress.cezalandir(36);
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);

      expect(cubit.state.oturum!.kazanc, -36);
      expect(
        cubit.state.oturum!.xpOnce,
        200,
        reason: 'the bar starts from where the run actually began',
      );
    });

    test('crossing the level takes the day with it', () {
      final cubit = KiymaCubit(world, Progress(), store)..startDay();
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
      final cubit = KiymaCubit(world, Progress(), store)..startDay();
      cubit.progress.kazan(Balance.target(3));
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);

      expect(cubit.state.oturum!.atlananGun, 3);
      expect(cubit.state.gun, 4);
    });

    test('spending never costs a level', () {
      final cubit = KiymaCubit(world, Progress(), store)..startDay();
      final earned = Balance.target(3) + 50;
      cubit.progress.kazan(earned);
      cubit.run!.tick(Balance.runLength(1).inSeconds + 1);
      expect(cubit.state.gun, 4, reason: 'it cleared the first three days');

      cubit.buy(const Unlock('malzeme_biber', 150));
      expect(cubit.state.gun, 4, reason: 'spending is not levelling');
      expect(cubit.state.xp, earned);
      expect(cubit.state.para, earned - 150);
    });

    test('closing the page ends the run and records what it took', () async {
      final progress = Progress();
      final cubit = KiymaCubit(world, progress, store)..startDay();
      progress.kazan(26);

      await cubit.close();
      expect(cubit.run, isNull, reason: 'stepping out is not a pause');
      expect(progress.sonOturum!.kazanc, 26);
      expect(progress.para, 26, reason: 'money banks as it is earned');
    });

    test('a new run clears the last summary', () {
      final cubit = KiymaCubit(world, Progress(), store);
      playOut(cubit);
      expect(cubit.state.oturum, isNotNull);

      cubit.startDay();
      expect(cubit.state.oturum, isNull);
      expect(cubit.state.gunBitti, isFalse);
    });

    test('closing without a run records nothing', () async {
      final progress = Progress();
      await KiymaCubit(world, progress, store).close();
      expect(progress.sonOturum, isNull);
    });

    test('pausing stops the clock and resuming starts it again', () {
      final cubit = KiymaCubit(world, Progress(), store)..startDay();
      final run = cubit.run!;
      final left = run.kalanSure;

      cubit.duraklat(durdur: true);
      expect(cubit.state.duraklatildi, isTrue);
      run.tick(5);
      expect(run.kalanSure, left, reason: 'nothing moved');

      cubit.duraklat(durdur: false);
      run.tick(5);
      expect(run.kalanSure, lessThan(left));
    });

    test('nothing can be touched while it is paused', () {
      final cubit = KiymaCubit(world, Progress(), store)..startDay();
      final run = cubit.run!;
      cubit.duraklat(durdur: true);
      expect(run.beginDrag(world.scene['lavas_kaynak'].quad.center), isFalse);
    });

    test('the debug grant is money and only money', () {
      final cubit = KiymaCubit(world, Progress(), store)..bagisla(1000);
      expect(cubit.state.para, 1000);
      expect(cubit.state.xp, 0, reason: 'the level is what was played');
      expect(cubit.state.gun, 1);
    });

    test('buying takes the money and opens the lock', () {
      final cubit = KiymaCubit(world, Progress(), store);
      cubit.progress.kazan(200);

      cubit.buy(const Unlock('malzeme_biber', 150));
      expect(cubit.state.para, 50);
      expect(cubit.progress.unlocks.has('malzeme_biber'), isTrue);

      cubit.buy(const Unlock('malzeme_tursu', 250));
      expect(cubit.state.para, 50, reason: 'not enough for the next one');
    });
  });
}
