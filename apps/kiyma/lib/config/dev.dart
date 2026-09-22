import 'package:flutter/foundation.dart';

/// Switches that exist only so the game can be played through quickly.
///
/// Debug builds only, and asserted so: a release build reads [hiz] as 1 and
/// [acik] as false whatever anybody sets, because a time multiplier is the
/// one setting that would turn a shipped game into a broken one.
///
/// It is a plain static holder rather than a registered service. Nothing in
/// the rules may read it — it multiplies the clock the presentation layer
/// feeds `DayRun.tick`, so a run played at five times speed is the same run,
/// just watched faster.
abstract final class Dev {
  static bool get acik => kDebugMode;

  /// Steps rather than a slider: the point is to reach day ten, not to tune.
  static const hizlar = [1.0, 2.0, 5.0];

  static double _hiz = 1;

  static double get hiz => acik ? _hiz : 1;

  static set hiz(double value) {
    if (acik) _hiz = value;
  }

  static void sonrakiHiz() =>
      hiz = hizlar[(hizlar.indexOf(hiz) + 1) % hizlar.length];
}
