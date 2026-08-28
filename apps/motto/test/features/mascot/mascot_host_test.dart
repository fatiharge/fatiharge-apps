import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/config/injectable.dart';
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

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    getIt.registerSingleton<MascotStore>(
      MascotStore(await SharedPreferences.getInstance()),
    );
  });

  tearDown(getIt.reset);

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

  testWidgets('it survives being built before the container exists', (
    tester,
  ) async {
    // The host wraps every route, including the one whose job is to build the
    // container. Reading get_it on that frame threw and took the app down.
    await getIt.reset();

    await tester.pumpWidget(hosted());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('a screen'), findsOneWidget);
    expect(find.byType(Mascot), findsNothing);
  });
}
