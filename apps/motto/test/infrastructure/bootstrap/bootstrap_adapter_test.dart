import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/infrastructure/bootstrap/bootstrap_adapter.dart';
import 'package:motto/route/app_router.gr.dart';

void main() {
  group('BootstrapAdapter', () {
    test('brings up the container before anything that needs it', () {
      final jobs = const BootstrapAdapter().jobs();

      expect(jobs.first.name, 'dependencies');
    });

    test('the archetype is asked for before the door is chosen', () {
      final jobs = const BootstrapAdapter().jobs();
      final names = jobs.map((job) => job.name).toList();
      final archetype = jobs.firstWhere((job) => job.name == 'archetype');

      // A reinstall wipes the preference the door is chosen from while the
      // server still holds the result, so skipping this would send somebody
      // with a running chain back through the inventory.
      expect(names.indexOf('archetype'), greaterThan(names.indexOf('session')));
      expect(archetype.errorPolicy, isNot(BootstrapErrorPolicy.skip));
      expect(archetype.retries, greaterThan(0));
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

    group('the door it opens', () {
      test('a result outranks the introduction', () {
        // The reinstall case: preferences are gone so the introduction has
        // not been seen, but the archetype came back off the server and the
        // chain is still running. Asking the twenty questions again would
        // write a second result that can name somebody else.
        expect(
          BootstrapAdapter.firstRoute(
            hasResult: true,
            onboardingSeen: false,
          ).routeName,
          const ShellRoute().routeName,
        );
      });

      test('no result and no introduction is a new phone', () {
        expect(
          BootstrapAdapter.firstRoute(
            hasResult: false,
            onboardingSeen: false,
          ).routeName,
          OnboardingRoute().routeName,
        );
      });

      test('introduction seen but nothing claimed goes to the inventory', () {
        expect(
          BootstrapAdapter.firstRoute(
            hasResult: false,
            onboardingSeen: true,
          ).routeName,
          const WelcomeRoute().routeName,
        );
      });
    });
  });
}
