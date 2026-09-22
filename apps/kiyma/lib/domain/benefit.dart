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
class Benefit {
  const Benefit(this.anahtar, this.args);

  /// One more of whatever there are already.
  Benefit.adet(int simdi) : anahtar = 'adet', args = ['$simdi', '${simdi + 1}'];

  Benefit.yuzde(this.anahtar, double pay) : args = ['${(pay * 100).round()}'];

  /// Names `fayda.<anahtar>` in the translations.
  final String anahtar;
  final List<String> args;

  static Benefit? of(Unlock unlock, int day, Unlocks unlocks) {
    // One more thing that can go in a wrap or on a plate, at today's rate.
    // Checked by id rather than by group because the plate line's own rung
    // sits in the same ladder as its components and is worth something else.
    if (unlock.id.startsWith('malzeme_') || unlock.id.startsWith('bilesen_')) {
      return Benefit.yuzde(
        'malzeme',
        Balance.ingredientBonus / Balance.durumBase,
      );
    }

    return switch (unlock.grup) {
      UnlockGroup.porsiyon || UnlockGroup.icecek
          when unlock.id.endsWith('_hatti') =>
        const Benefit('hat', []),
      UnlockGroup.icecek => Benefit.yuzde(
        'icecek',
        Balance.icecekBase.values.first / Balance.durumBase,
      ),
      UnlockGroup.tatli => Benefit.yuzde(
        'tatli',
        Balance.tatliBase.values.first / Balance.durumBase,
      ),

      UnlockGroup.mangal => Benefit.adet(unlocks.mangalSlots),
      UnlockGroup.musteri => Benefit.adet(unlocks.musteriSlots),
      UnlockGroup.bekleme => Benefit.adet(unlocks.bekleme),
      UnlockGroup.bardak => Benefit.adet(unlocks.bardakGozu),
      UnlockGroup.bicak => Benefit('bicak', [
        '${unlocks.tutamAdedi}',
        '${Balance.tutam(unlocks.kademe(UnlockGroup.bicak) + 1)}',
      ]),

      UnlockGroup.kasap => Benefit.yuzde('kasap', Balance.kasapPayi),
      UnlockGroup.komur => Benefit.yuzde('komur', 1 - Balance.komurHizi),
      UnlockGroup.cirak => Benefit.yuzde('cirak', 1 - Balance.cirakSizma),
      UnlockGroup.tabela => Benefit.yuzde('tabela', 1 - Balance.tabelaCarpani),
      UnlockGroup.ayranSurahisi || UnlockGroup.salgamSurahisi => Benefit.yuzde(
        'surahi',
        1 - Balance.surahiHizi,
      ),

      UnlockGroup.ikram => Benefit('ikram', ['${Balance.ikramSaniye.round()}']),
      UnlockGroup.kasa => Benefit('kasa', ['${Balance.kasaSaniye.round()}']),
      UnlockGroup.malzeme || UnlockGroup.porsiyon => null,
    };
  }
}
