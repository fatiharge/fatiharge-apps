import 'package:kiyma/domain/unlocks.dart';

/// Where each thing the shop sells actually stands in the kitchen.
///
/// The shop screen is the room, so a purchase is made by touching the object
/// it would change: the empty steel well that would hold pickles, the grill
/// that would get a third skewer, the jug that would pour faster. A player
/// who has to be told what "Ocak körüğü" does has been sold a word; one who
/// sees a price tag hanging off the coals has not.
///
/// Fourteen rungs have no object — a sharper knife, an apprentice, a sign
/// outside, tea for the queue, and the till, which is chalk on a slate this
/// screen does not draw. Those go to the list. Hanging their tags off the
/// nearest surface was tried and looked exactly like what it was: a price on
/// a thing that is not the thing. The shop is honest instead about which of
/// its goods you can point at.
abstract final class ShopMap {
  static const _yerler = <String, String>{
    // The grill carries two ladders: the slots across it and the coal in it.
    'mangal_3': 'mangal_alani',
    'mangal_4': 'mangal_alani',
    'komur_1': 'mangal_alani',
    'komur_2': 'mangal_alani',
    'komur_3': 'mangal_alani',
    'komur_4': 'mangal_alani',
    'komur_5': 'mangal_alani',

    // Each ingredient is bought at the empty well it would fill.
    'malzeme_biber': 'malzeme_biber',
    'malzeme_tursu': 'malzeme_tursu',
    'bilesen_icli_kofte': 'malzeme_icli_kofte',
    'bilesen_pilav': 'malzeme_pilav',
    'bilesen_patates': 'malzeme_patates',
    'bilesen_ezme': 'malzeme_ezme',

    // Better mince is bought at the mince tray.
    'kasap_1': 'malzeme_kiyma',
    'kasap_2': 'malzeme_kiyma',
    'kasap_3': 'malzeme_kiyma',

    'bekleme_2': 'bekleme_alani',
    'bekleme_3': 'bekleme_alani',

    'musteri_3': 'musteri_slot_3',

    // The plate line is bought at the stack of empty plates.
    'porsiyon_hatti': 'tabak_kaynak',

    'tatli_baklava': 'tatli_baklava',

    // The drinks line is bought at the glasses; each drink at its own jug.
    'icecek_hatti': 'bardak_kaynak',
    'icecek_salgam': 'surahi_salgam',
    'surahi_salgam_1': 'surahi_salgam',
    'surahi_salgam_2': 'surahi_salgam',
    'surahi_salgam_3': 'surahi_salgam',
    'icecek_ayran': 'surahi_ayran',
    'surahi_ayran_1': 'surahi_ayran',
    'surahi_ayran_2': 'surahi_ayran',
    'surahi_ayran_3': 'surahi_ayran',
    'icecek_kola': 'kola_kaynak',
    'bardak_2': 'bardak_bekletme',
    'bardak_3': 'bardak_bekletme',
  };

  /// The object [id] is bought at, or null where there is none.
  static String? yeri(String id) => _yerler[id];

  /// Every region the shop puts a tag on, in scene order.
  static Set<String> get bolgeler => _yerler.values.toSet();

  /// The rungs sold at [bolge] that are next in their own ladder — at most
  /// one per group, because a ladder only ever offers its next rung.
  static List<Unlock> satilan(String bolge, Unlocks unlocks) => [
    for (final unlock in unlocks.forSale)
      if (_yerler[unlock.id] == bolge) unlock,
  ];

  /// Everything with nowhere to stand. The list screen's whole contents.
  static List<Unlock> yersiz(Unlocks unlocks) => [
    for (final unlock in unlocks.forSale)
      if (!_yerler.containsKey(unlock.id)) unlock,
  ];

  /// The ladders a region carries, whether or not they still have rungs for
  /// sale — the card shows a finished ladder as finished rather than not at
  /// all.
  static List<Grup> gruplar(String bolge) {
    final out = <Grup>[];
    for (final unlock in Unlocks.catalogue) {
      if (_yerler[unlock.id] != bolge) continue;
      if (!out.contains(unlock.grup)) out.add(unlock.grup);
    }
    return out;
  }
}
