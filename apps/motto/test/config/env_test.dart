import 'package:flutter_test/flutter_test.dart';
import 'package:motto/config/env.dart';

void main() {
  group('MottoEnvironment', () {
    test('each environment names both services', () {
      for (final environment in MottoEnvironment.values) {
        expect(environment.authBaseUrl, startsWith('https://'));
        expect(environment.mottoBaseUrl, startsWith('https://'));
      }
    });

    test('stage and production are different servers', () {
      expect(
        MottoEnvironment.stage.mottoBaseUrl,
        isNot(MottoEnvironment.production.mottoBaseUrl),
      );
      expect(
        MottoEnvironment.stage.authBaseUrl,
        isNot(MottoEnvironment.production.authBaseUrl),
      );
    });

    test('a build with no flavor refuses rather than picking one', () {
      // Tests run without --flavor, so this is the unflavoured case itself.
      // Guessing here would mean a developer writing to the real database, or
      // a released build quietly talking to stage.
      expect(() => Env.current, throwsStateError);
    });
  });
}
