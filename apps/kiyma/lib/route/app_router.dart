import 'package:auto_route/auto_route.dart';
import 'package:kiyma/route/app_router.gr.dart';

/// Two routes today, and the counter is not one of the screens between days.
///
/// The day-start, day-end and shop cards are drawn over the live canvas
/// rather than pushed, because the counter has to stay visible behind them.
/// The shell screens of stage 7 — menu, settings, language, IAP — are what
/// this list grows for.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartupRoute.page, initial: true),
    AutoRoute(page: GameRoute.page),
  ];
}
