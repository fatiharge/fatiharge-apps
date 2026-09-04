import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/presentation/splash.dart';
import 'package:kiyma/presentation/startup_page.dart';

/// A port with jobs the test controls, so the startup screen can be driven
/// without loading the real scene.
class _FakePort implements BootstrapPort {
  _FakePort(this._jobs);

  final List<BootstrapJob> _jobs;
  bool finished = false;

  @override
  List<BootstrapJob> jobs() => _jobs;

  @override
  void bootstrapFinished() => finished = true;
}

void main() {
  Future<_FakePort> open(WidgetTester tester, List<BootstrapJob> jobs) async {
    final port = _FakePort(jobs);
    await getIt.reset();
    getIt.registerSingleton<BootstrapPort>(port);
    await tester.pumpWidget(const MaterialApp(home: StartupPage()));
    await tester.pump();
    return port;
  }

  tearDownAll(() async => getIt.reset());

  testWidgets('shows the splash while the jobs run', (tester) async {
    final port = await open(tester, [
      BootstrapJob('scene', () async {}),
      BootstrapJob('art', () async {}),
    ]);

    expect(find.byType(SplashView), findsOneWidget);
    expect(port.finished, isFalse, reason: 'the brand screen is held');

    // The jobs are instant; what is left is the floor under the splash.
    await tester.pump(StartupPage.hold - const Duration(milliseconds: 500));
    expect(port.finished, isFalse);

    await tester.pump(const Duration(seconds: 1));
    expect(port.finished, isTrue);
  });

  testWidgets('names the job that failed', (tester) async {
    await open(tester, [
      BootstrapJob(
        'art',
        () async => throw StateError('no images'),
        errorPolicy: BootstrapErrorPolicy.restart,
      ),
    ]);
    await tester.pump();

    expect(find.text('Tezgah kurulamadı'), findsOneWidget);
    expect(find.textContaining('art:'), findsOneWidget);
    // Every job here is fatal, so there is nothing to retry into.
    expect(find.text('Yeniden dene'), findsNothing);
  });

  testWidgets('offers a retry when the policy allows one', (tester) async {
    var attempts = 0;
    await open(tester, [
      BootstrapJob('scene', () async {
        attempts++;
        throw StateError('not yet');
      }),
    ]);
    await tester.pump();

    expect(find.text('Yeniden dene'), findsOneWidget);
    await tester.tap(find.text('Yeniden dene'));
    await tester.pump();
    expect(attempts, 2);
  });
}
