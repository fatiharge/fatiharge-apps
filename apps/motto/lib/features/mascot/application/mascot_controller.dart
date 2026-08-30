import 'dart:ui';

/// What the app can ask the mascot to do.
///
/// An interface rather than the Rive controller itself, so the screens never
/// learn what is drawing it. Swapping the file, or the renderer, changes one
/// class.
abstract interface class MascotController {
  /// Someone tapped it.
  void poke();

  /// 0 to 100. Rises with repeated pokes and decays when left alone; past its
  /// threshold the mascot stops finding it funny.
  set annoyance(double value);

  double get annoyance;

  /// Held under a finger, with the direction of the pull.
  void drag({required bool held, double x = 0, double y = 0});

  /// Off the screen and back.
  void flee();

  /// Nobody has touched it in a while.
  void attention();

  /// The question-mark bubble that opens the game.
  void offerGame();

  void celebrate();
}

/// Everything the mascot does, decided without a renderer.
///
/// The rules live here rather than in the widget so they can be tested without
/// pumping frames, and so the placeholder and the real file behave the same.
class MascotRules {
  /// Past this the mascot is annoyed rather than amused.
  static const annoyedAt = 60.0;

  /// Enough pokes in a row and it leaves.
  static const fleeAt = 100.0;

  /// One poke's worth.
  static const perPoke = 25.0;

  /// How fast being left alone calms it down, per second.
  static const decayPerSecond = 8.0;

  /// Far enough to feel elastic, near enough that it never leaves its corner
  /// of the screen — one dragged off it is one somebody has to go looking for.
  static const maxPull = 48.0;

  /// Where a pull of [delta] from [from] lands.
  static Offset pulledTo(Offset from, Offset delta) {
    final pulled = from + delta;
    final distance = pulled.distance;
    return distance > maxPull ? pulled * (maxPull / distance) : pulled;
  }

  /// Untouched for this long and it does something to be noticed.
  static const idleBeforeAttention = Duration(seconds: 2);

  /// And this long before it offers the game.
  ///
  /// Seven seconds, down from ten and before that seventy-five. Seventy-five
  /// is longer than anybody sits still on a screen they have already read, so
  /// the offer arrived after they had gone. The two are still far enough
  /// apart to read as one character getting bored rather than twitching.
  static const idleBeforeOffer = Duration(seconds: 7);

  /// How often the idle rules are asked. It sets how late the offer can be:
  /// the wait is [idleBeforeOffer] plus up to one tick, so a five-second tick
  /// on a ten-second rule meant fifteen seconds of sitting still.
  static const idleTick = Duration(seconds: 2);

  static double decayed(double annoyance, Duration since) {
    final calmed = annoyance - decayPerSecond * since.inMilliseconds / 1000;
    return calmed < 0 ? 0 : calmed;
  }
}
