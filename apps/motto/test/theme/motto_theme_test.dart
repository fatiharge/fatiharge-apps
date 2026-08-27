import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/theme/motto_theme.dart';

void main() {
  group('MottoTheme', () {
    test('light and dark are two readings of one identity', () {
      expect(MottoTheme.light.colorScheme.brightness, Brightness.light);
      expect(MottoTheme.dark.colorScheme.brightness, Brightness.dark);
      expect(
        MottoTheme.light.colorScheme.primary,
        isNot(MottoTheme.dark.colorScheme.primary),
      );
    });

    test('the scaffold is painted, not left to the framework default', () {
      // A transparent scaffold takes whatever the platform paints behind it,
      // which is how a card ends up screenshotted on the wrong ground.
      expect(
        MottoTheme.dark.scaffoldBackgroundColor,
        MottoTheme.dark.colorScheme.surface,
      );
      expect(
        MottoTheme.light.scaffoldBackgroundColor,
        MottoTheme.light.colorScheme.surface,
      );
    });

    test('a filled button is tall enough to hit', () {
      final style = MottoTheme.light.filledButtonTheme.style;
      final size = style?.minimumSize?.resolve({});

      expect(size?.height, greaterThanOrEqualTo(48));
    });
  });
}
