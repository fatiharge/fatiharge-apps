import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/support/presentation/widgets/could_not_load.dart';

void main() {
  group('a screen that could not read what it needed', () {
    testWidgets('says what is missing and asks again with the same call', (
      tester,
    ) async {
      var asked = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CouldNotLoad(
              said: 'Profil yüklenemedi.',
              retry: () => asked++,
            ),
          ),
        ),
      );

      expect(find.text('Profil yüklenemedi.'), findsOneWidget);
      await tester.tap(find.text('Tekrar dene'));
      await tester.pump();

      // The promise is that pressing it asks for exactly the same thing again.
      expect(asked, 1);
    });

    testWidgets('inline keeps the same promise in a page that has more', (
      tester,
    ) async {
      var asked = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                const Text('bu kalıyor'),
                CouldNotLoad.inline(said: 'Alınamadı.', retry: () => asked++),
              ],
            ),
          ),
        ),
      );

      // Losing what still worked because one part failed took a working chain
      // off the screen once.
      expect(find.text('bu kalıyor'), findsOneWidget);
      await tester.tap(find.text('Tekrar dene'));
      expect(asked, 1);
    });

    testWidgets('nothing to press looks like nothing to press', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CouldNotLoad(said: 'Olmadı.', retry: null)),
        ),
      );

      expect(find.text('Tekrar dene'), findsNothing);
      expect(find.text('Olmadı.'), findsOneWidget);
    });
  });
}
