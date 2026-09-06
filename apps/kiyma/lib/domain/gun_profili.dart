/// How busy the counter is, as a multiple of the day's base arrival gap.
/// Below one is busier than the base, above it is quieter.
enum Yogunluk {
  sakin(1.9),
  ortalama(1.15),
  yogun(0.6);

  const Yogunluk(this.aralikCarpani);

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
class GunProfili {
  const GunProfili(this.ad, this.dilimler);

  /// The key the day card reads its name from.
  final String ad;

  /// Where each stretch begins, `0..1` through the day, in order.
  final List<(double, Yogunluk)> dilimler;

  Yogunluk yogunlukAt(double oran) {
    var out = dilimler.first.$2;
    for (final (baslangic, seviye) in dilimler) {
      if (oran >= baslangic) out = seviye;
    }
    return out;
  }

  /// Day one only. Nothing to read, nothing to plan around: the first run is
  /// for finding out where the bread is.
  static const duz = GunProfili('duz', [(0, Yogunluk.ortalama)]);

  static const oglePatlamasi = GunProfili('ogle', [
    (0, Yogunluk.sakin),
    (0.25, Yogunluk.yogun),
    (0.60, Yogunluk.ortalama),
  ]);

  /// Two rushes with a lull between them — the shape a kebab shop actually
  /// has, and the one that gives the middle of a run something to be.
  static const ciftServis = GunProfili('cift_servis', [
    (0, Yogunluk.sakin),
    (0.15, Yogunluk.yogun),
    (0.45, Yogunluk.ortalama),
    (0.60, Yogunluk.sakin),
    (0.70, Yogunluk.yogun),
  ]);

  static const aksamustu = GunProfili('aksamustu', [
    (0, Yogunluk.sakin),
    (0.35, Yogunluk.ortalama),
    (0.60, Yogunluk.yogun),
  ]);

  static const List<GunProfili> dongu = [
    oglePatlamasi,
    ciftServis,
    aksamustu,
  ];

  static GunProfili forDay(int day) =>
      day <= 1 ? duz : dongu[(day - 2) % dongu.length];
}
