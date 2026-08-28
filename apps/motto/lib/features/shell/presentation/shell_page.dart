import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:motto/features/shell/presentation/widgets/floating_nav_bar.dart';
import 'package:motto/route/app_router.gr.dart';

/// The three places there are.
///
/// A bar, and only after the inventory: during the questions completion is the
/// only thing that matters and every tab is a way out of it.
///
/// The day's tasks are a tab rather than a screen pushed from Bugün. They are
/// what somebody opens the app to do — a thing reached by tapping a summary
/// card is a thing most people never reach twice.
@RoutePage()
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  static const _items = [
    NavItem(icon: Icons.today_outlined, filled: Icons.today, label: 'Bugün'),
    NavItem(
      icon: Icons.check_circle_outline,
      filled: Icons.check_circle,
      label: 'Görevler',
    ),
    NavItem(icon: Icons.person_outline, filled: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [TodayRoute(), DailyTasksRoute(), ProfileRoute()],
      // Floating over the content rather than sitting under it, so the bar
      // reads as something on top of the page instead of a wall at the bottom.
      extendBody: true,
      bottomNavigationBuilder: (context, tabsRouter) => FloatingNavBar(
        items: _items,
        index: tabsRouter.activeIndex,
        onSelected: tabsRouter.setActiveIndex,
      ),
    );
  }
}
