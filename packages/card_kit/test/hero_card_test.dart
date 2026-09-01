import 'package:card_kit/card_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );

  testWidgets('başlığı ve üst etiketi çiziyor', (tester) async {
    await pump(
      tester,
      const HeroCard(
        data: HeroCardData(
          imageUrl: null,
          headline: 'Kamp kadrosu açıklandı',
          eyebrow: 'Haber',
        ),
      ),
    );

    expect(find.text('Kamp kadrosu açıklandı'), findsOneWidget);
    // Üst etiket büyük harfe çevriliyor.
    expect(find.text('HABER'), findsOneWidget);
  });

  testWidgets('üst etiket boşsa hiç çizilmiyor', (tester) async {
    await pump(
      tester,
      const HeroCard(
        data: HeroCardData(imageUrl: null, headline: 'Başlık', eyebrow: ''),
      ),
    );

    // Boş bir etiket, boş bir satır kadar yer kaplamamalı.
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('görsel yoksa kart çökmüyor, yer tutucu çiziyor', (tester) async {
    await pump(
      tester,
      const HeroCard(
        data: HeroCardData(imageUrl: null, headline: 'Görselsiz'),
      ),
    );

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('onTap yoksa kart tepkisiz — önizlemenin hâli', (tester) async {
    await pump(
      tester,
      const HeroCard(data: HeroCardData(imageUrl: null, headline: 'Önizleme')),
    );

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.onTap, isNull);
  });

  testWidgets('onTap varsa dokunuş bir kez geçiyor', (tester) async {
    var taps = 0;
    await pump(
      tester,
      HeroCard(
        data: const HeroCardData(imageUrl: null, headline: 'Tıklanabilir'),
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(HeroCard));
    expect(taps, 1);
  });
}
