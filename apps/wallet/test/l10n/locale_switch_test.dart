import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/route/app_router.dart';
import 'package:wallet/route/app_router.gr.dart';

import '../support/app_harness.dart';
import '../support/finance_fixtures.dart';
import '../support/widget_harness.dart';

/// Every other widget test renders under one fixed locale, so none of them
/// catches text that renders correctly but never *changes*.
void main() {
  late AppHarness harness;

  setUp(() async {
    harness = await registerAppDependencies();
  });

  tearDown(() => harness.dispose());

  List<String> visibleText() => find
      .byType(Text)
      .evaluate()
      .map((element) => (element.widget as Text).data)
      .whereType<String>()
      .toList();

  Future<void> bootToDashboard(WidgetTester tester) async {
    await pumpApp(tester, const App());
    // bootstrap_kit pads the splash to a minimum duration; let that timer run.
    await tester.pump(const Duration(seconds: 3));
    await getIt<RouteManager>().replaceAll([const MainRoute()]);
    await tester.pumpAndSettle();
  }

  testWidgets('the settings page redraws itself in the language just picked', (
    tester,
  ) async {
    await bootToDashboard(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(visibleText(), contains('Ayarlar'));

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Türkçe stays — the language names are written in themselves.
    expect(
      visibleText(),
      containsAll(<String>['Settings', 'Appearance', 'Language', 'About']),
    );
    expect(
      visibleText(),
      isNot(
        anyElement(isIn(<String>['Ayarlar', 'Görünüm', 'Dil', 'Hakkında'])),
      ),
    );
  });

  testWidgets('the theme options redraw too, though nothing rebuilds them', (
    tester,
  ) async {
    await bootToDashboard(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(visibleText(), containsAll(<String>['System', 'Light', 'Dark']));
    expect(visibleText(), isNot(contains('Sistem')));
  });

  testWidgets('a tab page kept alive behind the switch redraws as well', (
    tester,
  ) async {
    harness.categories.seed([categoryOf('food', nameKey: 'category.food')]);
    await harness.transactions.save(expenseOf(2500, category: 'food'));
    await bootToDashboard(tester);

    expect(
      visibleText(),
      containsAll(<String>['Özet', 'Bu ayki bakiye', 'Yemek']),
    );

    await tester
        .element(find.byType(NavigationBar))
        .setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // The app bar title is the one that used to go stale.
    expect(
      visibleText(),
      containsAll(<String>['Overview', 'Balance this month', 'Food']),
    );
    expect(
      visibleText(),
      isNot(
        anyElement(isIn(<String>['Özet', 'Bu ayki bakiye', 'Yemek', 'Geçmiş'])),
      ),
    );
  });
}
