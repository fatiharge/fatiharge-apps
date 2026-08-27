// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i22;

import 'package:api_client_motto/api.dart' as _i23;
import 'package:auto_route/auto_route.dart' as _i20;
import 'package:flutter/material.dart' as _i21;
import 'package:motto/features/daily/presentation/today_page.dart' as _i18;
import 'package:motto/features/onboarding/presentation/onboarding_page.dart'
    as _i7;
import 'package:motto/features/profile/presentation/profile_page.dart' as _i10;
import 'package:motto/features/result/presentation/result_page.dart' as _i12;
import 'package:motto/features/result/presentation/share_card_page.dart'
    as _i14;
import 'package:motto/features/shell/presentation/shell_page.dart' as _i15;
import 'package:motto/features/startup/presentation/startup_page.dart' as _i16;
import 'package:motto/features/support/presentation/data_deletion_page.dart'
    as _i2;
import 'package:motto/features/support/presentation/faq_page.dart' as _i3;
import 'package:motto/features/support/presentation/feedback_page.dart' as _i4;
import 'package:motto/features/support/presentation/method_page.dart' as _i5;
import 'package:motto/features/support/presentation/privacy_page.dart' as _i9;
import 'package:motto/features/support/presentation/settings_page.dart' as _i13;
import 'package:motto/features/tasks/presentation/motto_detail_page.dart'
    as _i6;
import 'package:motto/features/tasks/presentation/period_report_page.dart'
    as _i8;
import 'package:motto/features/tasks/presentation/task_detail_page.dart'
    as _i17;
import 'package:motto/features/test/presentation/calculating_page.dart' as _i1;
import 'package:motto/features/test/presentation/question_page.dart' as _i11;
import 'package:motto/features/welcome/presentation/welcome_page.dart' as _i19;

/// generated route for
/// [_i1.CalculatingPage]
class CalculatingRoute extends _i20.PageRouteInfo<void> {
  const CalculatingRoute({List<_i20.PageRouteInfo>? children})
    : super(CalculatingRoute.name, initialChildren: children);

  static const String name = 'CalculatingRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return _i20.WrappedRoute(child: const _i1.CalculatingPage());
    },
  );
}

/// generated route for
/// [_i2.DataDeletionPage]
class DataDeletionRoute extends _i20.PageRouteInfo<void> {
  const DataDeletionRoute({List<_i20.PageRouteInfo>? children})
    : super(DataDeletionRoute.name, initialChildren: children);

  static const String name = 'DataDeletionRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i2.DataDeletionPage();
    },
  );
}

/// generated route for
/// [_i3.FaqPage]
class FaqRoute extends _i20.PageRouteInfo<FaqRouteArgs> {
  FaqRoute({
    String? openItem,
    _i21.Key? key,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         FaqRoute.name,
         args: FaqRouteArgs(openItem: openItem, key: key),
         rawQueryParams: {'item': openItem},
         initialChildren: children,
       );

  static const String name = 'FaqRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<FaqRouteArgs>(
        orElse: () => FaqRouteArgs(openItem: queryParams.optString('item')),
      );
      return _i3.FaqPage(openItem: args.openItem, key: args.key);
    },
  );
}

class FaqRouteArgs {
  const FaqRouteArgs({this.openItem, this.key});

  final String? openItem;

  final _i21.Key? key;

  @override
  String toString() {
    return 'FaqRouteArgs{openItem: $openItem, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FaqRouteArgs) return false;
    return openItem == other.openItem && key == other.key;
  }

  @override
  int get hashCode => openItem.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i4.FeedbackPage]
class FeedbackRoute extends _i20.PageRouteInfo<void> {
  const FeedbackRoute({List<_i20.PageRouteInfo>? children})
    : super(FeedbackRoute.name, initialChildren: children);

  static const String name = 'FeedbackRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i4.FeedbackPage();
    },
  );
}

/// generated route for
/// [_i5.MethodPage]
class MethodRoute extends _i20.PageRouteInfo<void> {
  const MethodRoute({List<_i20.PageRouteInfo>? children})
    : super(MethodRoute.name, initialChildren: children);

  static const String name = 'MethodRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i5.MethodPage();
    },
  );
}

/// generated route for
/// [_i6.MottoDetailPage]
class MottoDetailRoute extends _i20.PageRouteInfo<void> {
  const MottoDetailRoute({List<_i20.PageRouteInfo>? children})
    : super(MottoDetailRoute.name, initialChildren: children);

  static const String name = 'MottoDetailRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i6.MottoDetailPage();
    },
  );
}

/// generated route for
/// [_i7.OnboardingPage]
class OnboardingRoute extends _i20.PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    _i22.Future<void> Function(_i21.BuildContext, {required bool takeTest})?
    onDone,
    _i21.Key? key,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         OnboardingRoute.name,
         args: OnboardingRouteArgs(onDone: onDone, key: key),
         initialChildren: children,
       );

  static const String name = 'OnboardingRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnboardingRouteArgs>(
        orElse: () => const OnboardingRouteArgs(),
      );
      return _i7.OnboardingPage(onDone: args.onDone, key: args.key);
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.onDone, this.key});

  final _i22.Future<void> Function(_i21.BuildContext, {required bool takeTest})?
  onDone;

  final _i21.Key? key;

  @override
  String toString() {
    return 'OnboardingRouteArgs{onDone: $onDone, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OnboardingRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i8.PeriodReportPage]
class PeriodReportRoute extends _i20.PageRouteInfo<void> {
  const PeriodReportRoute({List<_i20.PageRouteInfo>? children})
    : super(PeriodReportRoute.name, initialChildren: children);

  static const String name = 'PeriodReportRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i8.PeriodReportPage();
    },
  );
}

/// generated route for
/// [_i9.PrivacyPage]
class PrivacyRoute extends _i20.PageRouteInfo<void> {
  const PrivacyRoute({List<_i20.PageRouteInfo>? children})
    : super(PrivacyRoute.name, initialChildren: children);

  static const String name = 'PrivacyRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i9.PrivacyPage();
    },
  );
}

/// generated route for
/// [_i10.ProfilePage]
class ProfileRoute extends _i20.PageRouteInfo<void> {
  const ProfileRoute({List<_i20.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i10.ProfilePage();
    },
  );
}

/// generated route for
/// [_i11.QuestionPage]
class QuestionRoute extends _i20.PageRouteInfo<void> {
  const QuestionRoute({List<_i20.PageRouteInfo>? children})
    : super(QuestionRoute.name, initialChildren: children);

  static const String name = 'QuestionRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return _i20.WrappedRoute(child: const _i11.QuestionPage());
    },
  );
}

/// generated route for
/// [_i12.ResultPage]
class ResultRoute extends _i20.PageRouteInfo<ResultRouteArgs> {
  ResultRoute({
    required _i23.ResultResponse result,
    _i22.Future<void> Function(_i21.BuildContext, _i23.ArchetypeResponse)?
    offerCard,
    _i21.Key? key,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         ResultRoute.name,
         args: ResultRouteArgs(result: result, offerCard: offerCard, key: key),
         initialChildren: children,
       );

  static const String name = 'ResultRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultRouteArgs>();
      return _i12.ResultPage(
        result: args.result,
        offerCard: args.offerCard,
        key: args.key,
      );
    },
  );
}

class ResultRouteArgs {
  const ResultRouteArgs({required this.result, this.offerCard, this.key});

  final _i23.ResultResponse result;

  final _i22.Future<void> Function(_i21.BuildContext, _i23.ArchetypeResponse)?
  offerCard;

  final _i21.Key? key;

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
/// [_i13.SettingsPage]
class SettingsRoute extends _i20.PageRouteInfo<void> {
  const SettingsRoute({List<_i20.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i13.SettingsPage();
    },
  );
}

/// generated route for
/// [_i14.ShareCardPage]
class ShareCardRoute extends _i20.PageRouteInfo<ShareCardRouteArgs> {
  ShareCardRoute({
    required _i23.ArchetypeResponse archetype,
    _i21.Key? key,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         ShareCardRoute.name,
         args: ShareCardRouteArgs(archetype: archetype, key: key),
         initialChildren: children,
       );

  static const String name = 'ShareCardRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShareCardRouteArgs>();
      return _i14.ShareCardPage(archetype: args.archetype, key: args.key);
    },
  );
}

class ShareCardRouteArgs {
  const ShareCardRouteArgs({required this.archetype, this.key});

  final _i23.ArchetypeResponse archetype;

  final _i21.Key? key;

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
/// [_i15.ShellPage]
class ShellRoute extends _i20.PageRouteInfo<void> {
  const ShellRoute({List<_i20.PageRouteInfo>? children})
    : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i15.ShellPage();
    },
  );
}

/// generated route for
/// [_i16.StartupPage]
class StartupRoute extends _i20.PageRouteInfo<void> {
  const StartupRoute({List<_i20.PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i16.StartupPage();
    },
  );
}

/// generated route for
/// [_i17.TaskDetailPage]
class TaskDetailRoute extends _i20.PageRouteInfo<TaskDetailRouteArgs> {
  TaskDetailRoute({
    required _i23.DailyTask task,
    required int day,
    _i22.Future<void> Function()? onDone,
    _i21.Key? key,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         TaskDetailRoute.name,
         args: TaskDetailRouteArgs(
           task: task,
           day: day,
           onDone: onDone,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'TaskDetailRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskDetailRouteArgs>();
      return _i17.TaskDetailPage(
        task: args.task,
        day: args.day,
        onDone: args.onDone,
        key: args.key,
      );
    },
  );
}

class TaskDetailRouteArgs {
  const TaskDetailRouteArgs({
    required this.task,
    required this.day,
    this.onDone,
    this.key,
  });

  final _i23.DailyTask task;

  final int day;

  final _i22.Future<void> Function()? onDone;

  final _i21.Key? key;

  @override
  String toString() {
    return 'TaskDetailRouteArgs{task: $task, day: $day, onDone: $onDone, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskDetailRouteArgs) return false;
    return task == other.task && day == other.day && key == other.key;
  }

  @override
  int get hashCode => task.hashCode ^ day.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i18.TodayPage]
class TodayRoute extends _i20.PageRouteInfo<void> {
  const TodayRoute({List<_i20.PageRouteInfo>? children})
    : super(TodayRoute.name, initialChildren: children);

  static const String name = 'TodayRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i18.TodayPage();
    },
  );
}

/// generated route for
/// [_i19.WelcomePage]
class WelcomeRoute extends _i20.PageRouteInfo<void> {
  const WelcomeRoute({List<_i20.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i19.WelcomePage();
    },
  );
}
