import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/infrastructure/game_boot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startup is the scene, then the art, and nothing is optional', () async {
    final boot = GameBoot();
    final jobs = boot.jobs();

    expect(jobs.map((job) => job.name), ['scene', 'art']);
    for (final job in jobs) {
      expect(
        job.errorPolicy,
        BootstrapErrorPolicy.restart,
        reason: '${job.name}: there is no reduced game to fall back to',
      );
    }

    expect(boot.ready.value, isFalse);
    for (final job in jobs) {
      await job.run();
    }
    boot.bootstrapFinished();

    expect(boot.ready.value, isTrue);
    expect(boot.scene.regions, isNotEmpty);
    expect(boot.assets['sis_cig'], isNotNull);
  });
}
