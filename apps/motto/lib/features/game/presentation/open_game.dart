import 'package:motto/config/injectable.dart';
import 'package:motto/features/game/application/game_store.dart';
import 'package:motto/features/game/application/turns_repository.dart';
import 'package:motto/features/game/presentation/no_turns_sheet.dart';
import 'package:motto/features/support/presentation/widgets/trouble_sheet.dart';
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
  final turns = getIt<TurnsRepository>();

  bool? paid;
  try {
    paid = await turns.spend();
  } on Object catch (failure) {
    final context = router.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    await showTroubleSheet(context, failure: failure, retry: openGame);
    return;
  }

  if (!paid) {
    final left = await turns.today();
    final context = router.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    // Both halves of the day, not just the tasks: a day whose three things
    // are done but whose mark is outstanding still has a turn waiting in it.
    await NoTurnsSheet.show(
      context,
      nothingLeftToEarn:
          (left?.dayMarked ?? false) && (left?.tasksDone ?? false),
    );
    return;
  }

  // The rules come first, and only once: three lives is short enough that
  // learning the game by losing it teaches that it is not worth playing.
  await router.push(
    getIt<GameStore>().rulesSeen ? GameRoute() : GameRulesRoute(),
  );
}
