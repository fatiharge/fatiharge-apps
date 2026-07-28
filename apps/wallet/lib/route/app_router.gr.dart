// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i9;
import 'package:wallet/features/about/presentation/page/about_page.dart' as _i1;
import 'package:wallet/features/finance/domain/models/money_transaction.dart'
    as _i10;
import 'package:wallet/features/finance/presentation/page/budget_page.dart'
    as _i2;
import 'package:wallet/features/finance/presentation/page/dashboard_page.dart'
    as _i3;
import 'package:wallet/features/finance/presentation/page/history_page.dart'
    as _i4;
import 'package:wallet/features/finance/presentation/page/main_page.dart'
    as _i5;
import 'package:wallet/features/finance/presentation/page/transaction_entry_page.dart'
    as _i7;
import 'package:wallet/features/startup/presentation/startup_page.dart' as _i6;

/// generated route for
/// [_i1.AboutPage]
class AboutRoute extends _i8.PageRouteInfo<void> {
  const AboutRoute({List<_i8.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutPage();
    },
  );
}

/// generated route for
/// [_i2.BudgetPage]
class BudgetRoute extends _i8.PageRouteInfo<void> {
  const BudgetRoute({List<_i8.PageRouteInfo>? children})
    : super(BudgetRoute.name, initialChildren: children);

  static const String name = 'BudgetRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i2.BudgetPage();
    },
  );
}

/// generated route for
/// [_i3.DashboardPage]
class DashboardRoute extends _i8.PageRouteInfo<void> {
  const DashboardRoute({List<_i8.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.DashboardPage();
    },
  );
}

/// generated route for
/// [_i4.HistoryPage]
class HistoryRoute extends _i8.PageRouteInfo<void> {
  const HistoryRoute({List<_i8.PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.HistoryPage();
    },
  );
}

/// generated route for
/// [_i5.MainPage]
class MainRoute extends _i8.PageRouteInfo<void> {
  const MainRoute({List<_i8.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i5.MainPage();
    },
  );
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
/// [_i7.TransactionEntryPage]
class TransactionEntryRoute
    extends _i8.PageRouteInfo<TransactionEntryRouteArgs> {
  TransactionEntryRoute({
    _i9.Key? key,
    _i10.MoneyTransaction? existing,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         TransactionEntryRoute.name,
         args: TransactionEntryRouteArgs(key: key, existing: existing),
         initialChildren: children,
       );

  static const String name = 'TransactionEntryRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionEntryRouteArgs>(
        orElse: () => const TransactionEntryRouteArgs(),
      );
      return _i7.TransactionEntryPage(key: args.key, existing: args.existing);
    },
  );
}

class TransactionEntryRouteArgs {
  const TransactionEntryRouteArgs({this.key, this.existing});

  final _i9.Key? key;

  final _i10.MoneyTransaction? existing;

  @override
  String toString() {
    return 'TransactionEntryRouteArgs{key: $key, existing: $existing}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionEntryRouteArgs) return false;
    return key == other.key && existing == other.existing;
  }

  @override
  int get hashCode => key.hashCode ^ existing.hashCode;
}
