import 'package:api_client_motto/api.dart' as motto;
import 'package:injectable/injectable.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:motto/infrastructure/analytics/motto_event.dart';
import 'package:uuid/uuid.dart';

/// [record] never throws and never waits on the network: the event lands in
/// [EventQueue] first and the flush is best-effort on top of it.
@lazySingleton
class Analytics {
  Analytics(this._queue, this._events);

  /// The limit the server enforces.
  static const _batch = 100;

  static const _ids = Uuid();

  final EventQueue _queue;
  final motto.EventResourceApi _events;

  /// Two flushes would remove the same rows from the queue twice.
  Future<void>? _flushing;

  Future<void> record(
    MottoEvent event, {
    Map<String, String> properties = const {},
  }) async {
    await _queue.add({
      'clientId': _ids.v4(),
      'name': event.wireName,
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
      'properties': properties,
    });

    await flush();
  }

  Future<void> flush() {
    return _flushing ??= _flush().whenComplete(() => _flushing = null);
  }

  Future<void> _flush() async {
    final entries = _queue.read();
    if (entries.isEmpty) return;

    final sending = entries.take(_batch).toList();

    try {
      await _events.recordEvents(
        motto.EventBatch(
          events: [for (final entry in sending) _entry(entry)],
        ),
      );
    } on Object {
      // The entries stay queued and the next recorded event tries again.
      return;
    }

    await _queue.removeFirst(sending.length);
  }

  motto.EventEntry _entry(Map<String, Object?> entry) => motto.EventEntry(
    clientId: entry['clientId']! as String,
    name: entry['name']! as String,
    occurredAt: DateTime.parse(entry['occurredAt']! as String),
    properties: (entry['properties'] as Map<String, dynamic>? ?? {}).cast(),
  );
}
