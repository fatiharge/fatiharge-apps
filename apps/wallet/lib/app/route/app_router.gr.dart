// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart'
    as _i9;
import 'package:wallet/app/features/finance/presentation/page/budget_page.dart'
    as _i1;
import 'package:wallet/app/features/finance/presentation/page/dashboard_page.dart'
    as _i2;
import 'package:wallet/app/features/finance/presentation/page/history_page.dart'
    as _i3;
import 'package:wallet/app/features/finance/presentation/page/main_page.dart'
    as _i4;
import 'package:wallet/app/features/finance/presentation/page/transaction_entry_page.dart'
    as _i6;
import 'package:wallet/app/features/startup/presentation/startup_page.dart'
    as _i5;

/// generated route for
/// [_i1.BudgetPage]
class BudgetRoute extends _i7.PageRouteInfo<void> {
  const BudgetRoute({List<_i7.PageRouteInfo>? children})
    : super(BudgetRoute.name, initialChildren: children);

  static const String name = 'BudgetRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.BudgetPage();
    },
  );
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardRoute extends _i7.PageRouteInfo<void> {
  const DashboardRoute({List<_i7.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.DashboardPage();
    },
  );
}

/// generated route for
/// [_i3.HistoryPage]
class HistoryRoute extends _i7.PageRouteInfo<void> {
  const HistoryRoute({List<_i7.PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.HistoryPage();
    },
  );
}

/// generated route for
/// [_i4.MainPage]
class MainRoute extends _i7.PageRouteInfo<void> {
  const MainRoute({List<_i7.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.MainPage();
    },
  );
}

/// generated route for
/// [_i5.StartupPage]
class StartupRoute extends _i7.PageRouteInfo<StartupRouteArgs> {
  StartupRoute({_i8.Key? key, List<_i7.PageRouteInfo>? children})
    : super(
        StartupRoute.name,
        args: StartupRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'StartupRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StartupRouteArgs>(
        orElse: () => const StartupRouteArgs(),
      );
      return _i5.StartupPage(key: args.key);
    },
  );
}

class StartupRouteArgs {
  const StartupRouteArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'StartupRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StartupRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i6.TransactionEntryPage]
class TransactionEntryRoute
    extends _i7.PageRouteInfo<TransactionEntryRouteArgs> {
  TransactionEntryRoute({
    _i8.Key? key,
    _i9.MoneyTransaction? existing,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         TransactionEntryRoute.name,
         args: TransactionEntryRouteArgs(key: key, existing: existing),
         initialChildren: children,
       );

  static const String name = 'TransactionEntryRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionEntryRouteArgs>(
        orElse: () => const TransactionEntryRouteArgs(),
      );
      return _i6.TransactionEntryPage(key: args.key, existing: args.existing);
    },
  );
}

class TransactionEntryRouteArgs {
  const TransactionEntryRouteArgs({this.key, this.existing});

  final _i8.Key? key;

  final _i9.MoneyTransaction? existing;

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
