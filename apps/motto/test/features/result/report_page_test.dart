import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/result/presentation/report_page.dart';
import 'package:motto/theme/motto_theme.dart';

class _MockReports extends Mock implements api.ReportResourceApi {}

void main() {
  late _MockReports reports;

  setUp(() {
    reports = _MockReports();
    getIt.registerSingleton<api.ReportResourceApi>(reports);
  });

  tearDown(getIt.reset);

  final report = api.ResultReport(
    resultId: 1,
    archetypeId: 'quiet_builder',
    overview: 'Gürültü çıkarmadan biriktiren birisin.',
    readings: [
      api.DimensionReading(
        dimension: 'CONSCIENTIOUSNESS',
        band: 'high',
        score: 0.9,
        text: 'Başladığın işi bitiriyorsun.',
      ),
      api.DimensionReading(
        dimension: 'EXTRAVERSION',
        band: 'low',
        score: 0.2,
        text: 'Kalabalık seni yormaya yakın.',
      ),
    ],
    strength: 'Kimse bakmazken de aynı hızda gidiyorsun.',
    cost: 'Yardım istemeyi geciktiriyorsun.',
  );

  Widget page() =>
      MaterialApp(theme: MottoTheme.dark, home: const ReportPage(resultId: 1));

  testWidgets('reads every dimension it is given', (tester) async {
    when(() => reports.resultReport(1)).thenAnswer((_) async => report);

    await tester.pumpWidget(page());
    await tester.pumpAndSettle();

    expect(find.text('Gürültü çıkarmadan biriktiren birisin.'), findsOneWidget);
    expect(find.text('Düzen ve süreklilik'), findsOneWidget);
    expect(find.text('Dışa dönüklük'), findsOneWidget);
    expect(find.text('yüksek'), findsOneWidget);
    expect(find.text('Başladığın işi bitiriyorsun.'), findsOneWidget);
  });

  // The cost is the half that makes the free report worth reading twice.
  testWidgets('says what the archetype costs, not only what it gives', (
    tester,
  ) async {
    when(() => reports.resultReport(1)).thenAnswer((_) async => report);

    await tester.pumpWidget(page());
    await tester.pumpAndSettle();

    expect(find.text('Neye mal oluyor'), findsOneWidget);
    expect(find.text('Yardım istemeyi geciktiriyorsun.'), findsOneWidget);
  });

  testWidgets('says so when it cannot be fetched', (tester) async {
    when(() => reports.resultReport(1)).thenThrow(Exception('offline'));

    await tester.pumpWidget(page());
    await tester.pumpAndSettle();

    expect(find.text('Rapor alınamadı.'), findsOneWidget);
  });
}
