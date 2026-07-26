import 'dart:async';

import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Crash = ({Object error, StackTrace? stack, bool fatal});

class _RecordingCrashListener extends CrashListener {
  final List<_Crash> crashes = <_Crash>[];

  @override
  Future<void> onCrash({
    required Object error,
    required StackTrace? stack,
    required bool fatal,
  }) async => crashes.add((error: error, stack: stack, fatal: fatal));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CrashListener', () {
    late FlutterExceptionHandler? originalOnError;

    setUp(() => originalOnError = FlutterError.onError);
    tearDown(() => FlutterError.onError = originalOnError);

    test('runs the body inside the guarded zone', () async {
      final listener = _RecordingCrashListener();
      var ran = false;

      await listener.runGuarded(() async => ran = true);

      expect(ran, isTrue);
      expect(listener.crashes, isEmpty);
    });

    test('reports framework errors as non-fatal', () async {
      final listener = _RecordingCrashListener();
      final error = StateError('layout overflowed');

      await listener.runGuarded(() async {
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: StackTrace.current),
        );
      });

      expect(listener.crashes, hasLength(1));
      expect(listener.crashes.single.error, same(error));
      expect(listener.crashes.single.fatal, isFalse);
      expect(listener.crashes.single.stack, isNotNull);
    });

    test('reports uncaught async errors as fatal', () async {
      final listener = _RecordingCrashListener();
      final error = StateError('async boom');

      await listener.runGuarded(() async {
        unawaited(Future<void>.error(error, StackTrace.current));
      });
      // The zone handler fires on a later microtask than the body's return.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(listener.crashes, hasLength(1));
      expect(listener.crashes.single.error, same(error));
      expect(listener.crashes.single.fatal, isTrue);
    });

    test('an error from the body itself is captured, not rethrown', () async {
      final listener = _RecordingCrashListener();

      await listener.runGuarded(() async => throw StateError('startup failed'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(listener.crashes, hasLength(1));
      expect(listener.crashes.single.fatal, isTrue);
    });

    test('installs a handler that still presents the error', () async {
      final listener = _RecordingCrashListener();
      var presented = 0;
      final originalPresent = FlutterError.presentError;
      FlutterError.presentError = (details) => presented++;
      addTearDown(() => FlutterError.presentError = originalPresent);

      await listener.runGuarded(() async {
        FlutterError.reportError(
          FlutterErrorDetails(exception: StateError('boom')),
        );
      });

      expect(presented, 1);
      expect(listener.crashes, hasLength(1));
    });
  });
}
