import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
import 'package:motto/features/profile/presentation/deep_report_page.dart';

class _MockResults extends Mock implements api.ResultResourceApi {}

class _MockEntitlements extends Mock implements api.EntitlementResourceApi {}

class _MockReports extends Mock implements api.ReportResourceApi {}

api.ResultSummary summary(int id, String name) => api.ResultSummary(
  id: id,
  archetype: api.ArchetypeResponse(
    id: 'quiet_builder',
    name: name,
    summary: 'Gürültü çıkarmadan biriktirirsin.',
    motto: 'Acele etmeyen ama durmayan.',
    confident: true,
  ),
  profile: api.ProfileScores(
    openness: 0.5,
    conscientiousness: 0.8,
    extraversion: 0.3,
    agreeableness: 0.5,
    neuroticism: 0.4,
  ),
  claimedAt: DateTime(2026, 3, id),
);

api.EntitlementResponse entitlement({bool premium = false}) =>
    api.EntitlementResponse(
      remainingUses: 1,
      skipsLeft: 1,
      premium: premium,
    );

void main() {
  late _MockResults results;
  late _MockEntitlements entitlements;

  setUp(() {
    results = _MockResults();
    entitlements = _MockEntitlements();
    when(results.resultHistory).thenAnswer(
      (_) async => api.ResultHistory(
        results: [summary(2, 'Kıvılcım'), summary(1, 'Sessiz İnşacı')],
      ),
    );
    when(entitlements.currentEntitlement)
        .thenAnswer((_) async => entitlement());
  });

  group('the profile', () {
    test('the newest result is who someone is now', () async {
      final cubit = ProfileCubit(results, entitlements);

      await cubit.load();

      expect(cubit.state.status, ProfileStatus.ready);
      expect(cubit.state.current!.archetype.name, 'Kıvılcım');
      expect(cubit.state.results, hasLength(2));
      expect(cubit.state.premium, isFalse);
    });

    test('a profile that cannot be fetched says so', () async {
      when(results.resultHistory).thenThrow(Exception('offline'));
      final cubit = ProfileCubit(results, entitlements);

      await cubit.load();

      expect(cubit.state.status, ProfileStatus.failed);
    });

    test('someone with nothing yet has no current archetype', () async {
      when(results.resultHistory)
          .thenAnswer((_) async => api.ResultHistory(results: []));
      final cubit = ProfileCubit(results, entitlements);

      await cubit.load();

      expect(cubit.state.current, isNull);
    });
  });

  group('the deep report', () {
    late _MockReports reports;

    setUp(() {
      reports = _MockReports();
      getIt.registerSingleton<api.ReportResourceApi>(reports);
    });

    tearDown(getIt.reset);

    testWidgets('locked, it shows the preview and a way to buy', (
      tester,
    ) async {
      when(() => reports.deepReport(any())).thenAnswer(
        (_) async => api.DeepReport(
          resultId: 1,
          archetypeId: 'quiet_builder',
          locked: true,
          preview: 'Bu bölüm nasıl karar verdiğinle ilgili.',
          sections: [],
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(home: DeepReportPage(resultId: 1)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Bu bölüm nasıl karar verdiğinle ilgili.'),
        findsOneWidget,
      );
      expect(find.text('Kilidi aç'), findsOneWidget);
    });

    testWidgets('open, it shows the sections', (tester) async {
      when(() => reports.deepReport(any())).thenAnswer(
        (_) async => api.DeepReport(
          resultId: 1,
          archetypeId: 'quiet_builder',
          locked: false,
          preview: 'önizleme',
          sections: [
            api.ReportSection(
              section: 1,
              opening: 'Karar verme bölümü',
              reading: 'Yüksek düzenlilik',
              fragment: 'Sessiz İnşacı için',
            ),
          ],
          portrait: 'Portre',
          limitation: 'Sınırlılıklar',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(home: DeepReportPage(resultId: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kilidi aç'), findsNothing);
      expect(find.text('Karar verme bölümü'), findsOneWidget);
      expect(find.text('Portre'), findsOneWidget);
      expect(find.text('Sınırlılıklar'), findsOneWidget);
    });

    testWidgets('a report that cannot be fetched says so', (tester) async {
      when(() => reports.deepReport(any())).thenThrow(Exception('offline'));

      await tester.pumpWidget(
        const MaterialApp(home: DeepReportPage(resultId: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rapor alınamadı.'), findsOneWidget);
    });
  });
}
