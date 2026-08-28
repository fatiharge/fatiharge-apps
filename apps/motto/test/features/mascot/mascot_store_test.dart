import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MascotStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = MascotStore(await SharedPreferences.getInstance());
  });

  test('it is on screen by default', () {
    expect(store.onScreen.value, isTrue);
  });

  // Read from the route, because the version that counted wrappers was right
  // in a test and wrong on a phone: the mascot sat on the result screen's
  // buttons even though the page said it should not.
  test('the funnel closes it, and the rest of the app does not', () {
    for (final route in MascotStore.closedTo) {
      store.onRoute(route);
      expect(store.onScreen.value, isFalse, reason: route);
    }

    store.onRoute('TodayRoute');
    expect(store.onScreen.value, isTrue);
  });

  test('a sheet over a closed route does not hand it back', () {
    store.onRoute('ResultRoute');
    // Sheets and dialogs do not change `current`, so nothing to release.
    expect(store.onScreen.value, isFalse);
  });

  test('settings win over the route', () async {
    await store.setVisible(value: false);
    store.onRoute('TodayRoute');

    expect(store.onScreen.value, isFalse);
  });

  test('an unknown route leaves it alone', () {
    store.onRoute(null);
    expect(store.onScreen.value, isTrue);
  });
}
