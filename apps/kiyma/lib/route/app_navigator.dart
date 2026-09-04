import 'package:flutter/material.dart';
import 'package:kiyma/ui/game_screen.dart';

/// The one navigator, held so that bootstrap can open the counter without a
/// [BuildContext].
///
/// Two screens and no deep links, so this is a `Navigator` rather than the
/// generated router the other apps in this repository use. What it shares
/// with them is the shape: the port says the startup jobs are done, and this
/// decides what that opens.
class AppNavigator {
  final key = GlobalKey<NavigatorState>();

  /// Replaces the splash. Never a push: there is nothing to go back to, and
  /// a back gesture onto a finished bootstrap would re-run it.
  void openGame() => key.currentState!.pushReplacement(
    MaterialPageRoute<void>(builder: (_) => const GameScreen()),
  );
}
