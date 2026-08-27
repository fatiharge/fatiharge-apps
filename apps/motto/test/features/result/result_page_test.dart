import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/result/presentation/result_page.dart';
import 'package:motto/theme/motto_theme.dart';

void main() {
  final result = api.ResultResponse(
    archetype: api.ArchetypeResponse(
      id: 'quiet_builder',
      name: 'Sessiz İnşacı',
      summary: 'Gürültü çıkarmadan biriktirirsin.',
      motto: 'Acele etmeyen ama durmayan.',
      confident: true,
    ),
    entitlement: api.EntitlementResponse(
      remainingUses: 1,
      skipsLeft: 1,
      premium: false,
    ),
  );

  testWidgets('shows the archetype, what it means and the motto', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: MottoTheme.dark, home: ResultPage(result: result)),
    );

    expect(find.text('Sessiz İnşacı'), findsOneWidget);
    expect(find.text('Gürültü çıkarmadan biriktirirsin.'), findsOneWidget);
    expect(find.text('"Acele etmeyen ama durmayan."'), findsOneWidget);
  });

  testWidgets('renders in both themes', (tester) async {
    for (final theme in [MottoTheme.light, MottoTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(theme: theme, home: ResultPage(result: result)),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
