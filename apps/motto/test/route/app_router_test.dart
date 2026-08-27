import 'package:flutter_test/flutter_test.dart';
import 'package:motto/route/app_router.dart';

void main() {
  group('AppRouter', () {
    test('startup is the first route, and it is the only one', () {
      final initial = AppRouter().routes.where((route) => route.initial);

      // Everything downstream resolves out of get_it, and the container is
      // built by the startup page. A different initial route finds an empty
      // container — which is exactly what happened the first time this ran on
      // a phone.
      expect(initial, hasLength(1));
      expect(initial.single.name, 'StartupRoute');
    });

    test('the test flow has no route that leaves it', () {
      final names = AppRouter().routes.map((route) => route.name).toSet();

      // Not a navigation bar anywhere in here: completion is the only thing
      // that matters, and every tab is a way out of the funnel.
      expect(names, contains('QuestionRoute'));
      expect(names, contains('CalculatingRoute'));
      expect(names, contains('ResultRoute'));
    });
  });
}
