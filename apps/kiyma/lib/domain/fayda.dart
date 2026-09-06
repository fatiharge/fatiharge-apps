import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/unlocks.dart';

/// What a rung is worth, as a number the player can weigh against a price.
///
/// The sentence beside a rung says what it does; this says how much, and it
/// is worked out against the day the player is on — an ingredient is worth
/// what it is worth *now*, not what it was worth on day one. A shop that
/// says "better mince" and charges 190 is asking to be trusted; one that
/// says "the main product is worth 20% more" is asking to be judged, which
/// is what a price is for.
///
/// The number never travels alone. "%7" on its own means nothing, so each
/// group names its own sentence and the number goes inside it.
class Fayda {
  const Fayda(this.anahtar, this.args);

  /// One more of whatever there are already.
  Fayda.adet(int simdi) : anahtar = 'adet', args = ['$simdi', '${simdi + 1}'];

  Fayda.yuzde(this.anahtar, double pay) : args = ['${(pay * 100).round()}'];

  /// Names `fayda.<anahtar>` in the translations.
  final String anahtar;
  final List<String> args;

  static Fayda? of(Unlock unlock, int day, Unlocks unlocks) {
    // One more thing that can go in a wrap or on a plate, at today's rate.
    // Checked by id rather than by group because the plate line's own rung
    // sits in the same ladder as its components and is worth something else.
    if (unlock.id.startsWith('malzeme_') || unlock.id.startsWith('bilesen_')) {
      return Fayda('malzeme', ['${Balance.income(0, day, ingredients: 1)}']);
    }

    return switch (unlock.grup) {
      Grup.porsiyon ||
      Grup.icecek when unlock.id.endsWith('_hatti') => const Fayda('hat', []),
      Grup.icecek => Fayda('icecek', [
        '${Balance.income(Balance.icecekBase.values.first, day)}',
      ]),
      Grup.tatli => Fayda('tatli', [
        '${Balance.income(Balance.tatliBase.values.first, day)}',
      ]),

      Grup.mangal => Fayda.adet(unlocks.mangalSlots),
      Grup.musteri => Fayda.adet(unlocks.musteriSlots),
      Grup.bekleme => Fayda.adet(unlocks.bekleme),
      Grup.bardak => Fayda.adet(unlocks.bardakGozu),
      Grup.bicak => Fayda('bicak', [
        '${unlocks.tutamAdedi}',
        '${Balance.tutam(unlocks.kademe(Grup.bicak) + 1)}',
      ]),

      Grup.kasap => Fayda.yuzde('kasap', Balance.kasapPayi),
      Grup.komur => Fayda.yuzde('komur', 1 - Balance.komurHizi),
      Grup.cirak => Fayda.yuzde('cirak', 1 - Balance.cirakSizma),
      Grup.tabela => Fayda.yuzde('tabela', 1 - Balance.tabelaCarpani),
      Grup.ayranSurahisi ||
      Grup.salgamSurahisi => Fayda.yuzde('surahi', 1 - Balance.surahiHizi),

      Grup.ikram => Fayda('ikram', ['${Balance.ikramSaniye.round()}']),
      Grup.kasa => Fayda('kasa', ['${Balance.kasaSaniye.round()}']),
      Grup.malzeme || Grup.porsiyon => null,
    };
  }
}
