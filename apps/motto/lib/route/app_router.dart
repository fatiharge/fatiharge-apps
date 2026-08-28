import 'package:auto_route/auto_route.dart';
import 'package:motto/route/app_router.gr.dart';

/// The test flow has no navigation bar: completion is everything there, and
/// every tab in a bar is a way out of the funnel. The bar is the shell, and
/// the shell is where someone lands once they have a result.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartupRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: WelcomeRoute.page),
    AutoRoute(page: QuestionRoute.page),
    AutoRoute(page: CalculatingRoute.page),
    AutoRoute(page: ResultRoute.page),
    AutoRoute(page: ShareCardRoute.page),
    AutoRoute(
      page: ShellRoute.page,
      children: [
        AutoRoute(page: TodayRoute.page, initial: true),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: PrivacyRoute.page),
    AutoRoute(page: DataDeletionRoute.page),
    AutoRoute(page: FaqRoute.page),
    AutoRoute(page: MethodRoute.page),
    AutoRoute(page: FeedbackRoute.page),
    AutoRoute(page: DailyTasksRoute.page),
    AutoRoute(page: TaskDetailRoute.page),
    AutoRoute(page: MottoDetailRoute.page),
    AutoRoute(page: PeriodReportRoute.page),
    AutoRoute(page: ArchiveRoute.page),
    AutoRoute(page: DeepReportRoute.page),
    AutoRoute(page: GalleryRoute.page),
    AutoRoute(page: GameRulesRoute.page),
    AutoRoute(page: GameRoute.page),
    AutoRoute(page: GameOverRoute.page),
  ];
}
