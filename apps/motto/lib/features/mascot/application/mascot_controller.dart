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

  /// Untouched for this long and it does something to be noticed.
  static const idleBeforeAttention = Duration(seconds: 20);

  /// And this long before it offers the game — far enough apart that the two
  /// never read as one twitchy character.
  static const idleBeforeOffer = Duration(seconds: 75);

  static double decayed(double annoyance, Duration since) {
    final calmed = annoyance - decayPerSecond * since.inMilliseconds / 1000;
    return calmed < 0 ? 0 : calmed;
  }
}
