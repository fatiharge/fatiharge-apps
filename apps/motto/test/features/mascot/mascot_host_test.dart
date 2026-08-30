import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/config/app_ready.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/mascot/application/mascot_controller.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';
import 'package:motto/features/mascot/presentation/mascot.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The renderer needs a native library `flutter test` does not have, so the
/// file never loads here. What is under test is the host: where the mascot
/// sits, how far it can be dragged, and that the screen survives it.
Widget hosted() => MaterialApp(
  home: const Scaffold(body: Center(child: Text('a screen'))),
  builder: (context, child) => MascotHost(
    loadFile: (_) => Future<RiveFile>.error(StateError('no renderer')),
    child: child ?? const SizedBox(),
  ),
);

/// Stands in for rive's controller, which cannot exist here.
class _FakeMascot implements MascotController {
  int pokes = 0;
  bool offered = false;

  @override
  double annoyance = 0;

  @override
  void poke() => pokes++;

  @override
  void offerGame() => offered = true;

  @override
  void drag({required bool held, double x = 0, double y = 0}) {}

  @override
  void attention() {}

  @override
  void flee() {}

  @override
  void celebrate() {}
}

/// The host with a controller and a clock, which is the only way to reach the
/// tap path: the renderer never loads here.
Widget played({
  required MascotController mascot,
  required DateTime Function() clock,
  VoidCallback? onGameOffered,
}) => MaterialApp(
  home: const Scaffold(body: Center(child: Text('a screen'))),
  builder: (context, child) => MascotHost(
    loadFile: (_) => Future<RiveFile>.error(StateError('no renderer')),
    controller: mascot,
    clock: clock,
    onGameOffered: onGameOffered,
    child: child ?? const SizedBox(),
  ),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    getIt.registerSingleton<MascotStore>(
      MascotStore(await SharedPreferences.getInstance()),
    );
    appReady.value = true;
  });

  tearDown(() async {
    appReady.value = false;
    await getIt.reset();
  });

  group('the way into the game', () {
    testWidgets('a tap on the offer opens it', (tester) async {
      var now = DateTime(2026, 8, 30, 12);
      var opened = false;
      final mascot = _FakeMascot();

      await tester.pumpWidget(
        played(
          mascot: mascot,
          clock: () => now,
          onGameOffered: () => opened = true,
        ),
      );
      await tester.pump();
      // The renderer is not here; the fake controller stands in for it.
      tester.takeException();

      // Bored long enough for the offer to go up.
      now = now.add(const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 5));
      expect(mascot.offered, isTrue);

      await tester.tap(find.byType(Mascot), warnIfMissed: false);
      await tester.pump();

      // The tap is a whole gesture: the drag recognizer loses the arena and
      // cancels first. Counting that cancel as somebody holding the mascot
      // cleared the offer before the tap arrived, and the game could not be
      // opened at all.
      expect(opened, isTrue);
      expect(mascot.pokes, 0);
    });

    testWidgets('a tap before the offer is only a poke', (tester) async {
      final now = DateTime(2026, 8, 30, 12);
      var opened = false;
      final mascot = _FakeMascot();

      await tester.pumpWidget(
        played(
          mascot: mascot,
          clock: () => now,
          onGameOffered: () => opened = true,
        ),
      );
      await tester.pump();
      tester.takeException();

      await tester.tap(find.byType(Mascot), warnIfMissed: false);
      await tester.pump();

      expect(opened, isFalse);
      expect(mascot.pokes, 1);
    });
  });

  testWidgets('switching it off takes it off the screen', (tester) async {
    await tester.pumpWidget(hosted());
    await tester.pump();
    tester.takeException();
    expect(find.byType(Mascot), findsOneWidget);

    await getIt<MascotStore>().setVisible(value: false);
    await tester.pump();

    // Off means gone: no widget, no state machine, no timers.
    expect(find.byType(Mascot), findsNothing);
    expect(find.text('a screen'), findsOneWidget);
  });

  testWidgets('the mascot floats above whatever screen is showing', (
    tester,
  ) async {
    await tester.pumpWidget(hosted());
    await tester.pump();
    tester.takeException();

    expect(find.text('a screen'), findsOneWidget);
    expect(find.byType(Mascot), findsOneWidget);
  });

  testWidgets('it starts out of the way, at the bottom right', (tester) async {
    await tester.pumpWidget(hosted());
    await tester.pump();
    tester.takeException();

    final screen = tester.getSize(find.byType(MaterialApp));
    final at = tester.getTopLeft(find.byType(Mascot));

    expect(at.dx, greaterThan(screen.width / 2));
    expect(at.dy, greaterThan(screen.height / 2));
  });

  testWidgets('and clear of the button every screen puts at the bottom', (
    tester,
  ) async {
    await tester.pumpWidget(hosted());
    await tester.pump();
    tester.takeException();

    final screen = tester.getSize(find.byType(MaterialApp));
    final bottom = tester.getBottomLeft(find.byType(Mascot)).dy;

    // It resolved to the exact corner before this: the offsets said "up and
    // in" and the arithmetic added them straight back.
    expect(
      screen.height - bottom,
      greaterThanOrEqualTo(MascotHost.bottomActionRoom),
    );
  });

  testWidgets('it can be dragged anywhere and settles against a side', (
    tester,
  ) async {
    await tester.pumpWidget(hosted());
    await tester.pump();
    tester.takeException();

    final started = tester.getTopLeft(find.byType(Mascot));
    await tester.drag(find.byType(Mascot), const Offset(-560, -300));
    await tester.pump();

    final dragged = tester.getTopLeft(find.byType(Mascot));
    expect(dragged.dx, lessThan(started.dx));
    expect(dragged.dy, lessThan(started.dy));

    await tester.pumpAndSettle();

    // Left in the middle it covers what someone is reading; against an edge it
    // is still reachable and out of the way.
    final settled = tester.getTopLeft(find.byType(Mascot));
    expect(settled.dx, lessThan(24));
    expect(settled.dy, closeTo(dragged.dy, 1));
  });

  testWidgets('it cannot be dragged off the screen', (tester) async {
    await tester.pumpWidget(hosted());
    await tester.pump();
    tester.takeException();

    await tester.drag(find.byType(Mascot), const Offset(-2000, -2000));
    await tester.pumpAndSettle();

    final at = tester.getTopLeft(find.byType(Mascot));
    expect(at.dx, greaterThanOrEqualTo(0));
    expect(at.dy, greaterThanOrEqualTo(0));
  });

  testWidgets('a mascot that cannot load leaves the screen alone', (
    tester,
  ) async {
    await tester.pumpWidget(hosted());
    await tester.pump();

    // A broken asset in production has this same shape: reported, and the
    // screen underneath carries on.
    expect(tester.takeException(), isA<StateError>());
    expect(find.text('a screen'), findsOneWidget);
  });

  testWidgets('it walks to a spot on its own', (tester) async {
    late MascotMovement move;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            move = MascotHost.movementOf(context)!;
            return const Scaffold(body: SizedBox());
          },
        ),
        builder: (context, child) => MascotHost(
          loadFile: (_) => Future<RiveFile>.error(StateError('no renderer')),
          child: child ?? const SizedBox(),
        ),
      ),
    );
    await tester.pump();
    tester.takeException();

    final started = tester.getTopLeft(find.byType(Mascot));
    // A mascot that only ever moves when dragged is a decoration; onboarding
    // has to be able to walk it around while it explains itself.
    unawaited(move(MascotSpot.topLeft));
    await tester.pumpAndSettle();

    final arrived = tester.getTopLeft(find.byType(Mascot));
    expect(arrived.dx, lessThan(started.dx));
    expect(arrived.dy, lessThan(started.dy));
    expect(arrived.dx, lessThan(24));
  });

  testWidgets('it waits for the container rather than reading an empty one', (
    tester,
  ) async {
    // This builder runs once, before the container exists. Reading get_it
    // there threw; skipping it silently meant the mascot never appeared at
    // all, which is what actually shipped.
    appReady.value = false;
    await tester.pumpWidget(hosted());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Mascot), findsNothing);

    appReady.value = true;
    await tester.pump();
    // The loader fails here on purpose; the mascot widget is what matters.
    tester.takeException();

    expect(find.byType(Mascot), findsOneWidget);
  });
}
