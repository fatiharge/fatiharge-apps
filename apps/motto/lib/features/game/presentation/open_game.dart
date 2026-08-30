import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/application/game_store.dart';
import 'package:motto/features/game/application/turns_repository.dart';
import 'package:motto/infrastructure/api/outcome.dart';
import 'package:motto/infrastructure/api/trouble_bus.dart';
import 'package:motto/route/app_router.dart';
import 'package:motto/route/app_router.gr.dart';

/// The one way into the game, wherever it is opened from.
///
/// It takes no context on purpose. The mascot floats above the router — its
/// callback runs in `MaterialApp.builder`, which is outside both the router
/// and the navigator — so a context passed from there has neither to give, and
/// asking it for one crashed the tap that offered the game.
///
/// The turn is spent here, so the rules screen and the board are both on the
/// paid side of the door and neither has to ask again.
Future<void> openGame() async {
  final router = getIt<AppRouter>();

  switch (await getIt<TurnsRepository>().spend()) {
    case Ok():
      // The rules come first, and only once: three lives is short enough that
      // learning the game by losing it teaches that it is not worth playing.
      await router.push(
        getIt<GameStore>().rulesSeen ? GameRoute() : GameRulesRoute(),
      );
    case Failed(:final trouble):
      // Nothing here decides what a refusal means. Running out of turns says
      // one of two things depending on the day, and which sentence that is —
      // and where its button goes — is a row somebody edited, not a branch
      // shipped in a release.
      getIt<TroubleBus>().unhandled(trouble);
  }
}
