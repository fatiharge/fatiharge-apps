import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePort extends BootstrapPort {
  _FakePort(this._jobs);

  final List<BootstrapJob> _jobs;
  bool finished = false;

  @override
  List<BootstrapJob> jobs() => _jobs;

  @override
  void bootstrapFinished() => finished = true;
}

void main() {
  group('BootstrapCubit', () {
    test('runs all jobs, reports progress, and finishes', () async {
      final calls = <String>[];
      final port = _FakePort([
        BootstrapJob('a', () async => calls.add('a')),
        BootstrapJob('b', () async => calls.add('b')),
      ]);
      final cubit = BootstrapCubit(port);
      addTearDown(cubit.close);

      await cubit.start();

      expect(calls, ['a', 'b']);
      expect(port.finished, isTrue);
      expect(cubit.state, isA<BootstrapRunning>());
      expect((cubit.state as BootstrapRunning).progress, 1.0);
    });

    test('stops on a retry-policy failure, then resumes', () async {
      var attempts = 0;
      final port = _FakePort([
        BootstrapJob(
          'flaky',
          () async {
            attempts++;
            if (attempts == 1) throw Exception('boom');
          },
        ),
      ]);
      final cubit = BootstrapCubit(port);
      addTearDown(cubit.close);

      await cubit.start();
      expect(cubit.state, isA<BootstrapFailed>());
      expect((cubit.state as BootstrapFailed).canRetry, isTrue);
      expect(port.finished, isFalse);

      await cubit.retry();
      expect(port.finished, isTrue);
      expect(cubit.state, isA<BootstrapRunning>());
    });

    test('skip policy logs and continues past a failing job', () async {
      final calls = <String>[];
      final port = _FakePort([
        BootstrapJob(
          'optional',
          () async => throw Exception('nope'),
          errorPolicy: BootstrapErrorPolicy.skip,
        ),
        BootstrapJob('after', () async => calls.add('after')),
      ]);
      final cubit = BootstrapCubit(port);
      addTearDown(cubit.close);

      await cubit.start();

      expect(calls, ['after']);
      expect(port.finished, isTrue);
    });

    test('fallback recovers a failed job and the flow continues', () async {
      var recovered = false;
      final port = _FakePort([
        BootstrapJob(
          'needs-fallback',
          () async => throw Exception('primary failed'),
          fallback: (_) async => recovered = true,
        ),
      ]);
      final cubit = BootstrapCubit(port);
      addTearDown(cubit.close);

      await cubit.start();

      expect(recovered, isTrue);
      expect(port.finished, isTrue);
      expect(cubit.state, isA<BootstrapRunning>());
    });

    test('retries the configured number of times before failing', () async {
      var attempts = 0;
      final port = _FakePort([
        BootstrapJob(
          'always-fails',
          () async {
            attempts++;
            throw Exception('boom');
          },
          retries: 2,
          retryDelay: Duration.zero,
        ),
      ]);
      final cubit = BootstrapCubit(port);
      addTearDown(cubit.close);

      await cubit.start();

      expect(attempts, 3); // 1 initial + 2 retries
      expect(cubit.state, isA<BootstrapFailed>());
    });
  });
}
