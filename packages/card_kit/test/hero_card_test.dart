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

  group('HeroCardData', () {
    // Kart bir listede yeniden çiziliyor ve Flutter aynı veriyle gereksiz
    // çizimden kaçınmak için eşitliğe bakıyor. Elle yazılmış bir == her zaman
    // bir alanı unutmaya açıktır, o yüzden sınanıyor.
    const base = HeroCardData(
      imageUrl: 'https://example.com/a.jpg',
      headline: 'Başlık',
      eyebrow: 'Haber',
    );

    test('aynı alanlar eşit ve aynı hash', () {
      const same = HeroCardData(
        imageUrl: 'https://example.com/a.jpg',
        headline: 'Başlık',
        eyebrow: 'Haber',
      );

      expect(base, same);
      expect(base.hashCode, same.hashCode);
      expect(base, base);
    });

    test('her alan tek başına eşitliği bozuyor', () {
      expect(
        base,
        isNot(
          const HeroCardData(
            imageUrl: 'https://example.com/b.jpg',
            headline: 'Başlık',
            eyebrow: 'Haber',
          ),
        ),
      );
      expect(
        base,
        isNot(
          const HeroCardData(
            imageUrl: 'https://example.com/a.jpg',
            headline: 'Başka',
            eyebrow: 'Haber',
          ),
        ),
      );
      expect(
        base,
        isNot(
          const HeroCardData(
            imageUrl: 'https://example.com/a.jpg',
            headline: 'Başlık',
            eyebrow: 'Duyuru',
          ),
        ),
      );
      expect(base, isNot(const Object()));
    });
  });

  testWidgets('görsel yüklenemezse yer tutucuya düşüyor', (tester) async {
    // Test ortamındaki HTTP istemcisi 400 döndürüyor, yani bu tam olarak
    // ağın çalışmadığı hâli sınıyor.
    await tester.runAsync(() async {
      await pump(
        tester,
        const HeroCard(
          data: HeroCardData(
            imageUrl: 'https://example.com/yok.jpg',
            headline: 'Kırık görsel',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
}
