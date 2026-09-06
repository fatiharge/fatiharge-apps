import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/tanitim.dart';

void main() {
  test('day one is told what the counter is for', () {
    final progress = Progress();
    final bekleyen = Tanitim.bekleyenler(progress);
    expect(bekleyen, isNotEmpty);
    expect(bekleyen.first.id, 'hosgeldin');
  });

  test('nothing is said twice', () {
    final progress = Progress();
    final first = Tanitim.bekleyenler(progress);
    progress.gordum(first.map((tanitim) => tanitim.id));
    expect(Tanitim.bekleyenler(progress), isEmpty);
  });

  test('skipping one skips all of them', () {
    final progress = Progress()..gun = 3;
    final bekleyen = Tanitim.bekleyenler(progress);
    // Day three has more than one thing owed, so skipping has to mean all of
    // them: a player who said no once should not be asked again next screen.
    expect(bekleyen.length, greaterThan(1));
    progress.gordum(bekleyen.map((tanitim) => tanitim.id));
    expect(Tanitim.bekleyenler(progress), isEmpty);
  });

  test('a line about something that is not on the counter waits', () {
    final progress = Progress()..gun = 9;
    expect(
      Tanitim.bekleyenler(progress).map((tanitim) => tanitim.id),
      isNot(contains('porsiyon')),
    );

    progress.unlocks.open('porsiyon_hatti');
    expect(
      Tanitim.bekleyenler(progress).map((tanitim) => tanitim.id),
      contains('porsiyon'),
    );
  });

  test('every line in the catalogue has words behind it', () {
    // The ids name the translation keys, so a catalogue entry with no
    // strings shows an empty card rather than failing.
    for (final tanitim in Tanitim.katalog) {
      expect(tanitim.id, isNotEmpty);
      expect(tanitim.satir, greaterThan(0));
      expect(tanitim.gun != null || tanitim.kilit != null, isTrue);
    }
  });
}
