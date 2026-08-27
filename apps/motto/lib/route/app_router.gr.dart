// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:api_client_motto/api.dart' as _i7;
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i8;
import 'package:motto/features/result/presentation/result_page.dart' as _i3;
import 'package:motto/features/startup/presentation/startup_page.dart' as _i4;
import 'package:motto/features/test/presentation/calculating_page.dart' as _i1;
import 'package:motto/features/test/presentation/question_page.dart' as _i2;
import 'package:motto/features/welcome/presentation/welcome_page.dart' as _i5;

/// generated route for
/// [_i1.CalculatingPage]
class CalculatingRoute extends _i6.PageRouteInfo<void> {
  const CalculatingRoute({List<_i6.PageRouteInfo>? children})
    : super(CalculatingRoute.name, initialChildren: children);

  static const String name = 'CalculatingRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return _i6.WrappedRoute(child: const _i1.CalculatingPage());
    },
  );
}

/// generated route for
/// [_i2.QuestionPage]
class QuestionRoute extends _i6.PageRouteInfo<void> {
  const QuestionRoute({List<_i6.PageRouteInfo>? children})
    : super(QuestionRoute.name, initialChildren: children);

  static const String name = 'QuestionRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return _i6.WrappedRoute(child: const _i2.QuestionPage());
    },
  );
}

/// generated route for
/// [_i3.ResultPage]
class ResultRoute extends _i6.PageRouteInfo<ResultRouteArgs> {
  ResultRoute({
    required _i7.ResultResponse result,
    _i8.Key? key,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         ResultRoute.name,
         args: ResultRouteArgs(result: result, key: key),
         initialChildren: children,
       );

  static const String name = 'ResultRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultRouteArgs>();
      return _i3.ResultPage(result: args.result, key: args.key);
    },
  );
}

class ResultRouteArgs {
  const ResultRouteArgs({required this.result, this.key});

  final _i7.ResultResponse result;

  final _i8.Key? key;

  @override
  String toString() {
    return 'ResultRouteArgs{result: $result, key: $key}';
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
/// [_i4.StartupPage]
class StartupRoute extends _i6.PageRouteInfo<void> {
  const StartupRoute({List<_i6.PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.StartupPage();
    },
  );
}

/// generated route for
/// [_i5.WelcomePage]
class WelcomeRoute extends _i6.PageRouteInfo<void> {
  const WelcomeRoute({List<_i6.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.WelcomePage();
    },
  );
}
