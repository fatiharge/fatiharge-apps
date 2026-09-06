import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/tempo.dart';

/// One named thing that is different about today.
///
/// Every field is neutral by default and [yok] is the identity, so the rules
/// engine multiplies and adds unconditionally and never learns a single
/// rule's name. A rule that needed an `if` of its own would be the first of
/// five, and then the run would be a switch statement nobody can follow.
class DayRule {
  const DayRule(
    this.id, {
    this.odeme = 1,
    this.bagislanan = Tempo.bagislanan,
    this.mangalKesintisi = 0,
    this.pencereCarpani = 1,
    this.sadeDurum = false,
    this.ekMalzeme = 0,
    this.tatliSansi = Balance.tatliSansi,
    this.sabirCarpani = 1,
  });

  /// Names `kural.<id>` in the translations, and nothing else.
  final String id;

  /// What the main product is worth today.
  final double odeme;

  /// How many mis-drops in a row are free.
  final int bagislanan;

  /// Grill slots taken away, floored at [Balance.enAzMangal].
  final int mangalKesintisi;

  /// How much wider the cooked window is.
  final double pencereCarpani;

  /// Whether the plate line is closed for the day.
  final bool sadeDurum;

  /// Extra named ingredients per order.
  final int ekMalzeme;

  /// How often an order comes with a dessert.
  final double tatliSansi;

  /// How long everybody waits today, as a fraction of the usual.
  final double sabirCarpani;

  bool get adsiz => id == 'yok';

  static const yok = DayRule('yok');

  static const denetim = DayRule(
    'denetim',
    odeme: Balance.denetimOdemesi,
    bagislanan: Balance.denetimBagislanan,
  );

  static const komurAz = DayRule(
    'komur_az',
    mangalKesintisi: Balance.komurKesintisi,
    pencereCarpani: Balance.komurPenceresi,
  );

  static const durumGunu = DayRule(
    'durum_gunu',
    sadeDurum: true,
    odeme: Balance.durumGunuOdemesi,
  );

  static const titizGun = DayRule(
    'titiz_gun',
    ekMalzeme: Balance.titizEkMalzeme,
  );

  static const bayram = DayRule(
    'bayram',
    tatliSansi: Balance.bayramTatliSansi,
  );

  /// The whole queue is in a hurry. Nothing about the counter changes — the
  /// day is simply played at a different speed, and paid for at one.
  static const kosuGunu = DayRule(
    'kosu_gunu',
    sabirCarpani: Balance.kosuSabri,
    odeme: Balance.kosuOdemesi,
  );

  /// The other end of the same trade: time instead of money. Nobody hurries
  /// and the grill forgives, but the day pays less for it.
  static const sakinGun = DayRule(
    'sakin_gun',
    pencereCarpani: Balance.sakinPenceresi,
    sabirCarpani: Balance.sakinSabri,
    odeme: Balance.sakinOdemesi,
  );

  static const List<DayRule> dongu = [
    denetim,
    komurAz,
    kosuGunu,
    durumGunu,
    titizGun,
    sakinGun,
    bayram,
  ];

  /// Fixed per day rather than drawn, so the card can promise it.
  static DayRule forDay(int day) => day < Balance.ilkKuralGunu
      ? yok
      : dongu[(day - Balance.ilkKuralGunu) % dongu.length];
}
