// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;
import 'package:kiyma/presentation/day_page.dart' as _i1;
import 'package:kiyma/presentation/game_page.dart' as _i2;
import 'package:kiyma/presentation/language_page.dart' as _i3;
import 'package:kiyma/presentation/menu_page.dart' as _i4;
import 'package:kiyma/presentation/shop_list_page.dart' as _i5;
import 'package:kiyma/presentation/shop_page.dart' as _i6;
import 'package:kiyma/presentation/startup_page.dart' as _i7;
import 'package:kiyma/presentation/summary_page.dart' as _i8;
import 'package:kiyma/presentation/wiki_page.dart' as _i9;

/// generated route for
/// [_i1.DayPage]
class DayRoute extends _i10.PageRouteInfo<void> {
  const DayRoute({List<_i10.PageRouteInfo>? children})
    : super(DayRoute.name, initialChildren: children);

  static const String name = 'DayRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i1.DayPage();
    },
  );
}

/// generated route for
/// [_i2.GamePage]
class GameRoute extends _i10.PageRouteInfo<void> {
  const GameRoute({List<_i10.PageRouteInfo>? children})
    : super(GameRoute.name, initialChildren: children);

  static const String name = 'GameRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i2.GamePage();
    },
  );
}

/// generated route for
/// [_i3.LanguagePage]
class LanguageRoute extends _i10.PageRouteInfo<LanguageRouteArgs> {
  LanguageRoute({
    bool firstRun = true,
    _i11.Key? key,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         LanguageRoute.name,
         args: LanguageRouteArgs(firstRun: firstRun, key: key),
         initialChildren: children,
       );

  static const String name = 'LanguageRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LanguageRouteArgs>(
        orElse: () => const LanguageRouteArgs(),
      );
      return _i3.LanguagePage(firstRun: args.firstRun, key: args.key);
    },
  );
}

class LanguageRouteArgs {
  const LanguageRouteArgs({this.firstRun = true, this.key});

  final bool firstRun;

  final _i11.Key? key;

  @override
  String toString() {
    return 'LanguageRouteArgs{firstRun: $firstRun, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LanguageRouteArgs) return false;
    return firstRun == other.firstRun && key == other.key;
  }

  @override
  int get hashCode => firstRun.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i4.MenuPage]
class MenuRoute extends _i10.PageRouteInfo<void> {
  const MenuRoute({List<_i10.PageRouteInfo>? children})
    : super(MenuRoute.name, initialChildren: children);

  static const String name = 'MenuRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i4.MenuPage();
    },
  );
}

/// generated route for
/// [_i5.ShopListPage]
class ShopListRoute extends _i10.PageRouteInfo<void> {
  const ShopListRoute({List<_i10.PageRouteInfo>? children})
    : super(ShopListRoute.name, initialChildren: children);

  static const String name = 'ShopListRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i5.ShopListPage();
    },
  );
}

/// generated route for
/// [_i6.ShopPage]
class ShopRoute extends _i10.PageRouteInfo<void> {
  const ShopRoute({List<_i10.PageRouteInfo>? children})
    : super(ShopRoute.name, initialChildren: children);

  static const String name = 'ShopRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i6.ShopPage();
    },
  );
}

/// generated route for
/// [_i7.StartupPage]
class StartupRoute extends _i10.PageRouteInfo<void> {
  const StartupRoute({List<_i10.PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i7.StartupPage();
    },
  );
}

/// generated route for
/// [_i8.SummaryPage]
class SummaryRoute extends _i10.PageRouteInfo<void> {
  const SummaryRoute({List<_i10.PageRouteInfo>? children})
    : super(SummaryRoute.name, initialChildren: children);

  static const String name = 'SummaryRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i8.SummaryPage();
    },
  );
}

/// generated route for
/// [_i9.WikiPage]
class WikiRoute extends _i10.PageRouteInfo<void> {
  const WikiRoute({List<_i10.PageRouteInfo>? children})
    : super(WikiRoute.name, initialChildren: children);

  static const String name = 'WikiRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i9.WikiPage();
    },
  );
}
