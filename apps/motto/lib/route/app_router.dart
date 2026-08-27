import 'package:auto_route/auto_route.dart';
import 'package:motto/route/app_router.gr.dart';

/// The test flow deliberately has no navigation bar: completion is everything,
/// and every tab in a bottom bar is a way out of the funnel. The bar appears
/// once the test is done.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartupRoute.page, initial: true),
    AutoRoute(page: WelcomeRoute.page),
    AutoRoute(page: QuestionRoute.page),
    AutoRoute(page: CalculatingRoute.page),
    AutoRoute(page: ResultRoute.page),
    AutoRoute(page: ShareCardRoute.page),
    AutoRoute(page: TodayRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: PrivacyRoute.page),
    AutoRoute(page: DataDeletionRoute.page),
    AutoRoute(page: FaqRoute.page),
    AutoRoute(page: MethodRoute.page),
    AutoRoute(page: FeedbackRoute.page),
  ];
}
