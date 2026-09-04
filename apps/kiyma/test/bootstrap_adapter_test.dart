import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/infrastructure/bootstrap/bootstrap_adapter.dart';
import 'package:kiyma/route/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<AppRouter>(AppRouter());
  });

  tearDownAll(() async => getIt.reset());

  test('the container comes first, then the scene, then the art', () async {
    final adapter = BootstrapAdapter();
    final jobs = adapter.jobs();

    expect(jobs.map((job) => job.name), [
      'dependencies',
      'scene',
      'art',
      'splash',
    ]);
    for (final job in jobs.take(3)) {
      expect(
        job.errorPolicy,
        BootstrapErrorPolicy.restart,
        reason: '${job.name}: there is no reduced game to fall back to',
      );
    }

    // The container is not up yet, so nothing the later jobs need can be
    // resolved before the first one has run.
    expect(getIt.isRegistered<GameWorld>(), isFalse);

    for (final job in jobs.take(3)) {
      await job.run();
    }

    final world = getIt<GameWorld>();
    expect(world.scene.regions, isNotEmpty);
    expect(world.art['sis_cig'], isNotNull);
  });

  test('the splash waits out the remainder, not the whole floor', () async {
    final adapter = BootstrapAdapter();
    final jobs = adapter.jobs();

    // Two of the three seconds have already gone on real work.
    await Future<void>.delayed(const Duration(seconds: 2));

    final waited = Stopwatch()..start();
    await jobs.last.run();
    waited.stop();

    expect(waited.elapsed, lessThan(const Duration(milliseconds: 1600)));
    expect(waited.elapsed, greaterThan(const Duration(milliseconds: 400)));
  });

  test('the world refuses to be read before its job has run', () async {
    await configureDependencies();
    final world = getIt<GameWorld>();

    expect(() => world.scene, throwsStateError);
    expect(() => world.art, throwsStateError);

    await world.loadScene();
    expect(world.scene.size.width, 1024);
  });
}
