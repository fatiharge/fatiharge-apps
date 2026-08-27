import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/welcome/presentation/welcome_page.dart';
import 'package:motto/theme/motto_theme.dart';

Widget _wrap(Widget child, ThemeData theme) =>
    MaterialApp(theme: theme, home: child);

void main() {
  group('WelcomePage', () {
    testWidgets('introduces the app and offers a way in', (tester) async {
      await tester.pumpWidget(_wrap(const WelcomePage(), MottoTheme.light));

      expect(find.text('Motto'), findsOneWidget);
      expect(find.text('Başla'), findsOneWidget);
    });

    testWidgets('renders in both themes', (tester) async {
      for (final theme in [MottoTheme.light, MottoTheme.dark]) {
        await tester.pumpWidget(_wrap(const WelcomePage(), theme));
        expect(tester.takeException(), isNull);
      }
    });
  });
}
