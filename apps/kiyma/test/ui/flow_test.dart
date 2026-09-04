import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/kiyma_cubit.dart';
import 'package:kiyma/game/kiyma_game.dart';
import 'package:kiyma/game/world.dart';
import 'package:kiyma/infrastructure/bootstrap/bootstrap_adapter.dart';
import 'package:kiyma/route/app_router.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:kiyma/ui/day_page.dart';
import 'package:kiyma/ui/hud.dart';
import 'package:kiyma/ui/language_page.dart';
import 'package:kiyma/ui/menu_page.dart';
import 'package:kiyma/ui/shop_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The screens as they are actually reached: through the router, off the same
/// container bootstrap fills. A page tested on its own would not catch a
/// route wired to the wrong screen, and that is the part that is new.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppRouter router;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
    await getIt<GameWorld>().loadScene();
    await getIt<GameWorld>().loadArt();
    router = AppRouter();
  });

  tearDownAll(() async => getIt.reset());

  Future<void> open(WidgetTester tester, PageRouteInfo<dynamic> route) async {
    await router.replaceAll([route]);
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('tr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr'),
        useOnlyLangCode: true,
        child: MaterialApp.router(routerConfig: router.config()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Money only ever arrives through a run, so the cubit is the one that
  /// announces it. Reaching into `progress` alone leaves the screens stale.
  void earn(int amount) {
    getIt<KiymaCubit>()
      ..progress.kazan(amount)
      ..startDay();
  }

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
    testWidgets('will not move on until the target is met', (tester) async {
      await open(tester, const DayRoute());
      expect(find.text('Gün 1'), findsOneWidget);

      final locked = tester.widget<InkWell>(
        find.ancestor(
          of: find.text('Günü ilerlet'),
          matching: find.byType(InkWell),
        ),
      );
      expect(locked.onTap, isNull);
      expect(find.textContaining('Hedefi tutturunca'), findsOneWidget);

      earn(Balance.target(1));
      await open(tester, const DayRoute());

      final open_ = tester.widget<InkWell>(
        find.ancestor(
          of: find.text('Günü ilerlet'),
          matching: find.byType(InkWell),
        ),
      );
      expect(open_.onTap, isNotNull);

      await tester.tap(find.text('Günü ilerlet'));
      await tester.pumpAndSettle();
      expect(find.text('Gün 2'), findsOneWidget);
    });

    testWidgets('opening the counter starts a run and shows the HUD', (
      tester,
    ) async {
      await open(tester, const DayRoute());

      await tester.tap(find.text('Tezgahı aç'));
      // Not `pumpAndSettle`: the game loop never stops scheduling frames, so
      // settling plays the whole day out and lands back on this card.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GameWidget<KiymaGame>), findsOneWidget);
      expect(find.byType(Hud), findsOneWidget);
      expect(getIt<KiymaCubit>().run, isNotNull);
    });

    testWidgets('an emptied queue hands the day card back', (tester) async {
      await open(tester, const DayRoute());
      await tester.tap(find.text('Tezgahı aç'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final run = getIt<KiymaCubit>().run!
        ..kuyruk = 0
        ..musteriler.fillRange(0, 4, null)
        ..tick(0.1);
      expect(run.bitti, isTrue);

      await tester.pumpAndSettle();
      expect(find.byType(DayPage), findsOneWidget);
    });
  });

  group('the shop', () {
    testWidgets('sells what there is money for and nothing else', (
      tester,
    ) async {
      earn(200);
      await open(tester, const ShopRoute());

      expect(find.text('Biber'), findsOneWidget);
      expect(find.text('₺200'), findsOneWidget);

      await tester.tap(find.text('₺150'));
      await tester.pumpAndSettle();

      expect(getIt<KiymaCubit>().progress.unlocks.has('malzeme_biber'), isTrue);
      expect(find.text('₺50'), findsOneWidget);
      // Pickles cost 250; the button is there but dead.
      final pickles = tester.widget<InkWell>(
        find.ancestor(of: find.text('₺250'), matching: find.byType(InkWell)),
      );
      expect(pickles.onTap, isNull);
    });
  });
}
