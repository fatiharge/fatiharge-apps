import 'package:flutter/widgets.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';
import 'package:motto/route/app_router.dart';

/// Tells the mascot which screen it is floating over.
///
/// A navigator observer rather than a listener on the router, and rather than
/// a widget wrapped around each page. Both of those were tried: the wrapper
/// counted an `initState` that did not pair with its `dispose` the way the
/// router builds pages, and the router listener never fired on the way back,
/// so the mascot stayed hidden after the funnel instead of coming back.
/// `didPush` and `didPop` are a contract — they say *when* the stack moved.
/// What is on top comes from the router, because a pushed route's
/// `settings.name` is its path, not the name the app calls it by.
class MascotRouteObserver extends NavigatorObserver {
  MascotRouteObserver();

  /// Resolved per event, never held.
  ///
  /// The observer is built with `MaterialApp`, and that happens before
  /// bootstrap has filled the container — asking for the store in the
  /// constructor takes the app down on its first frame. Nothing is missed by
  /// waiting: the routes that come before the container exists are the splash
  /// and the onboarding, and the mascot is welcome on both.
  MascotStore? get _store =>
      getIt.isRegistered<MascotStore>() ? getIt<MascotStore>() : null;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _later();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _later();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _later();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _later();

  /// After the frame, because the observer runs while the stack is still
  /// moving and the router has not caught up yet.
  void _later() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!getIt.isRegistered<AppRouter>()) return;
      _store?.onRoute(getIt<AppRouter>().current.name);
    });
  }
}
