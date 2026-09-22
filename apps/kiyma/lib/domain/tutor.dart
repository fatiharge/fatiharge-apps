import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/shop_map.dart';
import 'package:kiyma/domain/unlocks.dart';

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
    this.metin,
  });

  /// Names the line: `ders.<lesson>.<id>`.
  final String id;

  /// A line of its own, where the step is generated rather than written.
  /// A purchase already has a sentence saying what it does; the usta reads
  /// that one rather than a second copy of it kept in step form.
  final String? metin;

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
  const Lesson(this.id, this.adimlar, {this.gun, this.kilit, this.isaretler});

  final String id;
  final List<LessonStep> adimlar;

  /// Owed on this day or later.
  final int? gun;

  /// Owed once this is bought. Nothing is explained before it exists.
  final String? kilit;

  /// What to write down as heard when this ends. A generated lesson marks
  /// each purchase it covered, so buying two things and skipping the first
  /// line does not silently swallow the second.
  final List<String>? isaretler;

  List<String> get gorulenler => isaretler ?? [id];

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

  /// Pouring, taught at whichever jug the player actually owns.
  ///
  /// It used to be a const gated on `icecek_hatti` and pointed at
  /// `surahi_ayran`, and that was a soft lock with nothing behind it. The
  /// line is thirty gold and the cheapest drink is four hundred and seventy,
  /// so the ordinary path is to buy the line alone — and with no drink, no
  /// jug is shown, no jug can be touched, and `bardakDoldu` cannot be
  /// reached. A lesson stops the clock, so the day never ended either; the
  /// run could only be left by skipping, which spends the lesson forever, and
  /// no run could be finished to earn the four hundred and seventy that
  /// would have fixed it.
  ///
  /// So it is owed by the jug rather than by the line, and it points at that
  /// jug. A player who has only bought bottled cola is never shown it, which
  /// is right: there is nothing to pour.
  static Lesson? icecekDersi(Unlocks unlocks) {
    Drink? surahi;
    for (final icecek in Drink.values) {
      if (icecek.poured && unlocks.icecekler.contains(icecek)) {
        surahi = icecek;
        break;
      }
    }
    if (surahi == null) return null;
    return Lesson('icecek', [
      const LessonStep(
        'bardak',
        hedef: 'bardak_kaynak',
        bekler: Milestone.bardakAlindi,
      ),
      LessonStep(
        'dok',
        hedef: surahi.sourceRegion,
        bekler: Milestone.bardakDoldu,
      ),
      const LessonStep('bitti'),
    ]);
  }

  /// One line for each thing bought since it was last explained.
  ///
  /// Generated rather than written: there are forty-seven rungs and each one
  /// already carries the sentence that says what it does. Anything with a
  /// lesson of its own is left to that lesson, which teaches the mechanic
  /// rather than describing it.
  static Lesson? alimlar(Progress progress) {
    final dersli = {
      for (final ders in katalog)
        if (ders.kilit != null) ders.kilit,
      // The drinks lesson is generated rather than listed, so its rung has
      // to be named here or the line would be explained twice: once as a
      // purchase and once as a lesson.
      'icecek_hatti',
    };
    final yeni = [
      for (final unlock in Unlocks.catalogue)
        if (progress.unlocks.has(unlock.id) &&
            !dersli.contains(unlock.id) &&
            !progress.gordu('alim_${unlock.id}'))
          unlock,
    ];
    if (yeni.isEmpty) return null;
    return Lesson(
      'alim',
      [
        for (final unlock in yeni)
          LessonStep(
            unlock.id,
            hedef: ShopMap.yeri(unlock.id),
            metin: 'kilit.${unlock.id}_ne',
          ),
      ],
      isaretler: [for (final unlock in yeni) 'alim_${unlock.id}'],
    );
  }

  /// The first lesson that is owed and has not been heard.
  static Lesson? bekleyen(Progress progress) {
    for (final ders in katalog) {
      if (progress.gordu(ders.id)) continue;
      if (ders.gun != null && progress.gun < ders.gun!) continue;
      if (ders.kilit != null && !progress.unlocks.has(ders.kilit!)) continue;
      return ders;
    }
    // Built rather than listed, because what it points at depends on what
    // was bought. It goes last for the same reason the catalogue is ordered:
    // a written lesson is owed before a generated one.
    if (!progress.gordu('icecek')) {
      if (icecekDersi(progress.unlocks) case final ders?) return ders;
    }
    return null;
  }

  /// The written ones, in the order they are owed. The drinks lesson is not
  /// here: it is generated from the jug the player owns.
  static const List<Lesson> katalog = [ilkGun, olculer, gidis, porsiyon];
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
