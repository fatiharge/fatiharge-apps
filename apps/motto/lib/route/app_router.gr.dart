// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i10;

import 'package:api_client_motto/api.dart' as _i9;
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i11;
import 'package:motto/features/chain/presentation/chain_page.dart' as _i2;
import 'package:motto/features/result/presentation/result_page.dart' as _i4;
import 'package:motto/features/result/presentation/share_card_page.dart' as _i5;
import 'package:motto/features/startup/presentation/startup_page.dart' as _i6;
import 'package:motto/features/test/presentation/calculating_page.dart' as _i1;
import 'package:motto/features/test/presentation/question_page.dart' as _i3;
import 'package:motto/features/welcome/presentation/welcome_page.dart' as _i7;

/// generated route for
/// [_i1.CalculatingPage]
class CalculatingRoute extends _i8.PageRouteInfo<void> {
  const CalculatingRoute({List<_i8.PageRouteInfo>? children})
    : super(CalculatingRoute.name, initialChildren: children);

  static const String name = 'CalculatingRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return _i8.WrappedRoute(child: const _i1.CalculatingPage());
    },
  );
}

/// generated route for
/// [_i2.ChainPage]
class ChainRoute extends _i8.PageRouteInfo<void> {
  const ChainRoute({List<_i8.PageRouteInfo>? children})
    : super(ChainRoute.name, initialChildren: children);

  static const String name = 'ChainRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i2.ChainPage();
    },
  );
}

/// generated route for
/// [_i3.QuestionPage]
class QuestionRoute extends _i8.PageRouteInfo<void> {
  const QuestionRoute({List<_i8.PageRouteInfo>? children})
    : super(QuestionRoute.name, initialChildren: children);

  static const String name = 'QuestionRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return _i8.WrappedRoute(child: const _i3.QuestionPage());
    },
  );
}

/// generated route for
/// [_i4.ResultPage]
class ResultRoute extends _i8.PageRouteInfo<ResultRouteArgs> {
  ResultRoute({
    required _i9.ResultResponse result,
    _i10.Future<void> Function(_i11.BuildContext, _i9.ArchetypeResponse)?
    offerCard,
    _i11.Key? key,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         ResultRoute.name,
         args: ResultRouteArgs(result: result, offerCard: offerCard, key: key),
         initialChildren: children,
       );

  static const String name = 'ResultRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultRouteArgs>();
      return _i4.ResultPage(
        result: args.result,
        offerCard: args.offerCard,
        key: args.key,
      );
    },
  );
}

class ResultRouteArgs {
  const ResultRouteArgs({required this.result, this.offerCard, this.key});

  final _i9.ResultResponse result;

  final _i10.Future<void> Function(_i11.BuildContext, _i9.ArchetypeResponse)?
  offerCard;

  final _i11.Key? key;

  @override
  String toString() {
    return 'ResultRouteArgs{result: $result, offerCard: $offerCard, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResultRouteArgs) return false;
    return result == other.result && key == other.key;
  }

  @override
  int get hashCode => result.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i5.ShareCardPage]
class ShareCardRoute extends _i8.PageRouteInfo<ShareCardRouteArgs> {
  ShareCardRoute({
    required _i9.ArchetypeResponse archetype,
    _i11.Key? key,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         ShareCardRoute.name,
         args: ShareCardRouteArgs(archetype: archetype, key: key),
         initialChildren: children,
       );

  static const String name = 'ShareCardRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShareCardRouteArgs>();
      return _i5.ShareCardPage(archetype: args.archetype, key: args.key);
    },
  );
}

class ShareCardRouteArgs {
  const ShareCardRouteArgs({required this.archetype, this.key});

  final _i9.ArchetypeResponse archetype;

  final _i11.Key? key;

  @override
  String toString() {
    return 'ShareCardRouteArgs{archetype: $archetype, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShareCardRouteArgs) return false;
    return archetype == other.archetype && key == other.key;
  }

  @override
  int get hashCode => archetype.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i6.StartupPage]
class StartupRoute extends _i8.PageRouteInfo<void> {
  const StartupRoute({List<_i8.PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i6.StartupPage();
    },
  );
}

/// generated route for
/// [_i7.WelcomePage]
class WelcomeRoute extends _i8.PageRouteInfo<void> {
  const WelcomeRoute({List<_i8.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i7.WelcomePage();
    },
  );
}
