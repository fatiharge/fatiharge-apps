import 'package:motto/features/mascot/application/mascot_controller.dart';

/// What the mascot should do about having been left alone.
enum MascotNudge {
  /// Nothing yet.
  none,

  /// Do something to be noticed.
  attention,

  /// Put the question mark up: a tap now opens the game.
  offer,
}

/// The idle rules, with no renderer in them.
///
/// Pulled out of the widget because this is the part that decides whether the
/// game is reachable at all, and the widget cannot be tested — rive needs a
/// native library `flutter test` does not have. A rule nobody can test is a
/// rule that quietly stops working, which is what happened: the game was
/// offered after seventy-five seconds and nobody ever saw it.
class MascotAttention {
  MascotAttention({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _lastTouched = _clock();
  }

  final DateTime Function() _clock;

  late DateTime _lastTouched;
  bool _offering = false;

  /// True while a tap would open the game rather than poke.
  bool get offering => _offering;

  Duration get alone => _clock().difference(_lastTouched);

  /// Somebody touched it — by tapping, dragging, or being congratulated.
  void touched() {
    _lastTouched = _clock();
    _offering = false;
  }

  /// What to do on this tick. Asked on a timer.
  MascotNudge nudge() {
    final idle = alone;
    if (idle > MascotRules.idleBeforeOffer && !_offering) {
      _offering = true;
      return MascotNudge.offer;
    }
    if (!_offering && idle > MascotRules.idleBeforeAttention) {
      return MascotNudge.attention;
    }
    return MascotNudge.none;
  }

  /// Whether this tap opens the game.
  ///
  /// Read off the clock rather than off [offering], which the tick has to set
  /// first. Ten seconds of being left alone is the whole rule; whether a timer
  /// happened to run in between is not something anybody did, and hanging the
  /// answer on it made the game late by up to a tick — or, when something else
  /// cleared the flag, unreachable.
  bool tapAccepts() {
    final accepted = alone > MascotRules.idleBeforeOffer;
    touched();
    return accepted;
  }
}
