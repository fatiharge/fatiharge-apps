import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/result/presentation/widgets/share_card.dart';
import 'package:motto/theme/motto_palette.dart';
import 'package:motto/theme/motto_theme.dart';

void main() {
  final archetype = api.ArchetypeResponse(
    id: 'quiet_builder',
    name: 'Sessiz İnşacı',
    summary: 'Gürültü çıkarmadan biriktirirsin.',
    motto: 'Acele etmeyen ama durmayan.',
    confident: true,
  );

  Widget card(ThemeData theme) => MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Center(child: ShareCard(archetype: archetype)),
    ),
  );

  testWidgets('carries the name, what it means and the motto', (tester) async {
    await tester.pumpWidget(card(MottoTheme.dark));

    expect(find.text('Sessiz İnşacı'), findsOneWidget);
    expect(find.text('Gürültü çıkarmadan biriktirirsin.'), findsOneWidget);
    expect(find.text('“Acele etmeyen ama durmayan.”'), findsOneWidget);
  });

  testWidgets('says inventory, never test result', (tester) async {
    await tester.pumpWidget(card(MottoTheme.dark));

    // Guideline 1.4.1 is about which words were used, and this is the most
    // screenshotted surface in the product.
    expect(find.text('KİŞİLİK ENVANTERİ'), findsOneWidget);
    expect(find.textContaining('test sonuc'), findsNothing);
  });

  testWidgets('keeps its own look in a light app', (tester) async {
    await tester.pumpWidget(card(MottoTheme.light));

    // The exported image is looked at in someone else's feed, not in the app.
    // It has one deliberate look, and this is the single place the system
    // theme is ignored on purpose.
    final ground = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(ShareCard),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(ground.color, MottoPalette.darkSurface);
  });

  testWidgets('is the shape every feed wants', (tester) async {
    await tester.pumpWidget(card(MottoTheme.dark));

    final box = tester.getSize(find.byType(ShareCard));

    expect(box.width / box.height, closeTo(ShareCard.aspectRatio, 0.01));
  });
}
