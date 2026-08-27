// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i25;

import 'package:api_client_motto/api.dart' as _i26;
import 'package:auto_route/auto_route.dart' as _i23;
import 'package:flutter/material.dart' as _i24;
import 'package:motto/features/daily/presentation/today_page.dart' as _i21;
import 'package:motto/features/onboarding/presentation/onboarding_page.dart'
    as _i10;
import 'package:motto/features/profile/presentation/archive_page.dart' as _i1;
import 'package:motto/features/profile/presentation/deep_report_page.dart'
    as _i4;
import 'package:motto/features/profile/presentation/gallery_page.dart' as _i7;
import 'package:motto/features/profile/presentation/profile_page.dart' as _i13;
import 'package:motto/features/result/presentation/result_page.dart' as _i15;
import 'package:motto/features/result/presentation/share_card_page.dart'
    as _i17;
import 'package:motto/features/shell/presentation/shell_page.dart' as _i18;
import 'package:motto/features/startup/presentation/startup_page.dart' as _i19;
import 'package:motto/features/support/presentation/data_deletion_page.dart'
    as _i3;
import 'package:motto/features/support/presentation/faq_page.dart' as _i5;
import 'package:motto/features/support/presentation/feedback_page.dart' as _i6;
import 'package:motto/features/support/presentation/method_page.dart' as _i8;
import 'package:motto/features/support/presentation/privacy_page.dart' as _i12;
import 'package:motto/features/support/presentation/settings_page.dart' as _i16;
import 'package:motto/features/tasks/presentation/motto_detail_page.dart'
    as _i9;
import 'package:motto/features/tasks/presentation/period_report_page.dart'
    as _i11;
import 'package:motto/features/tasks/presentation/task_detail_page.dart'
    as _i20;
import 'package:motto/features/test/presentation/calculating_page.dart' as _i2;
import 'package:motto/features/test/presentation/question_page.dart' as _i14;
import 'package:motto/features/welcome/presentation/welcome_page.dart' as _i22;

/// generated route for
/// [_i1.ArchivePage]
class ArchiveRoute extends _i23.PageRouteInfo<void> {
  const ArchiveRoute({List<_i23.PageRouteInfo>? children})
    : super(ArchiveRoute.name, initialChildren: children);

  static const String name = 'ArchiveRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i1.ArchivePage();
    },
  );
}

/// generated route for
/// [_i2.CalculatingPage]
class CalculatingRoute extends _i23.PageRouteInfo<void> {
  const CalculatingRoute({List<_i23.PageRouteInfo>? children})
    : super(CalculatingRoute.name, initialChildren: children);

  static const String name = 'CalculatingRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return _i23.WrappedRoute(child: const _i2.CalculatingPage());
    },
  );
}

/// generated route for
/// [_i3.DataDeletionPage]
class DataDeletionRoute extends _i23.PageRouteInfo<void> {
  const DataDeletionRoute({List<_i23.PageRouteInfo>? children})
    : super(DataDeletionRoute.name, initialChildren: children);

  static const String name = 'DataDeletionRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i3.DataDeletionPage();
    },
  );
}

/// generated route for
/// [_i4.DeepReportPage]
class DeepReportRoute extends _i23.PageRouteInfo<DeepReportRouteArgs> {
  DeepReportRoute({
    required int resultId,
    _i24.Key? key,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         DeepReportRoute.name,
         args: DeepReportRouteArgs(resultId: resultId, key: key),
         rawPathParams: {'resultId': resultId},
         initialChildren: children,
       );

  static const String name = 'DeepReportRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DeepReportRouteArgs>(
        orElse: () =>
            DeepReportRouteArgs(resultId: pathParams.getInt('resultId')),
      );
      return _i4.DeepReportPage(resultId: args.resultId, key: args.key);
    },
  );
}

class DeepReportRouteArgs {
  const DeepReportRouteArgs({required this.resultId, this.key});

  final int resultId;

  final _i24.Key? key;

  @override
  String toString() {
    return 'DeepReportRouteArgs{resultId: $resultId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeepReportRouteArgs) return false;
    return resultId == other.resultId && key == other.key;
  }

  @override
  int get hashCode => resultId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i5.FaqPage]
class FaqRoute extends _i23.PageRouteInfo<FaqRouteArgs> {
  FaqRoute({
    String? openItem,
    _i24.Key? key,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         FaqRoute.name,
         args: FaqRouteArgs(openItem: openItem, key: key),
         rawQueryParams: {'item': openItem},
         initialChildren: children,
       );

  static const String name = 'FaqRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<FaqRouteArgs>(
        orElse: () => FaqRouteArgs(openItem: queryParams.optString('item')),
      );
      return _i5.FaqPage(openItem: args.openItem, key: args.key);
    },
  );
}

class FaqRouteArgs {
  const FaqRouteArgs({this.openItem, this.key});

  final String? openItem;

  final _i24.Key? key;

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
/// [_i6.FeedbackPage]
class FeedbackRoute extends _i23.PageRouteInfo<void> {
  const FeedbackRoute({List<_i23.PageRouteInfo>? children})
    : super(FeedbackRoute.name, initialChildren: children);

  static const String name = 'FeedbackRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i6.FeedbackPage();
    },
  );
}

/// generated route for
/// [_i7.GalleryPage]
class GalleryRoute extends _i23.PageRouteInfo<void> {
  const GalleryRoute({List<_i23.PageRouteInfo>? children})
    : super(GalleryRoute.name, initialChildren: children);

  static const String name = 'GalleryRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i7.GalleryPage();
    },
  );
}

/// generated route for
/// [_i8.MethodPage]
class MethodRoute extends _i23.PageRouteInfo<void> {
  const MethodRoute({List<_i23.PageRouteInfo>? children})
    : super(MethodRoute.name, initialChildren: children);

  static const String name = 'MethodRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i8.MethodPage();
    },
  );
}

/// generated route for
/// [_i9.MottoDetailPage]
class MottoDetailRoute extends _i23.PageRouteInfo<void> {
  const MottoDetailRoute({List<_i23.PageRouteInfo>? children})
    : super(MottoDetailRoute.name, initialChildren: children);

  static const String name = 'MottoDetailRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i9.MottoDetailPage();
    },
  );
}

/// generated route for
/// [_i10.OnboardingPage]
class OnboardingRoute extends _i23.PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    _i25.Future<void> Function(_i24.BuildContext, {required bool takeTest})?
    onDone,
    _i24.Key? key,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         OnboardingRoute.name,
         args: OnboardingRouteArgs(onDone: onDone, key: key),
         initialChildren: children,
       );

  static const String name = 'OnboardingRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnboardingRouteArgs>(
        orElse: () => const OnboardingRouteArgs(),
      );
      return _i10.OnboardingPage(onDone: args.onDone, key: args.key);
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.onDone, this.key});

  final _i25.Future<void> Function(_i24.BuildContext, {required bool takeTest})?
  onDone;

  final _i24.Key? key;

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
/// [_i11.PeriodReportPage]
class PeriodReportRoute extends _i23.PageRouteInfo<void> {
  const PeriodReportRoute({List<_i23.PageRouteInfo>? children})
    : super(PeriodReportRoute.name, initialChildren: children);

  static const String name = 'PeriodReportRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i11.PeriodReportPage();
    },
  );
}

/// generated route for
/// [_i12.PrivacyPage]
class PrivacyRoute extends _i23.PageRouteInfo<void> {
  const PrivacyRoute({List<_i23.PageRouteInfo>? children})
    : super(PrivacyRoute.name, initialChildren: children);

  static const String name = 'PrivacyRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i12.PrivacyPage();
    },
  );
}

/// generated route for
/// [_i13.ProfilePage]
class ProfileRoute extends _i23.PageRouteInfo<void> {
  const ProfileRoute({List<_i23.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i13.ProfilePage();
    },
  );
}

/// generated route for
/// [_i14.QuestionPage]
class QuestionRoute extends _i23.PageRouteInfo<void> {
  const QuestionRoute({List<_i23.PageRouteInfo>? children})
    : super(QuestionRoute.name, initialChildren: children);

  static const String name = 'QuestionRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return _i23.WrappedRoute(child: const _i14.QuestionPage());
    },
  );
}

/// generated route for
/// [_i15.ResultPage]
class ResultRoute extends _i23.PageRouteInfo<ResultRouteArgs> {
  ResultRoute({
    required _i26.ResultResponse result,
    _i25.Future<void> Function(_i24.BuildContext, _i26.ArchetypeResponse)?
    offerCard,
    _i24.Key? key,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         ResultRoute.name,
         args: ResultRouteArgs(result: result, offerCard: offerCard, key: key),
         initialChildren: children,
       );

  static const String name = 'ResultRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultRouteArgs>();
      return _i15.ResultPage(
        result: args.result,
        offerCard: args.offerCard,
        key: args.key,
      );
    },
  );
}

class ResultRouteArgs {
  const ResultRouteArgs({required this.result, this.offerCard, this.key});

  final _i26.ResultResponse result;

  final _i25.Future<void> Function(_i24.BuildContext, _i26.ArchetypeResponse)?
  offerCard;

  final _i24.Key? key;

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
/// [_i16.SettingsPage]
class SettingsRoute extends _i23.PageRouteInfo<void> {
  const SettingsRoute({List<_i23.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i16.SettingsPage();
    },
  );
}

/// generated route for
/// [_i17.ShareCardPage]
class ShareCardRoute extends _i23.PageRouteInfo<ShareCardRouteArgs> {
  ShareCardRoute({
    required _i26.ArchetypeResponse archetype,
    _i24.Key? key,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         ShareCardRoute.name,
         args: ShareCardRouteArgs(archetype: archetype, key: key),
         initialChildren: children,
       );

  static const String name = 'ShareCardRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShareCardRouteArgs>();
      return _i17.ShareCardPage(archetype: args.archetype, key: args.key);
    },
  );
}

class ShareCardRouteArgs {
  const ShareCardRouteArgs({required this.archetype, this.key});

  final _i26.ArchetypeResponse archetype;

  final _i24.Key? key;

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
/// [_i18.ShellPage]
class ShellRoute extends _i23.PageRouteInfo<void> {
  const ShellRoute({List<_i23.PageRouteInfo>? children})
    : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i18.ShellPage();
    },
  );
}

/// generated route for
/// [_i19.StartupPage]
class StartupRoute extends _i23.PageRouteInfo<void> {
  const StartupRoute({List<_i23.PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i19.StartupPage();
    },
  );
}

/// generated route for
/// [_i20.TaskDetailPage]
class TaskDetailRoute extends _i23.PageRouteInfo<TaskDetailRouteArgs> {
  TaskDetailRoute({
    required _i26.DailyTask task,
    required int day,
    _i25.Future<void> Function()? onDone,
    _i24.Key? key,
    List<_i23.PageRouteInfo>? children,
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

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskDetailRouteArgs>();
      return _i20.TaskDetailPage(
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

  final _i26.DailyTask task;

  final int day;

  final _i25.Future<void> Function()? onDone;

  final _i24.Key? key;

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
/// [_i21.TodayPage]
class TodayRoute extends _i23.PageRouteInfo<void> {
  const TodayRoute({List<_i23.PageRouteInfo>? children})
    : super(TodayRoute.name, initialChildren: children);

  static const String name = 'TodayRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i21.TodayPage();
    },
  );
}

/// generated route for
/// [_i22.WelcomePage]
class WelcomeRoute extends _i23.PageRouteInfo<void> {
  const WelcomeRoute({List<_i23.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i22.WelcomePage();
    },
  );
}
