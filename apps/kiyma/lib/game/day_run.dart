import 'dart:math' as math;
import 'dart:ui';

import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/model/carried.dart';
import 'package:kiyma/game/model/order.dart';
import 'package:kiyma/game/model/products.dart';
import 'package:kiyma/game/order_maker.dart';
import 'package:kiyma/game/progress.dart';

/// Something the day did that the screen should react to once.
enum DayEvent {
  kabul,
  reddedildi,
  gecersiz,
  yandi,
  musteriGeldi,
  musteriMemnun,
  musteriKizgin,
  gunBitti,
}

/// One day behind the counter: the mutable world, and every rule that moves
/// it.
///
/// Deliberately free of Flame and of Flutter widgets. The engine ticks it and
/// draws from it; nothing here knows about either, which is what makes the
/// rules testable without a canvas.
class DayRun {
  DayRun({
    required this.scene,
    required this.progress,
    required this.onEvent,
    required this.onChanged,
    math.Random? random,
  }) : day = progress.gun,
       _maker = OrderMaker(progress.unlocks, random: random) {
    final unlocks = progress.unlocks;
    mangal = [
      for (var i = 0; i < 4; i++) MangalSlot(unlocked: i < unlocks.mangalSlots),
    ];
    bekleme = List<Urun?>.filled(3, null);
    bardakBekletme = List<Bardak?>.filled(3, null);
    musteriler = List<Customer?>.filled(4, null);
    kalanSure = Balance.runLength(day).inSeconds.toDouble();
    _acilis = progress.xp;
  }

  final SceneData scene;
  final Progress progress;
  final int day;
  final void Function(DayEvent event) onEvent;

  /// Called whenever something the HUD shows moved. Patience and cooking are
  /// drawn on the canvas and deliberately do not go through here — a bloc
  /// emitting at frame rate is a bloc nobody can debug.
  final void Function() onChanged;

  final OrderMaker _maker;

  late final List<MangalSlot> mangal;

  /// One shelf for both lines. Wraps and plates share it.
  late final List<Urun?> bekleme;
  late final List<Bardak?> bardakBekletme;
  late final List<Customer?> musteriler;

  Durum? durumIstasyonu;
  Porsiyon? tabakIstasyonu;

  Carried? carried;
  Offset carriedAt = Offset.zero;

  /// Regions lit up by a touch, and how long they have left. Taking something
  /// off a tray is otherwise invisible until the thing is already under the
  /// finger, which reads as a dropped input.
  final Map<String, ({double left, bool ok})> parlama = {};

  static const _flashFor = 0.28;

  void _flash(String region, {bool ok = true}) =>
      parlama[region] = (left: _flashFor, ok: ok);

  double flashAt(String region) => (parlama[region]?.left ?? 0) / _flashFor;

  /// Seconds left on the counter. A run is a clock: customers keep arriving
  /// as seats free until it runs out.
  late double kalanSure;

  late final int _acilis;

  /// What this run has taken, as opposed to the running total.
  int get kazanc => progress.xp - _acilis;

  double get sureOrani =>
      (kalanSure / Balance.runLength(day).inSeconds).clamp(0, 1);
  double _sonrakiGelis = 0;
  bool bitti = false;

  /// Everything stops: the clock, the grill, the patience bars. The player
  /// asked for it, so it is not the free breather that stepping out of the
  /// counter would have been.
  bool duraklatildi = false;

  // --- Clock ---

  void tick(double dt) {
    if (bitti || duraklatildi) return;

    for (final slot in mangal) {
      if (slot.tick(dt, day)) {
        progress.cezalandir(Balance.burnPenalty(day).round());
        onEvent(DayEvent.yandi);
        onChanged();
      }
    }

    for (final bardak in bardakBekletme) {
      bardak?.tick(dt);
    }

    parlama
      ..updateAll((_, flash) => (left: flash.left - dt, ok: flash.ok))
      ..removeWhere((_, flash) => flash.left <= 0);

    for (var i = 0; i < musteriler.length; i++) {
      final customer = musteriler[i];
      if (customer == null) continue;
      customer.sabirKalan -= dt;
      if (customer.sabirKalan <= 0) {
        _ayril(i, memnun: false);
      }
    }

    _sonrakiGelis -= dt;
    if (_sonrakiGelis <= 0) {
      final free = _bosMusteriSlotu();
      if (free != null) {
        musteriler[free] = Customer(order: _maker.make(), day: day);
        _sonrakiGelis = Balance.arrivalGap;
        onEvent(DayEvent.musteriGeldi);
        onChanged();
      }
    }

    kalanSure -= dt;
    if (kalanSure <= 0) {
      kalanSure = 0;
      bitti = true;
      onEvent(DayEvent.gunBitti);
      onChanged();
    }
  }

  int? _bosMusteriSlotu() {
    for (var i = 0; i < progress.unlocks.musteriSlots; i++) {
      if (musteriler[i] == null) return i;
    }
    return null;
  }

  // --- Hit testing ---

  /// The region under [point], smallest first.
  ///
  /// The counter's own surface is a region too and it covers half the scene,
  /// so a first-match search would swallow everything on it. Area order makes
  /// the specific area win without any z ordering to maintain.
  SceneRegion? regionAt(Offset point) {
    SceneRegion? best;
    var bestArea = double.infinity;
    for (final region in scene.interactive) {
      if (!region.quad.contains(point)) continue;
      final bounds = region.quad.bounds;
      final area = bounds.width * bounds.height;
      if (area < bestArea) {
        best = region;
        bestArea = area;
      }
    }
    return best;
  }

  int _slotAt(SceneRegion region, Offset point) {
    final slots = region.slots;
    // Back to front: on a shelf where the items lean on each other, the one
    // in front is the one being pointed at.
    for (var i = slots.length - 1; i >= 0; i--) {
      if (slots[i].contains(point)) return i;
    }
    // Fall back to the nearest centre: leaning slots leave hairline gaps and
    // a drop that lands in one should not silently do nothing.
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < slots.length; i++) {
      final distance = (slots[i].center - point).distanceSquared;
      if (distance < bestDistance) {
        best = i;
        bestDistance = distance;
      }
    }
    return best;
  }

  /// Whether the thing normally drawn at [region] is currently in the hand.
  ///
  /// Picking something up does not take it off the counter — that only
  /// happens once it lands somewhere, so a failed drop needs no undo. The
  /// renderer asks this instead, and skips what the finger is already
  /// carrying.
  bool lifted(String region, [int? slot]) => switch (carried) {
    PismisEt(slot: final from) when region == 'mangal_alani' => from == slot,
    HazirUrun(fromSource: false, :final origin, slot: final from) =>
      origin == region && from == slot,
    _ => false,
  };

  // --- Tap: sources with exactly one destination (design doc 13) ---

  /// A touch does what the obvious drag would have done.
  ///
  /// Dragging is still the vocabulary, but making it the *only* way to move
  /// an ingredient is friction with no decision behind it: there is exactly
  /// one place a pinch of onion can go. Where the destination is ambiguous —
  /// a dessert, a bottle, a finished product — the touch only lights the
  /// source up and the drag stays the way to say where.
  void tap(Offset point) {
    if (bitti || duraklatildi) return;
    final region = regionAt(point);
    switch (region?.name) {
      case 'tabak_kaynak':
        if (progress.unlocks.porsiyonHatti && tabakIstasyonu == null) {
          tabakIstasyonu = Porsiyon();
          _flash('tabak_kaynak');
          return;
        }
      case 'bardak_kaynak':
        if (progress.unlocks.icecekHatti) {
          final free = bardakBekletme.indexWhere((b) => b == null);
          if (free >= 0) {
            bardakBekletme[free] = Bardak();
            _flash('bardak_kaynak');
            return;
          }
        }
    }
    if (region == null) return;

    final held = _pickUp(region, point);
    if (held == null) {
      _flash(region.name, ok: false);
      onEvent(DayEvent.gecersiz);
      return;
    }
    _flash(region.name);
    if (_yerlestir(held)) onChanged();
  }

  /// The one place the thing in [held] can go, if there is only one.
  bool _yerlestir(Carried held) {
    bool at(String region, bool Function() place) {
      if (!place()) return false;
      _flash(region);
      return true;
    }

    return switch (held) {
      CigKiyma() => at('mangal_alani', _mangalaKoy),
      // Bread goes to the wrap while that is free, and to the plate after —
      // the plate cannot start without it either.
      Lavas() =>
        at('durum_hazirlama', () => _durumaBirak(held)) ||
            at('tabak_hazirlama', () => _tabagaBirak(held)),
      PismisEt(yanik: false) =>
        at('durum_hazirlama', () => _durumaBirak(held)) ||
            at('tabak_hazirlama', () => _tabagaBirak(held)),
      MalzemeTutami() => at('durum_hazirlama', () => _durumaBirak(held)),
      Kagit() => at('durum_hazirlama', () => _durumaBirak(held)),
      BilesenTutami() => at('tabak_hazirlama', () => _tabagaBirak(held)),
      Surahi() => at('bardak_bekletme', () => _surahiyiDok(held)),
      _ => false,
    };
  }

  bool _mangalaKoy() {
    final target = _bosSlot(0);
    if (target == null) return false;
    mangal[target].koy();
    return true;
  }

  bool _surahiyiDok(Surahi held) {
    for (final bardak in bardakBekletme) {
      if (bardak != null && bardak.bos) {
        bardak.doldur(held.icecek);
        return true;
      }
    }
    return false;
  }

  // --- Upward flick: rolling, and nothing else ---

  /// Rolling closes the wrap. It stays in the prep area until the paper is
  /// on it and somebody carries it off, which is the whole of the pressure in
  /// the wrap line: one wrap at a time, and every one of them a choice
  /// between serving it now and putting it on the shelf.
  void flickUp(Offset point) {
    if (bitti || duraklatildi) return;
    final station = durumIstasyonu;
    if (regionAt(point)?.name == 'durum_hazirlama' &&
        station != null &&
        station.sarilabilir) {
      station.sarili = true;
      _flash('durum_hazirlama');
      onChanged();
      return;
    }
    _flash('durum_hazirlama', ok: false);
    onEvent(DayEvent.gecersiz);
  }

  bool beginDrag(Offset point) {
    if (bitti || duraklatildi) return false;
    final region = regionAt(point);
    if (region == null) return false;
    carried = _pickUp(region, point);
    carriedAt = point;
    if (carried != null) _flash(region.name);
    return carried != null;
  }

  /// Puts down what a gesture picked up without applying it anywhere.
  ///
  /// A tap arrives as a drag that never moved, so the pickup has already
  /// happened by the time anyone knows it was a tap. Nothing was taken off
  /// the counter on pickup, so this is only forgetting.
  void cancelDrag() => carried = null;

  void endDrag(Offset point) {
    final held = carried;
    carried = null;
    if (held == null) return;
    if (_drop(held, point)) {
      final landed = regionAt(point);
      if (landed != null) _flash(landed.name);
    } else {
      final landed = regionAt(point);
      if (landed != null) _flash(landed.name, ok: false);
      onEvent(DayEvent.gecersiz);
      _putBack(held);
    }
    onChanged();
  }

  Carried? _pickUp(SceneRegion region, Offset point) {
    final unlocks = progress.unlocks;

    if (region.name == 'malzeme_kiyma') return const CigKiyma();
    if (region.name == 'lavas_kaynak') return const Lavas();
    if (region.name == 'kagit_kaynak') return const Kagit();

    for (final malzeme in unlocks.malzemeler) {
      if (region.name == malzeme.region) return MalzemeTutami(malzeme);
    }
    for (final bilesen in unlocks.bilesenler) {
      if (region.name == bilesen.region) return BilesenTutami(bilesen);
    }
    for (final icecek in unlocks.icecekler) {
      if (region.name != icecek.sourceRegion) continue;
      return icecek.poured
          ? Surahi(icecek)
          : HazirUrun(IcecekUrun(icecek), region.name, fromSource: true);
    }
    for (final tatli in unlocks.tatlilar) {
      if (region.name == tatli.region) {
        return HazirUrun(TatliUrun(tatli), region.name, fromSource: true);
      }
    }

    switch (region.name) {
      case 'mangal_alani':
        return _mangaldanAl(_slotAt(region, point));

      case 'durum_hazirlama':
        final station = durumIstasyonu;
        if (station != null && station.hazir) {
          return HazirUrun(DurumUrun(station), region.name);
        }

      case 'tabak_hazirlama':
        final station = tabakIstasyonu;
        if (station != null && station.hazir) {
          return HazirUrun(PorsiyonUrun(station), region.name);
        }

      case 'bekleme_alani':
        final index = _slotAt(region, point);
        final urun = bekleme[index];
        if (urun != null) return HazirUrun(urun, region.name, slot: index);

      case 'bardak_bekletme':
        final index = _slotAt(region, point);
        final bardak = bardakBekletme[index];
        if (bardak != null && bardak.hazir) {
          return HazirUrun(
            IcecekUrun(bardak.icerik!),
            region.name,
            slot: index,
          );
        }
    }
    return null;
  }

  bool _drop(Carried held, Offset point) {
    final region = regionAt(point);
    if (region == null) return false;

    // The bin takes everything, always open. Without it burnt meat would hold
    // a grill slot for the rest of the day.
    if (region.name == 'cop_alani') {
      _consume(held);
      return true;
    }

    if (region.name.startsWith('musteri_slot_')) {
      final index = int.parse(region.name.split('_').last) - 1;
      final customer = musteriler[index];
      if (customer == null || held is! HazirUrun) return false;
      return _servis(index, customer, held);
    }

    switch (region.name) {
      case 'mangal_alani':
        if (held is! CigKiyma) return false;
        final target = _bosSlot(_slotAt(region, point));
        if (target == null) return false;
        mangal[target].koy();
        return true;

      case 'durum_hazirlama':
        return _durumaBirak(held);

      case 'tabak_hazirlama':
        return _tabagaBirak(held);

      case 'bekleme_alani':
        if (held is! HazirUrun || held.urun.beklemeBolgesi != region.name) {
          return false;
        }
        return _rafaKoy(held, _slotAt(region, point));

      case 'bardak_bekletme':
        if (held is! Surahi) return false;
        final bardak = bardakBekletme[_slotAt(region, point)];
        if (bardak == null || !bardak.bos) return false;
        bardak.doldur(held.icecek);
        return true;
    }
    return false;
  }

  bool _durumaBirak(Carried held) {
    if (held is Lavas) {
      if (durumIstasyonu != null) return false;
      durumIstasyonu = Durum();
      return true;
    }
    final station = durumIstasyonu;
    if (station == null) return false;
    switch (held) {
      case PismisEt(yanik: false):
        if (station.etli || station.sarili) return false;
        station.etli = true;
      case MalzemeTutami(:final malzeme):
        if (!station.malzemeKabul(malzeme)) return false;
        station.malzemeler.add(malzeme);
      case Kagit():
        if (!station.kagitBekliyor) return false;
        station.kagitli = true;
      case _:
        return false;
    }
    _consume(held);
    return true;
  }

  bool _tabagaBirak(Carried held) {
    final station = tabakIstasyonu;
    if (station == null) return false;
    switch (held) {
      case Lavas():
        if (!station.lavasBekliyor) return false;
        station.lavasli = true;
      case PismisEt(yanik: false):
        if (!station.lavasli || station.etli) return false;
        station.etli = true;
      case BilesenTutami(:final bilesen):
        if (!station.bilesenKabul(bilesen)) return false;
        station.bilesenler.add(bilesen);
      case _:
        return false;
    }
    _consume(held);
    return true;
  }

  bool _rafaKoy(HazirUrun held, int preferred) {
    final capacity = progress.unlocks.bekleme;
    final target = preferred < capacity && bekleme[preferred] == null
        ? preferred
        : _ilkBos();
    if (target == null) return false;
    _consume(held);
    bekleme[target] = held.urun;
    return true;
  }

  int? _ilkBos() {
    for (var i = 0; i < progress.unlocks.bekleme; i++) {
      if (bekleme[i] == null) return i;
    }
    return null;
  }

  // --- The grill, aimed at as one area ---

  /// The skewer a drag starting at [index] picks up.
  ///
  /// Hitting an exact slot on a leaning grill is the wrong thing to ask of a
  /// player mid-rush, so the whole grill is the target: whatever is under the
  /// finger wins, and failing that the grill hands over its most urgent
  /// skewer. Cooked before burnt, and of the cooked ones the one nearest to
  /// burning — that is the one about to cost money.
  Carried? _mangaldanAl(int index) {
    final under = mangal[index];
    if (under.alinabilir) return PismisEt(index);
    if (under.yanmis) return PismisEt(index, yanik: true);

    var pick = -1;
    var urgency = -1.0;
    for (var i = 0; i < mangal.length; i++) {
      if (!mangal[i].unlocked || !mangal[i].alinabilir) continue;
      final left = mangal[i].ilerleme(day);
      if (left > urgency) {
        urgency = left;
        pick = i;
      }
    }
    if (pick >= 0) return PismisEt(pick);

    final burnt = _nearest(index, (slot) => slot.yanmis);
    return burnt == null ? null : PismisEt(burnt, yanik: true);
  }

  /// [preferred] when it is free, otherwise the closest slot that is.
  int? _bosSlot(int preferred) {
    final slot = mangal[preferred];
    if (slot.unlocked && slot.bos) return preferred;
    return _nearest(preferred, (slot) => slot.bos);
  }

  int? _nearest(int from, bool Function(MangalSlot slot) matches) {
    int? best;
    var distance = mangal.length;
    for (var i = 0; i < mangal.length; i++) {
      if (!mangal[i].unlocked || !matches(mangal[i])) continue;
      if ((i - from).abs() < distance) {
        distance = (i - from).abs();
        best = i;
      }
    }
    return best;
  }

  // --- Serving ---

  bool _servis(int index, Customer customer, HazirUrun held) {
    final order = customer.order;
    final kazanc = switch (held.urun) {
      TatliUrun(:final tatli)
          when order.tatli == tatli && !customer.tatliVerildi =>
        Balance.income(Balance.tatliBase[tatli]!, day),
      IcecekUrun(:final icecek)
          when order.icecek == icecek && !customer.icecekVerildi =>
        Balance.income(Balance.icecekBase[icecek]!, day),
      final urun when !customer.anaUrunVerildi && order.anaUrunKabul(urun) =>
        _anaUrunGeliri(urun),
      _ => null,
    };

    if (kazanc == null) {
      customer.reddet();
      onEvent(DayEvent.reddedildi);
      // Handled, not invalid: the drop was a legal move that the customer
      // turned down, so the product goes to its shelf rather than reporting a
      // mis-drop.
      _putBack(held);
      return true;
    }

    switch (held.urun) {
      case TatliUrun():
        customer.tatliVerildi = true;
      case IcecekUrun():
        customer.icecekVerildi = true;
      case _:
        customer.anaUrunVerildi = true;
    }

    _consume(held);
    customer.odenen += kazanc;
    progress.kazan(kazanc);
    onEvent(DayEvent.kabul);

    if (customer.tamamlandi) _ayril(index, memnun: true);
    return true;
  }

  int _anaUrunGeliri(Urun urun) => switch (urun) {
    DurumUrun(:final durum) => Balance.income(
      Balance.durumBase,
      day,
      ingredients: durum.malzemeler.length,
    ),
    PorsiyonUrun(:final porsiyon) => Balance.income(
      Balance.porsiyonBase,
      day,
      ingredients: porsiyon.bilesenler.length,
    ),
    _ => 0,
  };

  void _ayril(int index, {required bool memnun}) {
    final customer = musteriler[index];
    if (customer == null) return;
    musteriler[index] = null;

    onEvent(memnun ? DayEvent.musteriMemnun : DayEvent.musteriKizgin);
    _sonrakiGelis = math.max(_sonrakiGelis, Balance.arrivalGap);
    onChanged();
  }

  // --- Where things go ---

  /// Removes what was picked up from wherever it was sitting. Called only on
  /// a successful drop, so a drop that fails needs no undo.
  void _consume(Carried held) {
    switch (held) {
      case PismisEt(:final slot):
        mangal[slot].bosalt();
      case HazirUrun(fromSource: false, :final origin, :final slot):
        switch (origin) {
          case 'durum_hazirlama':
            durumIstasyonu = null;
          case 'tabak_hazirlama':
            tabakIstasyonu = null;
          case 'bekleme_alani':
            bekleme[slot!] = null;
          case 'bardak_bekletme':
            bardakBekletme[slot!] = null;
        }
      case _:
        break; // Sources are endless; nothing to take away.
    }
  }

  /// Design doc 8.5: a refused product goes to its own waiting shelf, and
  /// when that is full it stays in the prep area and blocks it. Nothing here
  /// has to move for that second case — a failed drop never removed it.
  void _putBack(Carried held) {
    if (held is! HazirUrun || held.fromSource) return;
    if (held.origin != 'durum_hazirlama' && held.origin != 'tabak_hazirlama') {
      return;
    }
    if (held.urun.beklemeBolgesi != 'bekleme_alani') return;
    final target = _ilkBos();
    if (target == null) return;
    _consume(held);
    bekleme[target] = held.urun;
  }
}
