import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/support/application/support_copy_cubit.dart';
import 'package:motto/features/support/presentation/faq_page.dart';

class _MockSupport extends Mock implements api.SupportResourceApi {}

api.SupportCopy copy() => api.SupportCopy(
  version: 'abc123',
  privacy: ['Hesap yok.'],
  deletion: api.DeletionCopy(
    goes: ['Arketibin'],
    stays: ['Cihaz kimliğin'],
    counterReason: 'Sayaç kalır.',
    answersNote: 'Cevaplar saklanmıyor.',
  ),
  faq: [
    api.FaqEntry(
      id: 'lost_data',
      question: 'Telefonumu değiştirirsem?',
      answer: 'Zincirin gider.',
    ),
    api.FaqEntry(
      id: 'chain_broken',
      question: 'Zincirim kırıldı?',
      answer: 'Telafi hakkın var.',
    ),
  ],
  privacyPolicyUrl: 'https://dafalabs.com/motto/privacy',
);

void main() {
  late _MockSupport support;

  setUp(() {
    support = _MockSupport();
    when(support.supportCopy).thenAnswer((_) async => copy());
    getIt.registerFactory<SupportCopyCubit>(() => SupportCopyCubit(support));
  });

  tearDown(getIt.reset);

  testWidgets('the questions come from the server', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FaqPage()));
    await tester.pumpAndSettle();

    // Served rather than shipped, so a wrong answer is fixed in one deploy.
    expect(find.text('Telefonumu değiştirirsem?'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNWidgets(2));
  });

  testWidgets('a linked entry is already open', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FaqPage(openItem: 'chain_broken')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Telafi hakkın var.'), findsOneWidget);
  });

  testWidgets('copy that cannot be fetched says so', (tester) async {
    when(support.supportCopy).thenThrow(Exception('offline'));

    await tester.pumpWidget(const MaterialApp(home: FaqPage()));
    await tester.pumpAndSettle();

    // No cache, by decision: a wrong answer about where somebody's data is
    // has to be fixable in one deploy.
    expect(find.textContaining('yüklenemedi'), findsOneWidget);
  });
}
