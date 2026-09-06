import 'dart:math' as math;

import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/musteri_tipi.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/unlocks.dart';

/// Builds the orders a day is made of.
///
/// The only hard rule is that nothing locked is ever asked for — a customer
/// who wants something the counter cannot make is a bug the player reads as
/// unfairness. Everything else scales with how much is open, so day one asks
/// for a wrap with one constraint and a late day asks for three.
class OrderMaker {
  OrderMaker(this.unlocks, {required this.day, math.Random? random})
    : _random = random ?? math.Random();

  final Unlocks unlocks;

  /// Which kinds of customer are possible yet.
  final int day;

  final math.Random _random;

  Order make() {
    final tipi = _tip();
    final ana = _urun(
      enAzIstemez: tipi == MusteriTipi.titiz ? Balance.titizIstemez : 0,
    );
    return Order(
      tip: ana.tip,
      ister: ana.ister,
      istemez: ana.istemez,
      tatli: _pick(unlocks.tatlilar, 0.35),
      icecek: _pick(unlocks.icecekler, 0.4),
      musteriTipi: tipi,
      // The other line where there is one: two wraps is the same job twice,
      // where a wrap and a plate is two jobs — which is the whole point of
      // a big order.
      ikinci: tipi == MusteriTipi.kalabalik
          ? _urun(
              zorla: ana.tip == UrunTipi.durum
                  ? UrunTipi.porsiyon
                  : UrunTipi.durum,
            )
          : null,
    );
  }

  /// Weighted among whatever is possible today. Nothing special turns up
  /// before its day, and the ordinary customer outweighs all of them
  /// together — the specials read as special only because most people
  /// are not one.
  MusteriTipi _tip() {
    final acik = [
      for (final tip in MusteriTipi.values)
        if (day >= tip.gun && (tip.kilit == null || unlocks.has(tip.kilit!)))
          tip,
    ];
    var pick = _random.nextInt(
      acik.fold(0, (sum, tip) => sum + tip.agirlik),
    );
    for (final tip in acik) {
      pick -= tip.agirlik;
      if (pick < 0) return tip;
    }
    return MusteriTipi.siradan;
  }

  /// One product's worth of asks. [zorla] pins the line; [enAzIstemez] is
  /// the floor on forbidden ingredients, which is what makes a fussy
  /// customer fussy.
  Order _urun({UrunTipi? zorla, int enAzIstemez = 0}) {
    final porsiyon =
        zorla == UrunTipi.porsiyon ||
        (zorla == null && unlocks.porsiyonHatti && _random.nextBool());
    // Asking for a plate before the plate line is open is the one thing that
    // is never allowed, whatever was pinned.
    final tip = porsiyon && unlocks.porsiyonHatti
        ? UrunTipi.porsiyon
        : UrunTipi.durum;

    final pool =
        (tip == UrunTipi.porsiyon
                ? unlocks.bilesenler.map((b) => b.id)
                : unlocks.malzemeler.map((m) => m.id))
            .toList()
          ..shuffle(_random);

    // One constraint while two things are open, three once the counter is
    // full. Half the pool, because an order asking for everything open is
    // not a choice.
    final limit = math.min(3, math.max(1, pool.length ~/ 2));
    final count = pool.isEmpty ? 0 : 1 + _random.nextInt(limit);

    final ister = <String>{};
    final istemez = <String>{};
    for (final id in pool.take(count)) {
      // Never all-negative: an order with nothing to put in reads as empty.
      if (ister.isEmpty || _random.nextDouble() < 0.65) {
        ister.add(id);
      } else {
        istemez.add(id);
      }
    }
    // A fussy customer names more than the draw gave them, out of whatever
    // is left over — never out of what they asked for.
    for (final id in pool.skip(count)) {
      if (istemez.length >= enAzIstemez) break;
      istemez.add(id);
    }

    return Order(tip: tip, ister: ister, istemez: istemez);
  }

  T? _pick<T>(Set<T> from, double chance) {
    if (from.isEmpty || _random.nextDouble() > chance) return null;
    return from.elementAt(_random.nextInt(from.length));
  }
}
