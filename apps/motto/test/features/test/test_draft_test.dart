import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/test/application/test_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late TestDraft draft;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    draft = TestDraft(await SharedPreferences.getInstance());
  });

  group('TestDraft', () {
    test('a test that was never started has nothing to resume', () {
      expect(draft.read(), isEmpty);
    });

    test('answers survive a restart', () async {
      await draft.write({'q1': 5, 'q2': 1});

      // The alternative is asking someone twenty questions twice.
      expect(draft.read(), {'q1': 5, 'q2': 1});
    });

    test('clearing leaves nothing to resume into a second charge', () async {
      await draft.write({'q1': 5});

      await draft.clear();

      expect(draft.read(), isEmpty);
    });
  });
}
