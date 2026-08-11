import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/app.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/route/app_router.dart';
import 'package:wallet/route/app_router.gr.dart';
import 'package:wallet/theme/app_mark.dart';

import 'support/app_harness.dart';
import 'support/finance_fixtures.dart';
import 'support/widget_harness.dart';

/// Proves the app boots: DI, router, theme and the first screen, wired
/// together. Everything below `App` was covered in isolation and nothing
/// checked that the pieces fit.
void main() {
  late AppHarness harness;

  setUp(() async {
    harness = await registerAppDependencies();
    harness.categories.seed([categoryOf('misc', name: 'Diğer')]);
  });

  tearDown(() => harness.dispose());

  testWidgets('boots to the dashboard without throwing', (tester) async {
    await pumpApp(tester, const App());
    await tester.pump(const Duration(seconds: 3));

    // The router starts on StartupPage; this navigates the way
    // BootstrapAdapter does once its jobs finish.
    await getIt<RouteManager>().replaceAll([const MainRoute()]);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Geçmiş'), findsOneWidget);
    expect(find.text('Bütçe'), findsOneWidget);
  });

  testWidgets('every tab opens, and so does the entry sheet', (tester) async {
    await pumpApp(tester, const App());
    await tester.pump(const Duration(seconds: 3));
    await getIt<RouteManager>().replaceAll([const MainRoute()]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Geçmiş'));
    await tester.pumpAndSettle();
    expect(find.text('Geçmiş boş'), findsOneWidget);

    await tester.tap(find.text('Bütçe'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz bütçe yok'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('applies the stored theme rather than the system one', (
    tester,
  ) async {
    await pumpApp(tester, const App());
    // bootstrap_kit pads the splash to a minimum duration; let that timer run.
    await tester.pump(const Duration(seconds: 3));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('the splash shows the app mark while startup runs', (
    tester,
  ) async {
    await pumpApp(tester, const App());
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(AppMark), findsOneWidget);
  });
}
