import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/test/presentation/widgets/glimpse_sheet.dart';
import 'package:motto/features/test/presentation/widgets/likert_scale.dart';
import 'package:motto/features/test/presentation/widgets/test_progress.dart';
import 'package:motto/theme/motto_theme.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: MottoTheme.dark, home: Scaffold(body: child));

void main() {
  group('LikertScale', () {
    testWidgets('offers every point and reports the one tapped', (
      tester,
    ) async {
      var picked = 0;
      await tester.pumpWidget(
        _wrap(LikertScale(onSelected: (value) => picked = value)),
      );

      expect(find.byType(InkWell), findsNWidgets(LikertScale.points));

      await tester.tap(find.byType(InkWell).last);
      expect(picked, LikertScale.points);
    });

    testWidgets('only the ends are labelled', (tester) async {
      await tester.pumpWidget(_wrap(LikertScale(onSelected: (_) {})));

      // Labelling all five turns the screen into a form.
      expect(find.text('Hiç katılmıyorum'), findsOneWidget);
      expect(find.text('Tamamen katılıyorum'), findsOneWidget);
    });

    testWidgets('the middle is drawn smaller than the ends', (tester) async {
      await tester.pumpWidget(_wrap(LikertScale(onSelected: (_) {})));
      await tester.pumpAndSettle();

      final sizes = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((container) => container.constraints?.maxWidth)
          .toList();

      // Equal circles invite the middle as if it were an opinion.
      expect(sizes.first, greaterThan(sizes[2]!));
      expect(sizes.last, greaterThan(sizes[2]!));
    });
  });

  group('GlimpseSheet', () {
    testWidgets('shows the archetype and says it may still change',
        (tester) async {
      var continued = false;
      await tester.pumpWidget(
        _wrap(
          GlimpseSheet(
            archetype: api.ArchetypeResponse(
              id: 'spark',
              name: 'Kıvılcım',
              summary: 'özet metni',
              motto: 'motto',
              confident: false,
            ),
            onContinue: () => continued = true,
          ),
        ),
      );

      expect(find.text('Kıvılcım'), findsOneWidget);
      expect(find.text('özet metni'), findsOneWidget);
      // Said plainly, because it is true and because it is the reason to keep
      // going.
      expect(find.text('Kalan sorular bunu değiştirebilir.'), findsOneWidget);

      await tester.tap(find.text('Devam et'));
      expect(continued, isTrue);
    });
  });

  group('TestProgress', () {
    testWidgets('shows how far in, without a number', (tester) async {
      await tester.pumpWidget(_wrap(const TestProgress(value: 0.4)));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // "7 / 20" tells someone how much is left to endure.
      expect(find.textContaining('/'), findsNothing);
    });
  });
}
