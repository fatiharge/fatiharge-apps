import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/support/domain/faq.dart';
import 'package:motto/features/support/presentation/faq_page.dart';

void main() {
  testWidgets('the questions render with no network at all', (tester) async {
    // The moment someone wonders where their data went is the moment they are
    // least likely to have a connection. Nothing on this screen may need one.
    await tester.pumpWidget(const MaterialApp(home: FaqPage()));

    // A count would only assert how many fit on screen — the list is lazy.
    expect(find.text(faq.first.question), findsOneWidget);
    expect(find.byType(ExpansionTile), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a linked entry is already open', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FaqPage(openItem: 'chain_broken')),
    );

    final answer = faq.firstWhere((item) => item.id == 'chain_broken').answer;
    expect(find.text(answer), findsOneWidget);
  });

  test('every entry has a unique id, or a link would be ambiguous', () {
    expect(faq.map((item) => item.id).toSet(), hasLength(faq.length));
  });

  test('the questions that get asked are all answered', () {
    // Twelve is the floor the plan set: below it the complaints this exists to
    // absorb start arriving as store reviews instead.
    expect(faq.length, greaterThanOrEqualTo(12));
    expect(
      faq.map((item) => item.id),
      containsAll(['lost_data', 'delete_data', 'not_me', 'chain_broken']),
    );
  });
}
