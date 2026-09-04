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
    const adapter = BootstrapAdapter();
    final jobs = adapter.jobs();

    expect(jobs.map((job) => job.name), [
      'display',
      'dependencies',
      'scene',
      'art',
    ]);
    for (final job in jobs.skip(1)) {
      expect(
        job.errorPolicy,
        BootstrapErrorPolicy.restart,
        reason: '${job.name}: there is no reduced game to fall back to',
      );
    }

    // The container is not up yet, so nothing the later jobs need can be
    // resolved before the first one has run.
    expect(getIt.isRegistered<GameWorld>(), isFalse);

    for (final job in jobs.skip(1)) {
      await job.run();
    }

    final world = getIt<GameWorld>();
    expect(world.scene.regions, isNotEmpty);
    expect(world.art['sis_cig'], isNotNull);
  });

  test('a locked orientation is nice to have, not a reason to fail', () {
    final display = const BootstrapAdapter().jobs().first;
    expect(display.name, 'display');
    expect(display.errorPolicy, BootstrapErrorPolicy.skip);
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
