import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockEvents extends Mock implements api.EventResourceApi {}

void main() {
  late SharedPreferences preferences;
  late EventQueue queue;
  late _MockEvents events;
  late Analytics analytics;

  setUpAll(() => registerFallbackValue(api.EventBatch()));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    queue = EventQueue(preferences);
    events = _MockEvents();
    analytics = Analytics(queue, events);
  });

  void serverAccepts() {
    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );
  }

  void serverIsUnreachable() {
    when(() => events.recordEvents(any())).thenThrow(Exception('offline'));
  }

  test('sends what it records and keeps nothing once it lands', () async {
    serverAccepts();

    await analytics.record(MottoEvent.shareComplete);

    final batch = verify(() => events.recordEvents(captureAny())).captured
        .single as api.EventBatch;
    expect(batch.events.single.name, 'share_complete');
    expect(queue.read(), isEmpty);
  });

  test('carries properties through', () async {
    serverAccepts();

    await analytics.record(
      MottoEvent.questionAnswered,
      properties: {'n': '5'},
    );

    final batch = verify(() => events.recordEvents(captureAny())).captured
        .single as api.EventBatch;
    expect(batch.events.single.properties, {'n': '5'});
  });

  test('a failed send neither throws nor loses the event', () async {
    serverIsUnreachable();

    // The interesting moments are the ones most likely to happen without a
    // network: someone shares the card and closes the app.
    await analytics.record(MottoEvent.shareComplete);

    expect(queue.read(), hasLength(1));
  });

  test('what was queued while offline goes out on the next flush', () async {
    serverIsUnreachable();
    await analytics.record(MottoEvent.appOpen);
    await analytics.record(MottoEvent.resultView);

    serverAccepts();
    await analytics.flush();

    final batch = verify(() => events.recordEvents(captureAny())).captured
        .last as api.EventBatch;
    expect(batch.events.map((event) => event.name), [
      'app_open',
      'result_view',
    ]);
    expect(queue.read(), isEmpty);
  });

  test('every event gets its own client id', () async {
    serverIsUnreachable();

    await analytics.record(MottoEvent.appOpen);
    await analytics.record(MottoEvent.appOpen);

    // A retry after a timeout that actually landed would otherwise inflate the
    // exact numbers this exists to measure, so the server dedupes on this —
    // which only works if two real events never share one.
    final ids = queue.read().map((entry) => entry['clientId']).toSet();
    expect(ids, hasLength(2));
  });

  test('flushing an empty queue asks the server nothing', () async {
    serverAccepts();

    await analytics.flush();

    verifyNever(() => events.recordEvents(any()));
  });

  test('a queue longer than capacity drops its oldest entries', () async {
    final entries = [
      for (var i = 0; i < EventQueue.capacity + 10; i++)
        {'clientId': '$i', 'name': 'app_open'},
    ];
    for (final entry in entries) {
      await queue.add(entry);
    }

    final kept = queue.read();
    expect(kept, hasLength(EventQueue.capacity));
    expect(kept.first['clientId'], '10');
  });

  test('a queue that cannot be parsed is dropped rather than kept forever',
      () async {
    SharedPreferences.setMockInitialValues({'analytics_queue': 'not json'});
    final broken = EventQueue(await SharedPreferences.getInstance());

    expect(broken.read(), isEmpty);
  });
}
