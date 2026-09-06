import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/gun_profili.dart';

void main() {
  test('a day has a shape, and day one has none', () {
    expect(GunProfili.forDay(1), GunProfili.duz);
    // Every other day is one of the shaped ones, and the same day always
    // gets the same shape — the card names it before the run starts.
    for (var day = 2; day < 20; day++) {
      expect(GunProfili.dongu, contains(GunProfili.forDay(day)));
      expect(GunProfili.forDay(day), GunProfili.forDay(day));
    }
  });

  test('two sittings is two rushes with a lull between them', () {
    const profil = GunProfili.ciftServis;
    expect(profil.yogunlukAt(0.05), Yogunluk.sakin);
    expect(profil.yogunlukAt(0.30), Yogunluk.yogun);
    expect(profil.yogunlukAt(0.50), Yogunluk.ortalama);
    expect(profil.yogunlukAt(0.65), Yogunluk.sakin);
    expect(profil.yogunlukAt(0.80), Yogunluk.yogun);
  });

  test('a rush is busier than the base and a lull is quieter', () {
    expect(Yogunluk.yogun.aralikCarpani, lessThan(1));
    expect(Yogunluk.sakin.aralikCarpani, greaterThan(1));
    expect(
      Yogunluk.ortalama.aralikCarpani,
      inExclusiveRange(
        Yogunluk.yogun.aralikCarpani,
        Yogunluk.sakin.aralikCarpani,
      ),
    );
  });

  test('the doors shut before the buzzer', () {
    expect(Balance.sonSiparis, lessThan(1));
    expect(Balance.sonSiparis, greaterThan(0.75));
  });
}
