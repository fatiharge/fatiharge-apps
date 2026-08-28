import 'package:utility_kit/src/base/effect_listener.dart';

/// Anything that emits one-shot side effects.
///
/// The one thing [EffectListener] needs to know, so it works with a bloc, a
/// cubit, or a fake in a test — and so the two channels below can differ in
/// how they buffer without the presentation layer caring.
abstract interface class EffectSource<Effect> {
  /// One-shot side effects: navigate, open a sheet, show a snackbar.
  Stream<Effect> get effects;
}
