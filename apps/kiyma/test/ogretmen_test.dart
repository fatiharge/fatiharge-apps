import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/ogretmen.dart';
import 'package:kiyma/domain/progress.dart';

void main() {
  test('the first run is the one that gets taught', () {
    expect(Ders.bekleyen(Progress())?.id, Ders.ilkGun.id);
  });

  test('nothing is taught twice', () {
    final progress = Progress()..gordum([Ders.ilkGun.id]);
    expect(Ders.bekleyen(progress)?.id, isNot(Ders.ilkGun.id));
  });

  test('a line about something not on the counter waits for it', () {
    final progress = Progress()
      ..gun = 9
      ..gordum([Ders.ilkGun.id, Ders.olculer.id, Ders.gidis.id]);
    expect(Ders.bekleyen(progress), isNull);

    progress.unlocks.open('porsiyon_hatti');
    expect(Ders.bekleyen(progress)?.id, Ders.porsiyon.id);
  });

  test('a lesson walks forward on the milestones it named', () {
    final ogretmen = Ogretmen(Ders.ilkGun);
    expect(ogretmen.adim!.id, 'lavas');

    // A milestone the step is not waiting for changes nothing: the counter
    // is allowed to do things in another order, it just is not taught yet.
    ogretmen.ulasildi(Kilometre.servisEdildi);
    expect(ogretmen.adim!.id, 'lavas');

    ogretmen.ulasildi(Kilometre.durumBasladi);
    expect(ogretmen.adim!.id, 'kiyma');
  });

  test('a step with nothing to do waits for a touch instead', () {
    final ogretmen = Ogretmen(Ders.olculer);
    expect(ogretmen.dokunusBekliyor, isTrue);
    ogretmen.ilerlet();
    expect(ogretmen.adim!.id, 'saat');
  });

  test('every lesson can be walked out of, from anywhere in it', () {
    for (final ders in Ders.katalog) {
      final ogretmen = Ogretmen(ders)..atla();
      expect(ogretmen.bitti, isTrue, reason: ders.id);
    }
  });

  test('every step names a line, and every target is a real region', () {
    for (final ders in Ders.katalog) {
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
