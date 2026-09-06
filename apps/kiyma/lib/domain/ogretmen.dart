import 'package:kiyma/domain/progress.dart';

/// Something the counter did that a lesson might be waiting for.
///
/// The teacher watches for these rather than reading the run: a step that
/// polls `durumIstasyonu?.sarili` has to know what a wrap is, and then every
/// lesson is coupled to every rule. A milestone is the run saying "this
/// happened", once, and the lesson only has to recognise the name.
enum Kilometre {
  durumBasladi,
  kiymaMangalda,
  etPisti,
  etDurumda,
  malzemeTam,
  durumSarildi,
  durumKagitlandi,
  servisEdildi,
  altinToplandi,
  tabakBasladi,
  tabagaLavas,
  tabagaEt,
  bardakAlindi,
  bardakDoldu,
}

/// One thing the usta asks for.
class Adim {
  const Adim(
    this.id, {
    this.hedef,
    this.bekler,
    this.musteri = false,
    this.ister = const {},
  });

  /// Names the line: `ders.<lesson>.<id>`.
  final String id;

  /// The region to point at while this step is up, if any.
  final String? hedef;

  /// What the counter has to do. Null means there is nothing to do — the
  /// step is the usta talking, and a touch moves it on.
  final Kilometre? bekler;

  /// Whether somebody has to be standing at the counter for this to be
  /// possible. The run seats one rather than waiting for the door.
  final bool musteri;

  /// What that person asks for. The lesson has just walked somebody through
  /// building one particular thing; handing it over and being refused would
  /// teach the opposite of what the step is for.
  final Set<String> ister;
}

/// A lesson: what is taught, when it is owed, and in what order.
class Ders {
  const Ders(this.id, this.adimlar, {this.gun, this.kilit});

  final String id;
  final List<Adim> adimlar;

  /// Owed on this day or later.
  final int? gun;

  /// Owed once this is bought. Nothing is explained before it exists.
  final String? kilit;

  /// The first run. Everything the counter is for, in the order a wrap is
  /// built — which is also the order somebody would be shown it.
  static const ilkGun = Ders('ilk_gun', [
    Adim('lavas', hedef: 'lavas_kaynak', bekler: Kilometre.durumBasladi),
    Adim('kiyma', hedef: 'malzeme_kiyma', bekler: Kilometre.kiymaMangalda),
    Adim('bekle', hedef: 'mangal_alani', bekler: Kilometre.etPisti),
    Adim('eti_al', hedef: 'mangal_alani', bekler: Kilometre.etDurumda),
    Adim('malzeme', hedef: 'malzeme_domates', bekler: Kilometre.malzemeTam),
    Adim('sar', hedef: 'durum_hazirlama', bekler: Kilometre.durumSarildi),
    Adim('kagit', hedef: 'kagit_kaynak', bekler: Kilometre.durumKagitlandi),
    Adim(
      'ver',
      hedef: 'musteri_slot_1',
      bekler: Kilometre.servisEdildi,
      musteri: true,
      ister: {'domates'},
    ),
    Adim('altin', hedef: 'altin_alani', bekler: Kilometre.altinToplandi),
    Adim('bitti'),
  ], gun: 1);

  /// The two things on the wall that nobody would guess.
  static const olculer = Ders('olculer', [
    Adim('tempo'),
    Adim('saat'),
  ], gun: 2);

  static const gidis = Ders('gidis', [Adim('gidis')], gun: 3);

  static const porsiyon = Ders('porsiyon', [
    Adim('tabak', hedef: 'tabak_kaynak', bekler: Kilometre.tabakBasladi),
    Adim('lavas', hedef: 'lavas_kaynak', bekler: Kilometre.tabagaLavas),
    Adim('et', hedef: 'mangal_alani', bekler: Kilometre.tabagaEt),
    Adim('bitti'),
  ], kilit: 'porsiyon_hatti');

  static const icecek = Ders('icecek', [
    Adim('bardak', hedef: 'bardak_kaynak', bekler: Kilometre.bardakAlindi),
    Adim('dok', hedef: 'surahi_ayran', bekler: Kilometre.bardakDoldu),
    Adim('bitti'),
  ], kilit: 'icecek_hatti');

  /// The first lesson that is owed and has not been heard.
  static Ders? bekleyen(Progress progress) {
    for (final ders in katalog) {
      if (progress.gordu(ders.id)) continue;
      if (ders.gun != null && progress.gun < ders.gun!) continue;
      if (ders.kilit != null && !progress.unlocks.has(ders.kilit!)) continue;
      return ders;
    }
    return null;
  }

  static const List<Ders> katalog = [
    ilkGun,
    olculer,
    gidis,
    porsiyon,
    icecek,
  ];
}

/// A lesson in progress.
///
/// It is deliberately dumb: it knows which step it is on and what would end
/// it. Nothing about the counter, nothing about drawing — a whole lesson can
/// be played through in a test by naming milestones.
class Ogretmen {
  Ogretmen(this.ders);

  final Ders ders;

  int _sira = 0;

  int get sira => _sira;

  int get toplam => ders.adimlar.length;

  Adim? get adim => _sira < ders.adimlar.length ? ders.adimlar[_sira] : null;

  bool get bitti => adim == null;

  /// A step with nothing to do is waiting on a touch, not on the counter.
  bool get dokunusBekliyor => adim != null && adim!.bekler == null;

  void ulasildi(Kilometre kilometre) {
    if (adim?.bekler == kilometre) _sira++;
  }

  /// Moves past a step the usta was only talking through.
  void ilerlet() {
    if (dokunusBekliyor) _sira++;
  }

  /// Every lesson can be walked out of. A player who does not want to be
  /// taught should have to say so once.
  void atla() => _sira = ders.adimlar.length;
}
