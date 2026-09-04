import 'package:auto_route/auto_route.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// The screens outside the counter.
///
/// The between-runs cards are routes rather than overlays now: the shop is
/// reached both from the menu and from the day card, and one screen with two
/// doors is cheaper than two copies of it.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartupRoute.page, initial: true),
    AutoRoute(page: LanguageRoute.page),
    AutoRoute(page: MenuRoute.page),
    AutoRoute(page: DayRoute.page),
    AutoRoute(page: GameRoute.page),
    AutoRoute(page: ShopRoute.page),
  ];
}
