import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePort extends BootstrapPort {
  _FakePort(this._jobs);

  final List<BootstrapJob> _jobs;
  bool finished = false;

  @override
  List<BootstrapJob> jobs() => _jobs;

  @override
  Widget get bootstrapView =>
      const Scaffold(body: Center(child: Text('splash')));

  @override
  void bootstrapFinished() => finished = true;
}

void main() {
  group('BootstrapPage', () {
    testWidgets('shows the port view while jobs run, then finishes', (
      tester,
    ) async {
      final port = _FakePort([BootstrapJob('a', () async {})]);

      await tester.pumpWidget(MaterialApp(home: BootstrapPage(port: port)));

      expect(find.text('splash'), findsOneWidget);
      expect(port.finished, isFalse);

      // The cubit holds the splash for a minimum duration so it cannot flash.
      await tester.pump(const Duration(seconds: 2));

      expect(port.finished, isTrue);
    });

    testWidgets('runningBuilder receives live progress', (tester) async {
      final port = _FakePort([
        BootstrapJob('a', () async {}),
        BootstrapJob('b', () async {}),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: BootstrapPage(
            port: port,
            runningBuilder: (context, state) => Scaffold(
              body: Center(child: Text('${state.completed}/${state.total}')),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('shows a retry action for a recoverable failure', (
      tester,
    ) async {
      var attempts = 0;
      final port = _FakePort([
        BootstrapJob('flaky', () async {
          attempts++;
          if (attempts == 1) throw Exception('boom');
        }),
      ]);

      await tester.pumpWidget(MaterialApp(home: BootstrapPage(port: port)));
      await tester.pump();

      expect(find.text('flaky'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(port.finished, isFalse);

      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(seconds: 2));

      expect(attempts, 2);
      expect(port.finished, isTrue);
    });

    testWidgets('offers no retry when the policy is restart', (tester) async {
      final port = _FakePort([
        BootstrapJob(
          'fatal',
          () async => throw Exception('unrecoverable'),
          errorPolicy: BootstrapErrorPolicy.restart,
        ),
      ]);

      await tester.pumpWidget(MaterialApp(home: BootstrapPage(port: port)));
      await tester.pump();

      expect(find.text('fatal'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('errorBuilder replaces the default failure screen', (
      tester,
    ) async {
      final port = _FakePort([
        BootstrapJob('boom', () async => throw Exception('nope')),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: BootstrapPage(
            port: port,
            errorBuilder: (context, state, onRetry) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: onRetry,
                  child: Text('custom ${state.jobName}'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('custom boom'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
