// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i32;
import 'dart:math' as _i31;

import 'package:api_client_motto/api.dart' as _i30;
import 'package:auto_route/auto_route.dart' as _i28;
import 'package:flutter/material.dart' as _i29;
import 'package:motto/features/daily/presentation/today_page.dart' as _i26;
import 'package:motto/features/game/presentation/game_over_page.dart' as _i9;
import 'package:motto/features/game/presentation/game_page.dart' as _i10;
import 'package:motto/features/game/presentation/game_rules_page.dart' as _i11;
import 'package:motto/features/onboarding/presentation/onboarding_page.dart'
    as _i14;
import 'package:motto/features/profile/presentation/archive_page.dart' as _i1;
import 'package:motto/features/profile/presentation/deep_report_page.dart'
    as _i5;
import 'package:motto/features/profile/presentation/gallery_page.dart' as _i8;
import 'package:motto/features/profile/presentation/profile_page.dart' as _i17;
import 'package:motto/features/result/presentation/report_page.dart' as _i19;
import 'package:motto/features/result/presentation/result_page.dart' as _i20;
import 'package:motto/features/result/presentation/share_card_page.dart'
    as _i22;
import 'package:motto/features/shell/presentation/shell_page.dart' as _i23;
import 'package:motto/features/startup/presentation/startup_page.dart' as _i24;
import 'package:motto/features/support/presentation/data_deletion_page.dart'
    as _i4;
import 'package:motto/features/support/presentation/faq_page.dart' as _i6;
import 'package:motto/features/support/presentation/feedback_page.dart' as _i7;
import 'package:motto/features/support/presentation/method_page.dart' as _i12;
import 'package:motto/features/support/presentation/privacy_page.dart' as _i16;
import 'package:motto/features/support/presentation/settings_page.dart' as _i21;
import 'package:motto/features/tasks/presentation/daily_tasks_page.dart' as _i3;
import 'package:motto/features/tasks/presentation/motto_detail_page.dart'
    as _i13;
import 'package:motto/features/tasks/presentation/period_report_page.dart'
    as _i15;
import 'package:motto/features/tasks/presentation/task_detail_page.dart'
    as _i25;
import 'package:motto/features/test/presentation/calculating_page.dart' as _i2;
import 'package:motto/features/test/presentation/question_page.dart' as _i18;
import 'package:motto/features/welcome/presentation/welcome_page.dart' as _i27;

/// generated route for
/// [_i1.ArchivePage]
class ArchiveRoute extends _i28.PageRouteInfo<void> {
  const ArchiveRoute({List<_i28.PageRouteInfo>? children})
    : super(ArchiveRoute.name, initialChildren: children);

  static const String name = 'ArchiveRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i1.ArchivePage();
    },
  );
}

/// generated route for
/// [_i2.CalculatingPage]
class CalculatingRoute extends _i28.PageRouteInfo<void> {
  const CalculatingRoute({List<_i28.PageRouteInfo>? children})
    : super(CalculatingRoute.name, initialChildren: children);

  static const String name = 'CalculatingRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i2.CalculatingPage());
    },
  );
}

/// generated route for
/// [_i3.DailyTasksPage]
class DailyTasksRoute extends _i28.PageRouteInfo<void> {
  const DailyTasksRoute({List<_i28.PageRouteInfo>? children})
    : super(DailyTasksRoute.name, initialChildren: children);

  static const String name = 'DailyTasksRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i3.DailyTasksPage();
    },
  );
}

/// generated route for
/// [_i4.DataDeletionPage]
class DataDeletionRoute extends _i28.PageRouteInfo<void> {
  const DataDeletionRoute({List<_i28.PageRouteInfo>? children})
    : super(DataDeletionRoute.name, initialChildren: children);

  static const String name = 'DataDeletionRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i4.DataDeletionPage();
    },
  );
}

/// generated route for
/// [_i5.DeepReportPage]
class DeepReportRoute extends _i28.PageRouteInfo<DeepReportRouteArgs> {
  DeepReportRoute({
    required int resultId,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         DeepReportRoute.name,
         args: DeepReportRouteArgs(resultId: resultId, key: key),
         rawPathParams: {'resultId': resultId},
         initialChildren: children,
       );

  static const String name = 'DeepReportRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DeepReportRouteArgs>(
        orElse: () =>
            DeepReportRouteArgs(resultId: pathParams.getInt('resultId')),
      );
      return _i5.DeepReportPage(resultId: args.resultId, key: args.key);
    },
  );
}

class DeepReportRouteArgs {
  const DeepReportRouteArgs({required this.resultId, this.key});

  final int resultId;

  final _i29.Key? key;

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
/// [_i6.FaqPage]
class FaqRoute extends _i28.PageRouteInfo<FaqRouteArgs> {
  FaqRoute({
    String? openItem,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         FaqRoute.name,
         args: FaqRouteArgs(openItem: openItem, key: key),
         rawQueryParams: {'item': openItem},
         initialChildren: children,
       );

  static const String name = 'FaqRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<FaqRouteArgs>(
        orElse: () => FaqRouteArgs(openItem: queryParams.optString('item')),
      );
      return _i6.FaqPage(openItem: args.openItem, key: args.key);
    },
  );
}

class FaqRouteArgs {
  const FaqRouteArgs({this.openItem, this.key});

  final String? openItem;

  final _i29.Key? key;

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
/// [_i7.FeedbackPage]
class FeedbackRoute extends _i28.PageRouteInfo<void> {
  const FeedbackRoute({List<_i28.PageRouteInfo>? children})
    : super(FeedbackRoute.name, initialChildren: children);

  static const String name = 'FeedbackRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i7.FeedbackPage();
    },
  );
}

/// generated route for
/// [_i8.GalleryPage]
class GalleryRoute extends _i28.PageRouteInfo<void> {
  const GalleryRoute({List<_i28.PageRouteInfo>? children})
    : super(GalleryRoute.name, initialChildren: children);

  static const String name = 'GalleryRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i8.GalleryPage();
    },
  );
}

/// generated route for
/// [_i9.GameOverPage]
class GameOverRoute extends _i28.PageRouteInfo<GameOverRouteArgs> {
  GameOverRoute({
    required int score,
    _i30.Leaderboard? board,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         GameOverRoute.name,
         args: GameOverRouteArgs(score: score, board: board, key: key),
         initialChildren: children,
       );

  static const String name = 'GameOverRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameOverRouteArgs>();
      return _i9.GameOverPage(
        score: args.score,
        board: args.board,
        key: args.key,
      );
    },
  );
}

class GameOverRouteArgs {
  const GameOverRouteArgs({required this.score, this.board, this.key});

  final int score;

  final _i30.Leaderboard? board;

  final _i29.Key? key;

  @override
  String toString() {
    return 'GameOverRouteArgs{score: $score, board: $board, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameOverRouteArgs) return false;
    return score == other.score && board == other.board && key == other.key;
  }

  @override
  int get hashCode => score.hashCode ^ board.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i10.GamePage]
class GameRoute extends _i28.PageRouteInfo<GameRouteArgs> {
  GameRoute({
    _i31.Random? random,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         GameRoute.name,
         args: GameRouteArgs(random: random, key: key),
         initialChildren: children,
       );

  static const String name = 'GameRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameRouteArgs>(
        orElse: () => const GameRouteArgs(),
      );
      return _i10.GamePage(random: args.random, key: args.key);
    },
  );
}

class GameRouteArgs {
  const GameRouteArgs({this.random, this.key});

  final _i31.Random? random;

  final _i29.Key? key;

  @override
  String toString() {
    return 'GameRouteArgs{random: $random, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameRouteArgs) return false;
    return random == other.random && key == other.key;
  }

  @override
  int get hashCode => random.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i11.GameRulesPage]
class GameRulesRoute extends _i28.PageRouteInfo<GameRulesRouteArgs> {
  GameRulesRoute({
    _i32.Future<void> Function(_i29.BuildContext)? onStart,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         GameRulesRoute.name,
         args: GameRulesRouteArgs(onStart: onStart, key: key),
         initialChildren: children,
       );

  static const String name = 'GameRulesRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameRulesRouteArgs>(
        orElse: () => const GameRulesRouteArgs(),
      );
      return _i11.GameRulesPage(onStart: args.onStart, key: args.key);
    },
  );
}

class GameRulesRouteArgs {
  const GameRulesRouteArgs({this.onStart, this.key});

  final _i32.Future<void> Function(_i29.BuildContext)? onStart;

  final _i29.Key? key;

  @override
  String toString() {
    return 'GameRulesRouteArgs{onStart: $onStart, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameRulesRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i12.MethodPage]
class MethodRoute extends _i28.PageRouteInfo<void> {
  const MethodRoute({List<_i28.PageRouteInfo>? children})
    : super(MethodRoute.name, initialChildren: children);

  static const String name = 'MethodRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i12.MethodPage();
    },
  );
}

/// generated route for
/// [_i13.MottoDetailPage]
class MottoDetailRoute extends _i28.PageRouteInfo<void> {
  const MottoDetailRoute({List<_i28.PageRouteInfo>? children})
    : super(MottoDetailRoute.name, initialChildren: children);

  static const String name = 'MottoDetailRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i13.MottoDetailPage();
    },
  );
}

/// generated route for
/// [_i14.OnboardingPage]
class OnboardingRoute extends _i28.PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    _i32.Future<void> Function(_i29.BuildContext, {required bool takeTest})?
    onDone,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         OnboardingRoute.name,
         args: OnboardingRouteArgs(onDone: onDone, key: key),
         initialChildren: children,
       );

  static const String name = 'OnboardingRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnboardingRouteArgs>(
        orElse: () => const OnboardingRouteArgs(),
      );
      return _i14.OnboardingPage(onDone: args.onDone, key: args.key);
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.onDone, this.key});

  final _i32.Future<void> Function(_i29.BuildContext, {required bool takeTest})?
  onDone;

  final _i29.Key? key;

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
/// [_i15.PeriodReportPage]
class PeriodReportRoute extends _i28.PageRouteInfo<void> {
  const PeriodReportRoute({List<_i28.PageRouteInfo>? children})
    : super(PeriodReportRoute.name, initialChildren: children);

  static const String name = 'PeriodReportRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i15.PeriodReportPage();
    },
  );
}

/// generated route for
/// [_i16.PrivacyPage]
class PrivacyRoute extends _i28.PageRouteInfo<void> {
  const PrivacyRoute({List<_i28.PageRouteInfo>? children})
    : super(PrivacyRoute.name, initialChildren: children);

  static const String name = 'PrivacyRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i16.PrivacyPage();
    },
  );
}

/// generated route for
/// [_i17.ProfilePage]
class ProfileRoute extends _i28.PageRouteInfo<void> {
  const ProfileRoute({List<_i28.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i17.ProfilePage();
    },
  );
}

/// generated route for
/// [_i18.QuestionPage]
class QuestionRoute extends _i28.PageRouteInfo<void> {
  const QuestionRoute({List<_i28.PageRouteInfo>? children})
    : super(QuestionRoute.name, initialChildren: children);

  static const String name = 'QuestionRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i18.QuestionPage());
    },
  );
}

/// generated route for
/// [_i19.ReportPage]
class ReportRoute extends _i28.PageRouteInfo<ReportRouteArgs> {
  ReportRoute({
    required int resultId,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         ReportRoute.name,
         args: ReportRouteArgs(resultId: resultId, key: key),
         rawPathParams: {'resultId': resultId},
         initialChildren: children,
       );

  static const String name = 'ReportRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ReportRouteArgs>(
        orElse: () => ReportRouteArgs(resultId: pathParams.getInt('resultId')),
      );
      return _i19.ReportPage(resultId: args.resultId, key: args.key);
    },
  );
}

class ReportRouteArgs {
  const ReportRouteArgs({required this.resultId, this.key});

  final int resultId;

  final _i29.Key? key;

  @override
  String toString() {
    return 'ReportRouteArgs{resultId: $resultId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReportRouteArgs) return false;
    return resultId == other.resultId && key == other.key;
  }

  @override
  int get hashCode => resultId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i20.ResultPage]
class ResultRoute extends _i28.PageRouteInfo<ResultRouteArgs> {
  ResultRoute({
    required _i30.ArchetypeResponse archetype,
    required int resultId,
    bool justClaimed = false,
    _i32.Future<void> Function(_i29.BuildContext, _i30.ArchetypeResponse)?
    offerCard,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         ResultRoute.name,
         args: ResultRouteArgs(
           archetype: archetype,
           resultId: resultId,
           justClaimed: justClaimed,
           offerCard: offerCard,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'ResultRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultRouteArgs>();
      return _i20.ResultPage(
        archetype: args.archetype,
        resultId: args.resultId,
        justClaimed: args.justClaimed,
        offerCard: args.offerCard,
        key: args.key,
      );
    },
  );
}

class ResultRouteArgs {
  const ResultRouteArgs({
    required this.archetype,
    required this.resultId,
    this.justClaimed = false,
    this.offerCard,
    this.key,
  });

  final _i30.ArchetypeResponse archetype;

  final int resultId;

  final bool justClaimed;

  final _i32.Future<void> Function(_i29.BuildContext, _i30.ArchetypeResponse)?
  offerCard;

  final _i29.Key? key;

  @override
  String toString() {
    return 'ResultRouteArgs{archetype: $archetype, resultId: $resultId, justClaimed: $justClaimed, offerCard: $offerCard, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResultRouteArgs) return false;
    return archetype == other.archetype &&
        resultId == other.resultId &&
        justClaimed == other.justClaimed &&
        key == other.key;
  }

  @override
  int get hashCode =>
      archetype.hashCode ^
      resultId.hashCode ^
      justClaimed.hashCode ^
      key.hashCode;
}

/// generated route for
/// [_i21.SettingsPage]
class SettingsRoute extends _i28.PageRouteInfo<void> {
  const SettingsRoute({List<_i28.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i21.SettingsPage();
    },
  );
}

/// generated route for
/// [_i22.ShareCardPage]
class ShareCardRoute extends _i28.PageRouteInfo<ShareCardRouteArgs> {
  ShareCardRoute({
    required _i30.ArchetypeResponse archetype,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         ShareCardRoute.name,
         args: ShareCardRouteArgs(archetype: archetype, key: key),
         initialChildren: children,
       );

  static const String name = 'ShareCardRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShareCardRouteArgs>();
      return _i22.ShareCardPage(archetype: args.archetype, key: args.key);
    },
  );
}

class ShareCardRouteArgs {
  const ShareCardRouteArgs({required this.archetype, this.key});

  final _i30.ArchetypeResponse archetype;

  final _i29.Key? key;

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
/// [_i23.ShellPage]
class ShellRoute extends _i28.PageRouteInfo<void> {
  const ShellRoute({List<_i28.PageRouteInfo>? children})
    : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i23.ShellPage();
    },
  );
}

/// generated route for
/// [_i24.StartupPage]
class StartupRoute extends _i28.PageRouteInfo<void> {
  const StartupRoute({List<_i28.PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i24.StartupPage();
    },
  );
}

/// generated route for
/// [_i25.TaskDetailPage]
class TaskDetailRoute extends _i28.PageRouteInfo<TaskDetailRouteArgs> {
  TaskDetailRoute({
    required _i30.DailyTask task,
    required int day,
    _i32.Future<void> Function()? onDone,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
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

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskDetailRouteArgs>();
      return _i25.TaskDetailPage(
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

  final _i30.DailyTask task;

  final int day;

  final _i32.Future<void> Function()? onDone;

  final _i29.Key? key;

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
/// [_i26.TodayPage]
class TodayRoute extends _i28.PageRouteInfo<void> {
  const TodayRoute({List<_i28.PageRouteInfo>? children})
    : super(TodayRoute.name, initialChildren: children);

  static const String name = 'TodayRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i26.TodayPage();
    },
  );
}

/// generated route for
/// [_i27.WelcomePage]
class WelcomeRoute extends _i28.PageRouteInfo<void> {
  const WelcomeRoute({List<_i28.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i27.WelcomePage();
    },
  );
}
