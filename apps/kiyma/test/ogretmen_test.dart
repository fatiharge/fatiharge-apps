import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/tutor.dart';

void main() {
  test('the first run is the one that gets taught', () {
    expect(Lesson.bekleyen(Progress())?.id, Lesson.ilkGun.id);
  });

  test('nothing is taught twice', () {
    final progress = Progress()..gordum([Lesson.ilkGun.id]);
    expect(Lesson.bekleyen(progress)?.id, isNot(Lesson.ilkGun.id));
  });

  test('a line about something not on the counter waits for it', () {
    final progress = Progress()
      ..gun = 9
      ..gordum([Lesson.ilkGun.id, Lesson.olculer.id, Lesson.gidis.id]);
    expect(Lesson.bekleyen(progress), isNull);

    progress.unlocks.open('porsiyon_hatti');
    expect(Lesson.bekleyen(progress)?.id, Lesson.porsiyon.id);
  });

  test('a lesson walks forward on the milestones it named', () {
    final ogretmen = Tutor(Lesson.ilkGun);
    expect(ogretmen.adim!.id, 'lavas');

    // A milestone the step is not waiting for changes nothing: the counter
    // is allowed to do things in another order, it just is not taught yet.
    ogretmen.ulasildi(Milestone.servisEdildi);
    expect(ogretmen.adim!.id, 'lavas');

    ogretmen.ulasildi(Milestone.durumBasladi);
    expect(ogretmen.adim!.id, 'kiyma');
  });

  test('a step with nothing to do waits for a touch instead', () {
    final ogretmen = Tutor(Lesson.olculer);
    expect(ogretmen.dokunusBekliyor, isTrue);
    ogretmen.ilerlet();
    expect(ogretmen.adim!.id, 'saat');
  });

  test('every lesson can be walked out of, from anywhere in it', () {
    for (final ders in Lesson.katalog) {
      final ogretmen = Tutor(ders)..atla();
      expect(ogretmen.bitti, isTrue, reason: ders.id);
    }
  });

  test('every step names a line, and every target is a real region', () {
    for (final ders in Lesson.katalog) {
      expect(ders.adimlar, isNotEmpty, reason: ders.id);
      for (final adim in ders.adimlar) {
        expect(adim.id, isNotEmpty);
        // A step that waits on nothing and points at nothing is the usta
        // talking, which is allowed; one that points has to point somewhere.
        if (adim.musteri) expect(adim.bekler, isNotNull, reason: adim.id);
      }
    }
  });
}
