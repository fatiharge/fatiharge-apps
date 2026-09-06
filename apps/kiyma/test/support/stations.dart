import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/products.dart';

/// A wrap with every ingredient fully on it.
///
/// An ingredient is [Balance.tutamAdedi] handfuls, so "loaded" is a loop
/// rather than a set literal, and two tests plus the goldens all wanted the
/// same loop.
Wrap fullWrap() {
  final durum = Wrap()..etli = true;
  for (final malzeme in Ingredient.values) {
    for (var i = 0; i < Balance.tutamAdedi; i++) {
      durum.malzemeEkle(malzeme);
    }
  }
  return durum;
}

Plate fullPlate() {
  final porsiyon = Plate()
    ..lavasli = true
    ..etli = true;
  for (final bilesen in PlateItem.values) {
    for (var i = 0; i < Balance.tutamAdedi; i++) {
      porsiyon.bilesenEkle(bilesen);
    }
  }
  return porsiyon;
}
