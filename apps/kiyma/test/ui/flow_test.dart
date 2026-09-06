import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/ogretmen.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/infrastructure/bootstrap/bootstrap_adapter.dart';
import 'package:kiyma/infrastructure/world.dart';
import 'package:kiyma/presentation/day_page.dart';
import 'package:kiyma/presentation/kiyma_game.dart';
import 'package:kiyma/presentation/language_page.dart';
import 'package:kiyma/presentation/level_bar.dart';
import 'package:kiyma/presentation/menu_page.dart';
import 'package:kiyma/presentation/shop_page.dart';
import 'package:kiyma/presentation/summary_page.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';
import '../support/app_harness.dart';

/// The screens as they are actually reached: through the router, off the same
/// container bootstrap fills. A page tested on its own would not catch a
/// route wired to the wrong screen, and that is the part that is new.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppRouter router;

  setUpAll(() async => EasyLocalization.ensureInitialized());

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
    await getIt<GameWorld>().loadScene();
    await getIt<GameWorld>().loadArt();
    // A returning player, so the day card is the day card. The usta's first
    // visit has a test of its own.
    getIt<Progress>().gordum(Ders.katalog.map((ders) => ders.id));
    router = AppRouter();
  });

  tearDownAll(() async => getIt.reset());

  Future<void> open(WidgetTester tester, PageRouteInfo<dynamic> route) async {
    await router.replaceAll([route]);
    await pumpApp(tester, router: router);
    await tester.pumpAndSettle();
  }

  /// Progress is the singleton; every screen builds its own cubit over it.
  void earn(int amount) => getIt<Progress>().kazan(amount);

  /// The cubit the page under test built, not a fresh one out of get_it.
  KiymaCubit shownCubit(WidgetTester tester) => BlocProvider.of<KiymaCubit>(
    tester.element(find.byType(GameWidget<KiymaGame>)),
  );

  group('the first run', () {
    test('opens the language question, and only once', () {
      expect(
        BootstrapAdapter.firstRoute(chosen: false).routeName,
        'LanguageRoute',
      );
      expect(BootstrapAdapter.firstRoute(chosen: true).routeName, 'MenuRoute');
    });

    testWidgets('picking a language leaves the menu behind it', (
      tester,
    ) async {
      await open(tester, LanguageRoute());
      expect(find.byType(LanguagePage), findsOneWidget);
      expect(find.text('Türkçe'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();

      expect(find.byType(MenuPage), findsOneWidget);
      // Replaced, not pushed: there is nothing to go back to.
      expect(router.stack, hasLength(1));
      // And the choice reached the words. Without the real app's delegates
      // this passed while every screen stayed Turkish.
      expect(find.text('Play'), findsOneWidget);
    });
  });

  group('the menu', () {
    testWidgets('leads to the day card and to the shop', (tester) async {
      await open(tester, const MenuRoute());

      await tester.tap(find.text('Oyna'));
      await tester.pumpAndSettle();
      expect(find.byType(DayPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);

      await tester.tap(find.text('Yükselt'));
      await tester.pumpAndSettle();
      expect(find.byType(ShopPage), findsOneWidget);
    });
  });

  group('the day card', () {
    testWidgets('shows the level and reaches the shop', (tester) async {
      await open(tester, const DayRoute());
      expect(find.text('Gün 1'), findsOneWidget);
      expect(find.byType(LevelBar), findsOneWidget);
      // The day is never advanced by hand any more.
      expect(find.text('Günü ilerlet'), findsNothing);

      await tester.tap(find.text('Yükselt'));
      await tester.pumpAndSettle();
      expect(find.byType(ShopPage), findsOneWidget);
    });

    testWidgets('opening the counter starts a run', (
      tester,
    ) async {
      await open(tester, const DayRoute());

      await tester.tap(find.text('Tezgahı aç'));
      // Not `pumpAndSettle`: the game loop never stops scheduling frames, so
      // settling plays the whole day out and lands back on this card.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GameWidget<KiymaGame>), findsOneWidget);
      expect(shownCubit(tester).run, isNotNull);
    });

    testWidgets('a finished clock hands over to the summary', (tester) async {
      await open(tester, const DayRoute());
      await tester.tap(find.text('Tezgahı aç'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      shownCubit(tester).run!.tick(
        Balance.runLength(1).inSeconds.toDouble() + 1,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SummaryPage), findsOneWidget);
    });
  });

  group('the shop', () {
    testWidgets('sells what there is money for and nothing else', (
      tester,
    ) async {
      earn(65);
      await open(tester, const ShopRoute());

      expect(find.text('65 altın'), findsOneWidget);

      // The shop is a ladder per group now, so the ingredients are below the
      // fold on a phone.
      await tester.scrollUntilVisible(find.text('Biber'), 140);
      expect(find.text('Biber'), findsOneWidget);
      await tester.ensureVisible(find.text('60'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('60'));
      await tester.pumpAndSettle();

      expect(getIt<Progress>().unlocks.has('malzeme_biber'), isTrue);
      expect(find.text('5 altın'), findsOneWidget);
      // Pickles cost 150; the button is there but dead.
      final pickles = tester.widget<InkWell>(
        find.ancestor(of: find.text('150'), matching: find.byType(InkWell)),
      );
      expect(pickles.onTap, isNull);
    });

    testWidgets('a purchase reaches the menu underneath it', (tester) async {
      // The shop is pushed, so the menu stays mounted behind it with its own
      // cubit. Progress is what both read, so Progress is what has to say it
      // moved — otherwise the hub's money chip shows the old balance for the
      // rest of the session.
      earn(65);
      await open(tester, const MenuRoute());
      expect(find.text('65 altın'), findsOneWidget);

      await tester.tap(find.text('Yükselt'));
      await tester.pumpAndSettle();
      // The ingredients ladder is below the fold on a phone.
      await tester.scrollUntilVisible(find.text('60'), 140);
      await tester.ensureVisible(find.text('60'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('60'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.text('5 altın'), findsOneWidget);
    });
  });
}
