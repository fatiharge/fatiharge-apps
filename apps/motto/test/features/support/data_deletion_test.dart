import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/support/application/data_deletion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockEntitlements extends Mock implements api.EntitlementResourceApi {}

void main() {
  late SharedPreferences preferences;
  late _MockEntitlements entitlements;
  late DataDeletion deletion;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'chain': '{}',
      'chain_unopened_in_a_row': 3,
      'chain_reminder_hour': 21,
      'test_draft': '{}',
      'last_archetype': 'quiet_builder',
    });
    preferences = await SharedPreferences.getInstance();
    entitlements = _MockEntitlements();
    when(entitlements.deleteMyData).thenAnswer((_) async => null);
    deletion = DataDeletion(entitlements, preferences);
  });

  test('the server is asked and the phone is cleared with it', () async {
    await deletion.deleteEverything();

    verify(entitlements.deleteMyData).called(1);
    // The chain never leaves the phone, so the server cannot delete it — and
    // someone who asked for everything to go would expect it gone.
    expect(preferences.getString('chain'), isNull);
    expect(preferences.getString('test_draft'), isNull);
    expect(preferences.getString('last_archetype'), isNull);
  });

  test('the reminder hour is a preference, not data about anyone', () async {
    await deletion.deleteEverything();

    expect(preferences.getInt('chain_reminder_hour'), 21);
  });

  test('a server that refuses leaves the phone alone', () async {
    when(entitlements.deleteMyData).thenThrow(Exception('offline'));

    await expectLater(deletion.deleteEverything(), throwsA(isA<Exception>()));

    // Half-deleted is the worst outcome: the screen says it failed and the
    // data it claims is still there has to actually still be there.
    expect(preferences.getString('chain'), isNotNull);
  });
}
