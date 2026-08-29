import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

/// Reloads a tab when the screen that was covering it goes away.
///
/// A tab page is built once and kept alive, so a cubit that loaded in its
/// constructor keeps answering with what was true then. Fill in the inventory
/// and come back, and Bugün still says to fill in the inventory — until the
/// app is restarted, which is the one thing a person will not think to do.
///
/// `didPopNext` is the moment that staleness starts, and the only one: a tab
/// switch does not change what these cubits read, and the app coming back from
/// the background is somebody else's problem.
mixin ReloadsOnReturn<T extends StatefulWidget> on State<T>
    implements AutoRouteAware {
  /// What to read again. Called after the covering screen pops.
  void reload();

  AutoRouteObserver? _observer;

  /// Looked up rather than required: a widget test pumps these views on their
  /// own, and a page that only reloads inside the app is still a page worth
  /// testing.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = context.getInheritedWidgetOfExactType<RouterScope>();
    if (scope == null) return;

    _observer = scope.firstObserverOfType<AutoRouteObserver>();
    _observer?.subscribe(this, context.routeData);
  }

  @override
  void dispose() {
    _observer?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => reload();

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {}

  @override
  void didInitTabRoute(TabPageRoute? previousRoute) {}

  @override
  void didPop() {}

  @override
  void didPush() {}

  @override
  void didPushNext() {}
}
