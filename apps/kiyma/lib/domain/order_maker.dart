import 'dart:math' as math;

import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/unlocks.dart';

/// Builds the orders a day is made of.
///
/// The only hard rule is that nothing locked is ever asked for — a customer
/// who wants something the counter cannot make is a bug the player reads as
/// unfairness. Everything else scales with how much is open, so day one asks
/// for a wrap with one constraint and a late day asks for three.
class OrderMaker {
  OrderMaker(this.unlocks, {math.Random? random})
    : _random = random ?? math.Random();

  final Unlocks unlocks;
  final math.Random _random;

  Order make() {
    final porsiyon = unlocks.porsiyonHatti && _random.nextBool();
    final tip = porsiyon ? UrunTipi.porsiyon : UrunTipi.durum;

    final pool =
        (porsiyon
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

    return Order(
      tip: tip,
      ister: ister,
      istemez: istemez,
      tatli: _pick(unlocks.tatlilar, 0.35),
      icecek: _pick(unlocks.icecekler, 0.4),
    );
  }

  T? _pick<T>(Set<T> from, double chance) {
    if (from.isEmpty || _random.nextDouble() > chance) return null;
    return from.elementAt(_random.nextInt(from.length));
  }
}
