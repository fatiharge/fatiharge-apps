import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/support/application/feedback_cubit.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/features/support/application/support_context.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockFeedback extends Mock implements api.FeedbackResourceApi {}

class _MockEvents extends Mock implements api.EventResourceApi {}

class _FakeIdentity implements DeviceIdentity {
  @override
  Future<String> hash() async => 'hash';

  @override
  String get platform => 'android';
}

void main() {
  late _MockFeedback feedback;
  late FeedbackCubit cubit;

  setUpAll(() {
    registerFallbackValue(api.EventBatch());
    registerFallbackValue(
      api.FeedbackRequest(kind: api.FeedbackKind.OTHER, message: 'x'),
    );
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'Motto',
      packageName: 'com.dafalabs.motto',
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({'last_archetype': 'quiet_builder'});
    final preferences = await SharedPreferences.getInstance();

    feedback = _MockFeedback();
    when(() => feedback.submitFeedback(any())).thenAnswer((_) async => null);

    final events = _MockEvents();
    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );

    cubit = FeedbackCubit(
      feedback,
      SupportContext(_FakeIdentity(), LastArchetype(preferences)),
      Analytics(EventQueue(preferences), events),
    );
  });

  test('what someone wrote goes out with the chosen kind', () async {
    cubit.chooseKind(api.FeedbackKind.BUG);

    await cubit.send(message: 'Sorular yüklenmedi', email: 'a@b.com');

    final sent = verify(() => feedback.submitFeedback(captureAny())).captured
        .single as api.FeedbackRequest;
    expect(sent.kind, api.FeedbackKind.BUG);
    expect(sent.message, 'Sorular yüklenmedi');
    expect(sent.email, 'a@b.com');
    expect(cubit.state.status, FeedbackStatus.sent);
  });

  test('the archetype rides along, so the report is about something', () async {
    await cubit.send(message: 'bir şey');

    final sent = verify(() => feedback.submitFeedback(captureAny())).captured
        .single as api.FeedbackRequest;
    expect(sent.context['archetypeId'], 'quiet_builder');
    expect(sent.context['platform'], 'android');
    expect(sent.context['appVersion'], '0.1.0+1');
  });

  test('a rejection is sent as its own kind, with no form to fill', () async {
    await cubit.rejectArchetype('Tam tersi gibi');

    final sent = verify(() => feedback.submitFeedback(captureAny())).captured
        .single as api.FeedbackRequest;
    expect(sent.kind, api.FeedbackKind.ARCHETYPE_REJECTED);
    expect(sent.message, 'Tam tersi gibi');
  });

  test('a failed send says so instead of pretending', () async {
    when(() => feedback.submitFeedback(any())).thenThrow(Exception('offline'));

    await cubit.send(message: 'bir şey');

    expect(cubit.state.status, FeedbackStatus.failed);
  });
}
