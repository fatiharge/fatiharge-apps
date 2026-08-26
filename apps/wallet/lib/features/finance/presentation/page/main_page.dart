import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/generated/locale_keys.g.dart';
import 'package:wallet/route/app_router.gr.dart';

/// The add button lives here rather than on each tab so it is reachable from
/// everywhere — recording a transaction is the app's primary action.
@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => AutoTabsScaffold(
    routes: const [DashboardRoute(), HistoryRoute(), BudgetRoute()],
    floatingActionButton: const _AddTransactionButton(),
    bottomNavigationBuilder: (context, tabsRouter) => NavigationBar(
      selectedIndex: tabsRouter.activeIndex,
      onDestinationSelected: tabsRouter.setActiveIndex,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.pie_chart_outline),
          selectedIcon: const Icon(Icons.pie_chart),
          label: context.tr(LocaleKeys.tabs_dashboard),
        ),
        NavigationDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          selectedIcon: const Icon(Icons.receipt_long),
          label: context.tr(LocaleKeys.tabs_history),
        ),
        NavigationDestination(
          icon: const Icon(Icons.savings_outlined),
          selectedIcon: const Icon(Icons.savings),
          label: context.tr(LocaleKeys.tabs_budget),
        ),
      ],
    ),
  );
}

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton();

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: () => context.router.push(TransactionEntryRoute()),
    tooltip: context.tr(LocaleKeys.entry_add_title),
    child: const Icon(Icons.add),
  );
}
