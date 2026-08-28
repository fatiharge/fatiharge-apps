import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/shell/presentation/widgets/floating_nav_bar.dart';

const _items = [
  NavItem(icon: Icons.today_outlined, filled: Icons.today, label: 'Bugün'),
  NavItem(icon: Icons.person_outline, filled: Icons.person, label: 'Profil'),
];

Widget bar({int index = 0, ValueChanged<int>? onSelected}) => MaterialApp(
  home: Scaffold(
    bottomNavigationBar: FloatingNavBar(
      items: _items,
      index: index,
      onSelected: onSelected ?? (_) {},
    ),
  ),
);

void main() {
  testWidgets('only the selected item is labelled', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    // Two labels sitting there permanently is what makes a bar look like 2014.
    expect(find.text('Bugün'), findsOneWidget);
    expect(find.text('Profil'), findsNothing);
  });

  testWidgets('the selected item is filled, the other outlined', (
    tester,
  ) async {
    await tester.pumpWidget(bar(index: 1));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.today_outlined), findsOneWidget);
  });

  testWidgets('tapping the other side selects it', (tester) async {
    int? chosen;
    await tester.pumpWidget(bar(onSelected: (index) => chosen = index));

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump();

    expect(chosen, 1);
  });

  testWidgets('it renders in both themes', (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            bottomNavigationBar: FloatingNavBar(
              items: _items,
              index: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });
}
