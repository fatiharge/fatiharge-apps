import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/config/reported.dart';
import 'package:motto/features/chain/application/chain_cubit.dart';
import 'package:motto/features/daily/application/daily_cubit.dart';
import 'package:motto/features/days/application/days_cubit.dart';
import 'package:motto/features/game/application/turns_cubit.dart';
import 'package:motto/features/profile/application/profile_cubit.dart';
import 'package:motto/features/shell/presentation/widgets/floating_nav_bar.dart';
import 'package:motto/features/support/presentation/widgets/trouble_sheet.dart';
import 'package:motto/features/tasks/application/task_cubit.dart';
import 'package:motto/infrastructure/api/outcome.dart';
import 'package:motto/infrastructure/api/trouble_bus.dart';
import 'package:motto/infrastructure/session/device_session.dart';
import 'package:motto/route/app_router.gr.dart';
import 'package:motto/route/reloads_on_return.dart';

/// The three places there are.
///
/// A bar, and only after the inventory: during the questions completion is the
/// only thing that matters and every tab is a way out of it.
///
/// The day's tasks are a tab rather than a screen pushed from Bugün. They are
/// what somebody opens the app to do — a thing reached by tapping a summary
/// card is a thing most people never reach twice.
///
/// The four cubits are provided here rather than in each tab. Two tabs used to
/// build their own [ChainCubit], which is two readings of one chain that can
/// disagree; and a cubit built inside a tab is one nothing can reach when the
/// inventory is filled in on a screen pushed over the whole shell.
@RoutePage()
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => getIt<DailyCubit>()..unawaitedLoad()),
      BlocProvider(create: (_) => getIt<ProfileCubit>()..unawaitedLoad()),
      BlocProvider(create: (_) => getIt<ChainCubit>()..unawaitedLoad()),
      BlocProvider(create: (_) => getIt<TaskCubit>()..unawaitedLoad()),
      BlocProvider(create: (_) => getIt<TurnsCubit>()..unawaitedLoad()),
      BlocProvider(create: (_) => getIt<DaysCubit>()..unawaitedLoad()),
    ],
    child: const _ShellView(),
  );
}

class _ShellView extends StatefulWidget {
  const _ShellView();

  @override
  State<_ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<_ShellView> with ReloadsOnReturn {
  /// The token lasts an hour and nothing checked it on the way back in. A
  /// phone picked up after lunch asked with a dead token, and the two tabs
  /// that need the server came back empty — the chain, the three things and
  /// the profile all at once, which reads as the app being broken.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => unawaited(_cameBack()),
  );

  Future<void> _cameBack() async {
    // Renewed before anything is asked rather than after a 401: the recovery
    // works, but three tabs failing and silently retrying is a second of
    // empty screens nobody should have to see.
    //
    // Best effort, and the reload happens either way. A phone that came back
    // with no signal cannot renew anything, and swallowing the reload would
    // leave the screens on yesterday with no way to ask again — each of them
    // has its own retry and its own sentence for this.
    try {
      await getIt<DeviceSession>().ensure();
    } on Object catch (failure, trace) {
      reported('session', failure, trace);
    }
    if (mounted) reload();
  }

  StreamSubscription<Trouble>? _troubles;

  @override
  void initState() {
    super.initState();
    _lifecycle.hashCode;
    // Said once, above the tabs. A dead session and a door we should not have
    // offered do not become different problems because a different screen was
    // asking, and answering them in every cubit is how one meaning turns into
    // six sentences.
    _troubles = getIt<TroubleBus>().stream.listen(_answer);
  }

  @override
  void dispose() {
    unawaited(_troubles?.cancel());
    _lifecycle.dispose();
    super.dispose();
  }

  void _answer(Trouble trouble) {
    if (!mounted) return;
    unawaited(
      showTroubleSheet(
        context,
        // Nothing to retry: the client already renewed and retried before a
        // session ever came through here, and a door that is closed stays
        // closed however many times it is pushed.
        failure: trouble,
      ),
    );
  }

  static const _items = [
    NavItem(icon: Icons.today_outlined, filled: Icons.today, label: 'Bugün'),
    NavItem(
      icon: Icons.check_circle_outline,
      filled: Icons.check_circle,
      label: 'Görevler',
    ),
    NavItem(
      icon: Icons.calendar_month_outlined,
      filled: Icons.calendar_month,
      label: 'Günler',
    ),
    NavItem(icon: Icons.person_outline, filled: Icons.person, label: 'Profil'),
  ];

  /// What one tab changes for another.
  ///
  /// A tab is built once and kept alive, so marking the day on Görevler left
  /// Günler still showing no days at all — the screen whose whole job is to
  /// show marked days did not notice one being marked. The turns behave the
  /// same way: marking the day earns one, and the row that spends it lived on
  /// another tab.
  ///
  /// Only these two: the rest read cubits that the act itself updates.
  void _crossTabs() {
    context.read<DaysCubit>().unawaitedLoad();
    context.read<TurnsCubit>().unawaitedLoad();
  }

  /// Everything the three tabs read. The inventory, the report and a marked
  /// day all happen on screens pushed over this one, and every one of them
  /// changes what at least two tabs should say.
  @override
  void reload() {
    context.read<DailyCubit>().unawaitedLoad();
    context.read<ProfileCubit>().unawaitedLoad();
    context.read<ChainCubit>().unawaitedLoad();
    context.read<TaskCubit>().unawaitedLoad();
    context.read<TurnsCubit>().unawaitedLoad();
    context.read<DaysCubit>().unawaitedLoad();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        TodayRoute(),
        DailyTasksRoute(),
        DaysRoute(),
        ProfileRoute(),
      ],
      // Floating over the content rather than sitting under it, so the bar
      // reads as something on top of the page instead of a wall at the bottom.
      extendBody: true,
      bottomNavigationBuilder: (context, tabsRouter) => FloatingNavBar(
        items: _items,
        index: tabsRouter.activeIndex,
        onSelected: (index) {
          tabsRouter.setActiveIndex(index);
          _crossTabs();
        },
      ),
    );
  }
}
