import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/route/reloads_on_return.dart';

/// A page that counts how many times it was told to read again.
class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> with ReloadsOnReturn {
  int reloads = 0;

  @override
  void reload() => reloads++;

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  testWidgets('a page outside the router still builds', (tester) async {
    // The tab views are pumped on their own in their own tests, and a mixin
    // that only works inside the app would take those down with it.
    await tester.pumpWidget(const MaterialApp(home: _Page()));

    expect(tester.takeException(), isNull);
    expect(tester.state<_PageState>(find.byType(_Page)).reloads, 0);
  });

  testWidgets('the screen that covered it going away is the signal', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _Page()));
    final state = tester.state<_PageState>(find.byType(_Page))..didPopNext();

    expect(state.reloads, 1);
  });

  testWidgets('nothing else is', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _Page()));
    // Pushing, popping this page itself, and switching tabs all leave what it
    // reads alone; only a screen closing on top of it changes anything.
    final state = tester.state<_PageState>(find.byType(_Page))
      ..didPush()
      ..didPop()
      ..didPushNext();

    expect(state.reloads, 0);
  });
}
