import 'package:auto_route/auto_route.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/application/game_store.dart';
import 'package:motto/route/app_router.gr.dart';

/// The one way the game is opened, wherever it is opened from.
///
/// The rules come first, and only once: three lives is short enough that
/// learning the game by losing it teaches that it is not worth playing.
Future<void> openGame(StackRouter router) => router.push(
  getIt<GameStore>().rulesSeen ? GameRoute() : GameRulesRoute(),
);
