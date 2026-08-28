import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/chain/application/chain_repository.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:motto/features/support/application/data_deletion.dart';
import 'package:motto/features/support/application/feedback_cubit.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/features/support/application/support_context.dart';
import 'package:motto/features/support/application/support_copy_cubit.dart';
import 'package:motto/features/support/domain/method_text.dart';
import 'package:motto/features/support/presentation/data_deletion_page.dart';
import 'package:motto/features/support/presentation/feedback_page.dart';
import 'package:motto/features/support/presentation/method_page.dart';
import 'package:motto/features/support/presentation/privacy_page.dart';
import 'package:motto/features/support/presentation/settings_page.dart';
import 'package:motto/infrastructure/analytics/analytics.dart';
import 'package:motto/infrastructure/analytics/event_queue.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockScheduler extends Mock implements ReminderScheduler {}

class _MockChains extends Mock implements ChainRepository {}

class _MockEvents extends Mock implements api.EventResourceApi {}

class _MockFeedback extends Mock implements api.FeedbackResourceApi {}

class _MockEntitlements extends Mock implements api.EntitlementResourceApi {}

class _MockSupport extends Mock implements api.SupportResourceApi {}

api.SupportCopy supportCopy() => api.SupportCopy(
  version: 'abc123',
  privacy: ['Adın, e-postan ya da telefon numaran istenmiyor. Hesap yok.'],
  deletion: api.DeletionCopy(
    goes: ['Arketibin ve aldığın mottolar'],
    stays: ['Cihaz kimliğin', 'Kullandığın hak sayısı'],
    counterReason: 'Kullanım hakkı sayacı, suistimali önlemek için saklanır.',
    answersNote: 'Test cevapların zaten saklanmıyor.',
  ),
  faq: [],
  privacyPolicyUrl: 'https://dafalabs.com/motto/privacy',
);

class _FakeIdentity implements DeviceIdentity {
  @override
  Future<String> hash() async => 'hash';

  @override
  String get platform => 'android';
}

void main() {
  late _MockEntitlements entitlements;

  setUpAll(() {
    registerFallbackValue(api.EventBatch());
    registerFallbackValue(<Reminder>[]);
    registerFallbackValue(
      api.FeedbackRequest(kind: api.FeedbackKind.OTHER, message: 'x'),
    );
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'Motto',
      packageName: 'com.dafalabs.motto',
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final scheduler = _MockScheduler();
    when(scheduler.hasPermission).thenAnswer((_) async => true);
    when(scheduler.requestPermission).thenAnswer((_) async => true);
    when(() => scheduler.schedule(any())).thenAnswer((_) async {});
    when(scheduler.cancelAll).thenAnswer((_) async {});

    final events = _MockEvents();
    when(() => events.recordEvents(any())).thenAnswer(
      (_) async => api.EventBatchResponse(accepted: 1, duplicates: 0),
    );
    final analytics = Analytics(EventQueue(preferences), events);

    final feedback = _MockFeedback();
    when(() => feedback.submitFeedback(any())).thenAnswer((_) async => null);

    entitlements = _MockEntitlements();
    when(entitlements.deleteMyData).thenAnswer((_) async => null);

    final chains = _MockChains();
    when(() => chains.cached).thenReturn(const Chain());
    when(() => chains.load(any())).thenAnswer((_) async => const Chain());

    final support = _MockSupport();
    when(support.supportCopy).thenAnswer((_) async => supportCopy());

    getIt
      ..registerFactory<SupportCopyCubit>(() => SupportCopyCubit(support))
      ..registerFactory<ChainCubit>(
        () => ChainCubit(chains, ChainStore(preferences), scheduler, analytics),
      )
      ..registerFactory<FeedbackCubit>(
        () => FeedbackCubit(
          feedback,
          SupportContext(_FakeIdentity(), LastArchetype(preferences)),
          analytics,
        ),
      )
      ..registerSingleton<DataDeletion>(
        DataDeletion(entitlements, preferences),
      );
  });

  tearDown(getIt.reset);

  testWidgets('settings lists every way out', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    // With no account these are the only channel there is.
    expect(find.text('Gizlilik ve izinler'), findsOneWidget);
    expect(find.text('Sık sorulanlar'), findsOneWidget);
    expect(find.text('Yöntem'), findsOneWidget);
    expect(find.text('Geri bildirim'), findsOneWidget);
  });

  testWidgets('the reminder hour waits for a chain to exist', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Zincir başlayınca sorulur'), findsOneWidget);
  });

  testWidgets('privacy says what is kept and offers the way out', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPage()));
    await tester.pumpAndSettle();

    expect(find.text(supportCopy().privacy.first), findsOneWidget);
    expect(find.text('Verilerimi sil'), findsOneWidget);
  });

  testWidgets('the deletion screen says what survives before the button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DataDeletionPage()));
    await tester.pumpAndSettle();

    // Finding out afterwards that the counter stays is how this screen becomes
    // a one-star review.
    expect(find.text(supportCopy().deletion.counterReason), findsWidgets);
    for (final item in supportCopy().deletion.stays) {
      expect(find.text('• $item'), findsOneWidget);
    }
  });

  testWidgets('deleting asks the server', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DataDeletionPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Verilerimi sil'));
    await tester.pumpAndSettle();

    verify(entitlements.deleteMyData).called(1);
    expect(find.text('Silindi.'), findsOneWidget);
  });

  testWidgets('the method screen renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MethodPage()));

    expect(find.text(methodSections.first.heading), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('the method text says the archetype is a reading, not a category', () {
    final limits = methodSections.firstWhere(
      (section) => section.heading == 'Sınırlılıklar',
    );

    // The limitations section is the point of that screen, not an appendix:
    // it is what keeps the app on the right side of App Review 1.4.1.
    expect(limits.body, contains('editöryal'));
    expect(limits.body, contains('teşhis'));
  });

  testWidgets('feedback sends without an address', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FeedbackPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Bir şey oldu');
    await tester.tap(find.widgetWithText(FilledButton, 'Gönder'));
    await tester.pumpAndSettle();

    // Requiring an address collapses the submission rate.
    expect(find.text('Ulaştı. Teşekkürler.'), findsOneWidget);
  });
}
