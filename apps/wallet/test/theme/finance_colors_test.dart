import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/theme/app_theme.dart';
import 'package:wallet/theme/finance_colors.dart';

/// Contrast ratio between [foreground] and [background], per WCAG 2.1.
double _contrast(Color foreground, Color background) {
  final a = _relativeLuminance(foreground);
  final b = _relativeLuminance(background);
  final lighter = math.max(a, b);
  final darker = math.min(a, b);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double linear(double channel) => channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * linear(color.r) +
      0.7152 * linear(color.g) +
      0.0722 * linear(color.b);
}

void main() {
  group('FinanceColors', () {
    test(
      'the light theme carries the light pair, the dark one the dark pair',
      () {
        expect(
          AppTheme.light().extension<FinanceColors>(),
          FinanceColors.light,
        );
        expect(AppTheme.dark().extension<FinanceColors>(), FinanceColors.dark);
      },
    );

    testWidgets('of() reads the pair in force for the theme', (tester) async {
      late FinanceColors seen;

      Future<void> pump(ThemeData theme) => tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              seen = FinanceColors.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await pump(AppTheme.light());
      expect(seen, FinanceColors.light);

      // MaterialApp animates between themes, so the pair is mid-lerp for a few
      // frames after the swap — settle before reading it.
      await pump(AppTheme.dark());
      await tester.pumpAndSettle();
      expect(seen, FinanceColors.dark);
    });

    test('amountColor picks by direction, not by sign', () {
      expect(
        FinanceColors.light.amountColor(isExpense: true),
        FinanceColors.light.expense,
      );
      expect(
        FinanceColors.light.amountColor(isExpense: false),
        FinanceColors.light.income,
      );
    });

    test('lerp lands on each end and moves between them', () {
      expect(
        FinanceColors.light.lerp(FinanceColors.dark, 0),
        FinanceColors.light,
      );
      expect(
        FinanceColors.light.lerp(FinanceColors.dark, 1),
        FinanceColors.dark,
      );
      expect(
        FinanceColors.light.lerp(FinanceColors.dark, 0.5).income,
        isNot(FinanceColors.light.income),
      );
    });

    test('lerp against null keeps the receiver', () {
      expect(FinanceColors.light.lerp(null, 0.5), FinanceColors.light);
    });

    test('copyWith replaces only what it is given', () {
      final swapped = FinanceColors.light.copyWith(
        income: const Color(0xFF00FF00),
      );
      expect(swapped.income, const Color(0xFF00FF00));
      expect(swapped.expense, FinanceColors.light.expense);
    });

    test('both colours clear 4.5:1 against their own surface', () {
      final light = AppTheme.light().colorScheme.surface;
      final dark = AppTheme.dark().colorScheme.surface;

      expect(_contrast(FinanceColors.light.income, light), greaterThan(4.5));
      expect(_contrast(FinanceColors.light.expense, light), greaterThan(4.5));
      expect(_contrast(FinanceColors.dark.income, dark), greaterThan(4.5));
      expect(_contrast(FinanceColors.dark.expense, dark), greaterThan(4.5));
    });
  });
}
