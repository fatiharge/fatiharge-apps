// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:kiyma/ui/game_page.dart' as _i1;
import 'package:kiyma/ui/startup_page.dart' as _i2;

/// generated route for
/// [_i1.GamePage]
class GameRoute extends _i3.PageRouteInfo<void> {
  const GameRoute({List<_i3.PageRouteInfo>? children})
    : super(GameRoute.name, initialChildren: children);

  static const String name = 'GameRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.GamePage();
    },
  );
}

/// generated route for
/// [_i2.StartupPage]
class StartupRoute extends _i3.PageRouteInfo<void> {
  const StartupRoute({List<_i3.PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.StartupPage();
    },
  );
}
