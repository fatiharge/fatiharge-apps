import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wallet/route/app_router.gr.dart';

/// The app's route table.
///
/// Registered in get_it before `runApp`, so non-widget code (the bootstrap
/// adapter) can navigate once startup finishes.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class RouteManager extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartupRoute.page, initial: true),
    AutoRoute(
      page: MainRoute.page,
      children: [
        AutoRoute(page: DashboardRoute.page, initial: true),
        AutoRoute(page: HistoryRoute.page),
        AutoRoute(page: BudgetRoute.page),
      ],
    ),
    CustomRoute<bool>(
      page: TransactionEntryRoute.page,
      customRouteBuilder: _modalSheetBuilder,
    ),
  ];
}

/// Presents the entry form as a sheet on top of the current page.
Route<T> _modalSheetBuilder<T>(
  BuildContext context,
  Widget child,
  AutoRoutePage<T> page,
) => ModalBottomSheetRoute<T>(
  settings: page,
  builder: (_) => child,
  isScrollControlled: true,
  useSafeArea: true,
);
