import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/theme/app_theme.dart';
import 'package:wallet/theme/finance_colors.dart';

/// 4.5:1 is the WCAG AA floor for body text, 3:1 for large text and for the
/// parts of an icon or control that carry its meaning.
void main() {
  /// WCAG 2.x relative luminance.
  double luminance(Color color) {
    double channel(double value) {
      final v = value;
      return v <= 0.03928
          ? v / 12.92
          : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  double contrast(Color a, Color b) {
    final first = luminance(a);
    final second = luminance(b);
    final lighter = math.max(first, second);
    final darker = math.min(first, second);
    return (lighter + 0.05) / (darker + 0.05);
  }

  void expectAtLeast(double ratio, double floor, String what) {
    expect(
      ratio,
      greaterThanOrEqualTo(floor),
      reason: '$what is ${ratio.toStringAsFixed(2)}:1, under $floor:1',
    );
  }

  group('amount colours clear AA on the surface they sit on', () {
    test('light', () {
      final scheme = AppTheme.light().colorScheme;

      expectAtLeast(
        contrast(FinanceColors.light.income, scheme.surface),
        4.5,
        'income on light surface',
      );
      expectAtLeast(
        contrast(FinanceColors.light.expense, scheme.surface),
        4.5,
        'expense on light surface',
      );
    });

    test('dark', () {
      final scheme = AppTheme.dark().colorScheme;

      expectAtLeast(
        contrast(FinanceColors.dark.income, scheme.surface),
        4.5,
        'income on dark surface',
      );
      expectAtLeast(
        contrast(FinanceColors.dark.expense, scheme.surface),
        4.5,
        'expense on dark surface',
      );
    });
  });

  group('the scheme pairs Material actually draws with', () {
    for (final (name, theme) in [
      ('light', AppTheme.light()),
      ('dark', AppTheme.dark()),
    ]) {
      test(name, () {
        final scheme = theme.colorScheme;
        final pairs = <String, (Color, Color)>{
          'onSurface/surface': (scheme.onSurface, scheme.surface),
          'onSurface/surfaceContainerLow': (
            scheme.onSurface,
            scheme.surfaceContainerLow,
          ),
          'onPrimary/primary': (scheme.onPrimary, scheme.primary),
          'onError/error': (scheme.onError, scheme.error),
          'onErrorContainer/errorContainer': (
            scheme.onErrorContainer,
            scheme.errorContainer,
          ),
          'primary/surface': (scheme.primary, scheme.surface),
        };
        // Lighter by design, so held to the large-text floor.
        final secondary = contrast(scheme.onSurfaceVariant, scheme.surface);

        pairs.forEach((label, pair) {
          expectAtLeast(contrast(pair.$1, pair.$2), 4.5, '$name $label');
        });
        expectAtLeast(secondary, 3, '$name onSurfaceVariant/surface');
      });
    }
  });

  test('the mark teal stays out of text, as its comment says', () {
    // A measurement, not a warning: the number anyone reaching for it as a
    // foreground colour is up against.
    final onWhite = contrast(AppTheme.teal, const Color(0xFFFFFFFF));

    expect(onWhite, lessThan(3), reason: 'teal is $onWhite:1 on white');
  });
}
