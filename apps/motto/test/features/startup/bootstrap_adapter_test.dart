import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/startup/application/bootstrap_adapter.dart';

void main() {
  group('BootstrapAdapter', () {
    test('brings up the container before anything that needs it', () {
      final jobs = const BootstrapAdapter().jobs();

      expect(jobs.first.name, 'dependencies');
    });

    test('a session that cannot be established does not hold the app shut', () {
      final session = const BootstrapAdapter().jobs().firstWhere(
        (job) => job.name == 'session',
      );

      // The welcome screen reads fine without a token, and the first screen
      // that needs the server explains a network problem better than a splash
      // that will not move.
      expect(session.errorPolicy, BootstrapErrorPolicy.skip);
      expect(session.retries, greaterThan(0));
    });
  });
}
