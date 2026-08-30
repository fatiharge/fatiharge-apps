import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/mascot/application/mascot_attention.dart';
import 'package:motto/features/mascot/application/mascot_controller.dart';

void main() {
  late DateTime now;
  late MascotAttention attention;

  setUp(() {
    now = DateTime(2026, 8, 28, 12);
    attention = MascotAttention(clock: () => now);
  });

  void wait(Duration by) => now = now.add(by);

  test('fresh, it wants nothing', () {
    expect(attention.nudge(), MascotNudge.none);
  });

  test('left a moment, it asks to be noticed', () {
    wait(MascotRules.idleBeforeAttention + const Duration(seconds: 1));
    expect(attention.nudge(), MascotNudge.attention);
  });

  test('left longer, it offers the game once', () {
    wait(MascotRules.idleBeforeOffer + const Duration(seconds: 1));

    expect(attention.nudge(), MascotNudge.offer);
    // The offer stands; it does not keep re-offering on every tick, and it
    // does not fall back to asking for attention either — that would take the
    // question mark down and make the game unreachable again.
    expect(attention.nudge(), MascotNudge.none);
    expect(attention.offering, isTrue);
  });

  test('a tap while it is offering opens the game', () {
    wait(MascotRules.idleBeforeOffer + const Duration(seconds: 1));
    attention.nudge();

    expect(attention.tapAccepts(), isTrue);
    expect(attention.offering, isFalse);
  });

  test('a tap opens the game whether or not a tick has run', () {
    wait(MascotRules.idleBeforeOffer + const Duration(seconds: 1));

    // No nudge() first. The rule is ten seconds of being left alone, and a
    // timer having run in between is not something anybody did.
    expect(attention.tapAccepts(), isTrue);
  });

  test('a tap before the offer is only a poke', () {
    expect(attention.tapAccepts(), isFalse);
  });

  test('being touched takes the offer away', () {
    wait(MascotRules.idleBeforeOffer + const Duration(seconds: 1));
    attention
      ..nudge()
      ..touched();

    expect(attention.offering, isFalse);
    expect(attention.tapAccepts(), isFalse);
  });

  test('the offer comes back after being left alone again', () {
    attention.touched();
    wait(MascotRules.idleBeforeOffer + const Duration(seconds: 1));

    expect(attention.nudge(), MascotNudge.offer);
  });
}
