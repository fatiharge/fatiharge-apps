/// How busy the counter is, as a multiple of the day's base arrival gap.
/// Below one is busier than the base, above it is quieter.
enum Busyness {
  sakin(1.9),
  ortalama(1.15),
  yogun(0.6);

  const Busyness(this.aralikCarpani);

  final double aralikCarpani;
}

/// The shape of one day's trade.
///
/// A flat arrival rate is a metronome: the counter is either always ahead of
/// it or always behind, and nothing about the middle of a run is different
/// from its start. A shift has rushes and it has lulls, and the lull is the
/// part that matters — it is where a player catches up, and catching up is
/// what the rush was for.
///
/// The shape is fixed per day rather than random, so the day card can name it
/// and the player can walk in knowing what is coming.
class TradeShape {
  const TradeShape(this.ad, this.dilimler);

  /// The key the day card reads its name from.
  final String ad;

  /// Where each stretch begins, `0..1` through the day, in order.
  final List<(double, Busyness)> dilimler;

  Busyness yogunlukAt(double oran) {
    var out = dilimler.first.$2;
    for (final (baslangic, seviye) in dilimler) {
      if (oran >= baslangic) out = seviye;
    }
    return out;
  }

  /// Day one only. Nothing to read, nothing to plan around: the first run is
  /// for finding out where the bread is.
  static const duz = TradeShape('duz', [(0, Busyness.ortalama)]);

  static const oglePatlamasi = TradeShape('ogle', [
    (0, Busyness.sakin),
    (0.25, Busyness.yogun),
    (0.60, Busyness.ortalama),
  ]);

  /// Two rushes with a lull between them — the shape a kebab shop actually
  /// has, and the one that gives the middle of a run something to be.
  static const ciftServis = TradeShape('cift_servis', [
    (0, Busyness.sakin),
    (0.15, Busyness.yogun),
    (0.45, Busyness.ortalama),
    (0.60, Busyness.sakin),
    (0.70, Busyness.yogun),
  ]);

  static const aksamustu = TradeShape('aksamustu', [
    (0, Busyness.sakin),
    (0.35, Busyness.ortalama),
    (0.60, Busyness.yogun),
  ]);

  static const List<TradeShape> dongu = [
    oglePatlamasi,
    ciftServis,
    aksamustu,
  ];

  static TradeShape forDay(int day) =>
      day <= 1 ? duz : dongu[(day - 2) % dongu.length];
}
