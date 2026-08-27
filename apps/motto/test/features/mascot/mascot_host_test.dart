import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/mascot/presentation/mascot.dart';
import 'package:motto/features/mascot/presentation/mascot_host.dart';
import 'package:rive/rive.dart';

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
}
