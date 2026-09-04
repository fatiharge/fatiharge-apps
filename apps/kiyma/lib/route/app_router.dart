import 'package:auto_route/auto_route.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// The shop is a route rather than a card over the counter because the menu
/// and the day card both reach it.
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
