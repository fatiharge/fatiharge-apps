import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/trade_shape.dart';

void main() {
  test('a day has a shape, and day one has none', () {
    expect(TradeShape.forDay(1), TradeShape.duz);
    // Every other day is one of the shaped ones, and the same day always
    // gets the same shape — the card names it before the run starts.
    for (var day = 2; day < 20; day++) {
      expect(TradeShape.dongu, contains(TradeShape.forDay(day)));
      expect(TradeShape.forDay(day), TradeShape.forDay(day));
    }
  });

  test('two sittings is two rushes with a lull between them', () {
    const profil = TradeShape.ciftServis;
    expect(profil.yogunlukAt(0.05), Busyness.sakin);
    expect(profil.yogunlukAt(0.30), Busyness.yogun);
    expect(profil.yogunlukAt(0.50), Busyness.ortalama);
    expect(profil.yogunlukAt(0.65), Busyness.sakin);
    expect(profil.yogunlukAt(0.80), Busyness.yogun);
  });

  test('a rush is busier than the base and a lull is quieter', () {
    expect(Busyness.yogun.aralikCarpani, lessThan(1));
    expect(Busyness.sakin.aralikCarpani, greaterThan(1));
    expect(
      Busyness.ortalama.aralikCarpani,
      inExclusiveRange(
        Busyness.yogun.aralikCarpani,
        Busyness.sakin.aralikCarpani,
      ),
    );
  });

  test('the doors shut before the buzzer', () {
    expect(Balance.sonSiparis, lessThan(1));
    expect(Balance.sonSiparis, greaterThan(0.75));
  });
}
