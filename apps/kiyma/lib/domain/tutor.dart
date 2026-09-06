import 'package:kiyma/domain/progress.dart';

/// Something the counter did that a lesson might be waiting for.
///
/// The teacher watches for these rather than reading the run: a step that
/// polls `durumIstasyonu?.sarili` has to know what a wrap is, and then every
/// lesson is coupled to every rule. A milestone is the run saying "this
/// happened", once, and the lesson only has to recognise the name.
enum Milestone {
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
class LessonStep {
  const LessonStep(
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
  final Milestone? bekler;

  /// Whether somebody has to be standing at the counter for this to be
  /// possible. The run seats one rather than waiting for the door.
  final bool musteri;

  /// What that person asks for. The lesson has just walked somebody through
  /// building one particular thing; handing it over and being refused would
  /// teach the opposite of what the step is for.
  final Set<String> ister;
}

/// A lesson: what is taught, when it is owed, and in what order.
class Lesson {
  const Lesson(this.id, this.adimlar, {this.gun, this.kilit});

  final String id;
  final List<LessonStep> adimlar;

  /// Owed on this day or later.
  final int? gun;

  /// Owed once this is bought. Nothing is explained before it exists.
  final String? kilit;

  /// The first run. Everything the counter is for, in the order a wrap is
  /// built — which is also the order somebody would be shown it.
  static const ilkGun = Lesson('ilk_gun', [
    LessonStep('lavas', hedef: 'lavas_kaynak', bekler: Milestone.durumBasladi),
    LessonStep(
      'kiyma',
      hedef: 'malzeme_kiyma',
      bekler: Milestone.kiymaMangalda,
    ),
    LessonStep('bekle', hedef: 'mangal_alani', bekler: Milestone.etPisti),
    LessonStep('eti_al', hedef: 'mangal_alani', bekler: Milestone.etDurumda),
    LessonStep(
      'malzeme',
      hedef: 'malzeme_domates',
      bekler: Milestone.malzemeTam,
    ),
    LessonStep('sar', hedef: 'durum_hazirlama', bekler: Milestone.durumSarildi),
    LessonStep(
      'kagit',
      hedef: 'kagit_kaynak',
      bekler: Milestone.durumKagitlandi,
    ),
    LessonStep(
      'ver',
      hedef: 'musteri_slot_1',
      bekler: Milestone.servisEdildi,
      musteri: true,
      ister: {'domates'},
    ),
    LessonStep('altin', hedef: 'altin_alani', bekler: Milestone.altinToplandi),
    LessonStep('bitti'),
  ], gun: 1);

  /// The two things on the wall that nobody would guess.
  static const olculer = Lesson('olculer', [
    LessonStep('tempo'),
    LessonStep('saat'),
  ], gun: 2);

  static const gidis = Lesson('gidis', [LessonStep('gidis')], gun: 3);

  static const porsiyon = Lesson('porsiyon', [
    LessonStep('tabak', hedef: 'tabak_kaynak', bekler: Milestone.tabakBasladi),
    LessonStep('lavas', hedef: 'lavas_kaynak', bekler: Milestone.tabagaLavas),
    LessonStep('et', hedef: 'mangal_alani', bekler: Milestone.tabagaEt),
    LessonStep('bitti'),
  ], kilit: 'porsiyon_hatti');

  static const icecek = Lesson('icecek', [
    LessonStep(
      'bardak',
      hedef: 'bardak_kaynak',
      bekler: Milestone.bardakAlindi,
    ),
    LessonStep('dok', hedef: 'surahi_ayran', bekler: Milestone.bardakDoldu),
    LessonStep('bitti'),
  ], kilit: 'icecek_hatti');

  /// The first lesson that is owed and has not been heard.
  static Lesson? bekleyen(Progress progress) {
    for (final ders in katalog) {
      if (progress.gordu(ders.id)) continue;
      if (ders.gun != null && progress.gun < ders.gun!) continue;
      if (ders.kilit != null && !progress.unlocks.has(ders.kilit!)) continue;
      return ders;
    }
    return null;
  }

  static const List<Lesson> katalog = [
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
class Tutor {
  Tutor(this.ders);

  final Lesson ders;

  int _sira = 0;

  int get sira => _sira;

  int get toplam => ders.adimlar.length;

  LessonStep? get adim =>
      _sira < ders.adimlar.length ? ders.adimlar[_sira] : null;

  bool get bitti => adim == null;

  /// A step with nothing to do is waiting on a touch, not on the counter.
  bool get dokunusBekliyor => adim != null && adim!.bekler == null;

  void ulasildi(Milestone kilometre) {
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
