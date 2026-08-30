import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MascotStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = MascotStore(await SharedPreferences.getInstance());
  });

  test('a dialog takes it off the screen and closing gives it back', () {
    expect(store.onScreen.value, isTrue);

    // It floats over prose on purpose. Over a clock face it hides the numbers
    // being picked, and there is nothing to drag it away with.
    store.onModals(1);
    expect(store.onScreen.value, isFalse);

    store.onModals(0);
    expect(store.onScreen.value, isTrue);
  });

  test('a screen that shut it out keeps it out after the dialog closes', () {
    store
      ..onRoute('QuestionRoute')
      ..onModals(1)
      ..onModals(0);

    expect(store.onScreen.value, isFalse);
  });
}
