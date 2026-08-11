import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/about/domain/app_version_port.dart';
import 'package:wallet/features/about/presentation/page/about_page.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/features/settings/presentation/page/settings_page.dart';
import 'package:wallet/features/settings/presentation/views/language_section.dart';
import 'package:wallet/features/startup/presentation/splash_view.dart';
import 'package:wallet/theme/app_mark.dart';

import '../../../support/in_memory_repositories.dart';

import '../../../support/widget_harness.dart';

void main() {
  late FakeSettingsRepository settings;

  setUp(() async {
    settings = FakeSettingsRepository();
    await getIt.reset();
    getIt
      ..registerSingleton<AppVersionPort>(_StubVersion())
      ..registerSingleton<SettingsRepository>(settings)
      ..registerSingleton<SummaryReminderController>(
        SummaryReminderController(settings, FakeSummaryNotifier()),
      );
  });

  tearDown(getIt.reset);

  Future<void> pumpSettings(WidgetTester tester) {
    useTallSurface(tester);
    return pumpLocalized(
      tester,
      BlocProvider(
        create: (_) => SettingsCubit(settings),
        child: const SettingsPage(),
      ),
    );
  }

  group('SettingsPage', () {
    testWidgets('offers every theme, with the stored one checked', (
      tester,
    ) async {
      settings.theme = ThemePreference.dark;
      await pumpSettings(tester);

      expect(find.text('Sistem'), findsOneWidget);
      expect(find.text('Açık'), findsOneWidget);
      expect(find.text('Koyu'), findsOneWidget);
      // theme + language + currency
      expect(find.byIcon(Icons.check), findsNWidgets(3));
    });

    testWidgets('choosing a theme writes it through', (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Koyu'));
      await tester.pumpAndSettle();

      expect(settings.theme, ThemePreference.dark);
    });

    testWidgets('lists each language in its own language', (tester) async {
      await pumpSettings(tester);

      expect(find.byType(LanguageSection), findsOneWidget);
      expect(find.text('Türkçe'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Cihaz dili'), findsOneWidget);
    });

    testWidgets('moves the check mark onto the language just picked', (
      tester,
    ) async {
      await pumpSettings(tester);

      ListTile tileFor(String label) => tester.widget<ListTile>(
        find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
      );

      expect(tileFor('Cihaz dili').selected, isTrue);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(tileFor('English').selected, isTrue);
      expect(tileFor('Device language').selected, isFalse);
    });

    testWidgets('leads to the about page', (tester) async {
      await pumpSettings(tester);

      expect(find.text('Hakkında'), findsOneWidget);
    });

    testWidgets('leads to the category screen', (tester) async {
      await pumpSettings(tester);

      expect(find.text('Kategoriler'), findsOneWidget);
    });

    testWidgets('offers a default currency, with the stored one checked', (
      tester,
    ) async {
      settings.currency = Currency.euro;
      await pumpSettings(tester);

      ListTile tileFor(String label) => tester.widget<ListTile>(
        find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
      );

      expect(tileFor('€  EUR').selected, isTrue);
      expect(tileFor('₺  TRY').selected, isFalse);
    });

    testWidgets('picking a currency writes it through', (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text(r'$  USD'));
      await tester.pumpAndSettle();

      expect(settings.currency, Currency.usDollar);
    });

    testWidgets('says that existing records are not touched', (tester) async {
      await pumpSettings(tester);

      expect(
        find.textContaining('kaydedildikleri para biriminde kalır'),
        findsOneWidget,
      );
    });
  });

  group('AboutPage', () {
    testWidgets('credits both maintainers with their handles', (tester) async {
      await pumpLocalized(tester, const AboutPage());

      expect(find.text('Fatih Çetin'), findsOneWidget);
      expect(find.text('@github/fatiharge'), findsOneWidget);
      expect(find.text('Damla Saymaz'), findsOneWidget);
      expect(find.text('@github/damlasaymaz'), findsOneWidget);
    });

    testWidgets('shows the installed version, not the pubspec one', (
      tester,
    ) async {
      await pumpLocalized(tester, const AboutPage());
      await tester.pumpAndSettle();

      expect(find.text('0.3.1 (7)'), findsOneWidget);
    });

    testWidgets('offers no email — GitHub issues are the only channel', (
      tester,
    ) async {
      await pumpLocalized(tester, const AboutPage());

      expect(find.textContaining('@fatiharge.com'), findsNothing);
      expect(find.text('Hata bildir'), findsOneWidget);
      expect(find.text('Özellik iste'), findsOneWidget);
    });

    testWidgets('a row copies its link and says so', (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );

      await pumpLocalized(tester, const AboutPage());
      await tester.scrollUntilVisible(find.text('Kaynak kod'), 200);
      await tester.tap(find.text('Kaynak kod'));
      await tester.pumpAndSettle();

      expect(copied.single, contains('github.com/fatiharge/fatiharge-apps'));
      expect(find.text('Panoya kopyalandı'), findsOneWidget);
    });
  });

  group('SplashView', () {
    testWidgets('shows the mark and a progress bar', (tester) async {
      await pumpLocalized(tester, const SplashView(), settle: false);

      expect(find.byType(AppMark), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}

class _StubVersion implements AppVersionPort {
  @override
  Future<AppVersion> read() async =>
      const AppVersion(name: '0.3.1', build: '7');
}
