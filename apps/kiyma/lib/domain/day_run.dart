import 'dart:math' as math;
import 'dart:ui';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_rule.dart';
import 'package:kiyma/domain/model/carried.dart';
import 'package:kiyma/domain/model/customer_kind.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/order_maker.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/domain/trade_shape.dart';
import 'package:kiyma/domain/tutor.dart';

/// Something the day did that the screen should react to once.
enum DayEvent {
  kabul,
  reddedildi,
  gecersiz,
  yandi,
  mangalDolu,
  altinSupuruldu,
  musteriGeldi,
  tempoBonusu,
  musteriMemnun,
  musteriKizgin,
  gunBitti,

  /// The doors are shut: whoever is at the counter is the last of them.
  sonSiparis,

  /// Somebody changed their mind about what they wanted.
  fikirDegisti,

  /// The day's goal was reached.
  gunlukHedef,

  /// A run of customers served without a mistake paid out.
  seri,

  /// A generous customer left something on top.
  bahsis,
}

/// Something that happened, and where.
///
/// [DayEvent] alone says only what, so every reward was drawn on the plate in
/// the top-left corner and nothing could burst under the finger that earned
/// it. The renderer drains these into its effects pool; the rules stay free
/// of the engine and the headless simulator keeps running at full speed.
class Cue {
  Cue(this.kind, this.at, {this.to, this.amount = 0, this.asset});

  final DayEvent kind;
  final Offset at;
  final Offset? to;
  final int amount;
  final String? asset;
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
    this.ogretmen,
    math.Random? random,
  }) : day = progress.gun,
       _random = random ?? math.Random(),
       _maker = OrderMaker(
         progress.unlocks,
         day: progress.gun,
         kural: DayRule.forDay(progress.gun),
         random: random,
       ) {
    final unlocks = progress.unlocks;
    mangal = [
      for (var i = 0; i < 4; i++)
        GrillSlot(
          komur: unlocks.komurKademesi,
          pencere: DayRule.forDay(progress.gun).pencereCarpani,
          unlocked: i < _acikMangal(progress),
        ),
    ];
    bekleme = List<Product?>.filled(3, null);
    altin = List<CoinPile?>.filled(3, null);
    bardakBekletme = List<Glass?>.filled(3, null);
    musteriler = List<Customer?>.filled(3, null);
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
  final math.Random _random;

  late final List<GrillSlot> mangal;

  /// One shelf for both lines. Wraps and plates share it.
  late final List<Product?> bekleme;
  late final List<Glass?> bardakBekletme;
  late final List<Customer?> musteriler;

  /// Still walking off. Nothing here affects a rule; the seat was freed the
  /// moment they turned to go.
  final List<Departure> ayrilanlar = [];

  Wrap? durumIstasyonu;
  Plate? tabakIstasyonu;

  Carried? carried;
  Offset carriedAt = Offset.zero;

  /// Regions lit up by a touch, and how long they have left. Taking something
  /// off a tray is otherwise invisible until the thing is already under the
  /// finger, which reads as a dropped input.
  final Map<String, ({double left, bool ok})> parlama = {};

  static const _flashFor = 0.28;

  /// [sayilir] is false where the flash is only saying "you touched this".
  ///
  /// Picking something up is not a move. It used to count as one, so lifting
  /// a pinch of tomato paid tempo before anyone knew whether there was
  /// anywhere to put it — and a tap on a tray with a full wrap behind it was
  /// a clean gain for an impossible action. What counts is where a thing
  /// lands, or that it could not land anywhere.
  void _flash(String region, {bool ok = true, bool sayilir = true}) {
    parlama[region] = (left: _flashFor, ok: ok);
    if (!sayilir) return;
    // Every success and every refusal in the game passes through here, which
    // makes it the one place that can count a run of mis-moves.
    ok ? tempo.basarili() : tempo.gecersizHareket();
  }

  double flashAt(String region) => (parlama[region]?.left ?? 0) / _flashFor;

  /// What each customer left on the ledge, waiting to be picked up. One pile
  /// per place, so the gold sits where the person who paid it stood.
  late final List<CoinPile?> altin;

  /// Seconds left on the counter. A run is a clock: customers keep arriving
  /// as seats free until it runs out.
  late double kalanSure;

  late final int _acilis;

  /// What this run has taken, as opposed to the running total.
  int get kazanc => progress.xp - _acilis;

  /// How many customers left with everything they asked for.
  int memnunMusteri = 0;

  /// What the day is judged on afterwards. Counted here rather than derived
  /// from the summary because nothing else sees a skewer burn: by the time a
  /// run is over the grill has been emptied and the evidence is gone.
  int yanikSayisi = 0;
  int kizginSayisi = 0;
  int kritikServis = 0;

  /// What just happened and where, waiting to be drawn. Capped, because the
  /// headless simulator plays thousands of runs and nothing drains it there.
  final List<Cue> cues = [];

  static const _cueCap = 24;

  void _cue(
    DayEvent kind,
    Offset at, {
    Offset? to,
    int amount = 0,
    String? asset,
  }) {
    if (cues.length >= _cueCap) cues.removeAt(0);
    cues.add(Cue(kind, at, to: to, amount: amount, asset: asset));
  }

  /// Where a customer is standing, for anything addressed to them.
  Offset yeri(int slot) => scene['musteri_slot_${slot + 1}'].quad.bounds.center;

  /// The counter's momentum. Everything the player does feeds it or costs it,
  /// and what it is worth is a multiplier on the takings, the cooked window
  /// and how fast patience runs out.
  late final Tempo tempo = Tempo(bagislananSayisi: kural.bagislanan);

  double get sureOrani =>
      (kalanSure / Balance.runLength(day).inSeconds).clamp(0, 1);
  double _sonrakiGelis = 0;
  bool bitti = false;

  /// What is different about today. Neutral on days one to three.
  late final DayRule kural = DayRule.forDay(day);

  /// How many customers the day asks to be sent away happy, and whether it
  /// has happened yet.
  late final int gunlukHedef = math.max(
    1,
    (Balance.gunlukHedef(day) * kural.hedefCarpani).round(),
  );

  bool hedefTamam = false;

  /// The lesson being taught on this run, if one is owed.
  ///
  /// While it is running the clock is stopped and nobody comes through the
  /// door unless the step asks for somebody: a first lesson played against a
  /// ticking day teaches only that the game does not wait.
  final Tutor? ogretmen;

  bool get ogretiliyor => ogretmen != null && !ogretmen!.bitti;

  /// Walking out of a lesson, and stepping through the parts of one that are
  /// only the usta talking. Here rather than on [Tutor] so that the screen
  /// is told to redraw and the shop is told the lesson is over.
  void dersiAtla() {
    ogretmen?.atla();
    onChanged();
  }

  void dersiIlerlet() {
    ogretmen?.ilerlet();
    onChanged();
  }

  void _kilometre(Milestone kilometre) {
    if (!ogretiliyor) return;
    ogretmen!.ulasildi(kilometre);
    onChanged();
  }

  /// The shape of this particular day, and how far through it we are.
  late final TradeShape profil = TradeShape.forDay(day);

  double get gunOrani => 1 - sureOrani;

  /// Past the last order, before the buzzer.
  bool get sonSiparisZamani => gunOrani >= Balance.sonSiparis;

  /// After the buzzer, while the counter empties.
  bool get kapaniyor => kalanSure <= 0 && !bitti;

  double _kapanisKalan = Balance.kapanisPayi;
  bool _sonSiparisBildirildi = false;

  /// How long every open grill slot has been empty. Past
  /// [Balance.idleGrill] the mince tray starts blinking: an empty grill is
  /// the one mistake that costs nothing to make and everything to keep
  /// making, because the whole counter waits on it.
  double bosMangal = 0;

  bool get mangalCagiriyor => bosMangal >= Balance.idleGrill;

  /// The same, for a wrap station with nothing on it: the bread is what
  /// starts a wrap, so the bread is what asks.
  double bosDurum = 0;

  bool get lavasCagiriyor => bosDurum >= Balance.idleWrap;

  /// How long a burnt skewer has been holding a slot. The bin is the only
  /// way out of that, so the bin is what asks.
  double bekleyenYanik = 0;

  bool get copCagiriyor => bekleyenYanik >= Balance.idleBurnt;

  /// What the camera can see, in scene units, kept current by the renderer.
  ///
  /// The bin is not a bucket on the floor any more. A painted bin has to
  /// stand somewhere, and the only free floor was in front of the grill —
  /// which put it behind the grill in depth and half a counter away from the
  /// shelf. Two corners of the screen are within reach of the thumb already
  /// holding the thing, on every shape of phone, and they cost no space at
  /// all when the hand is empty.
  Rect gorunurAlan = Rect.zero;

  static const _copKose = Size(176, 124);

  /// The two places a binnable thing can be dropped, in the corners of what
  /// is actually on screen rather than of the design box.
  List<Rect> get copKoseleri {
    final area = gorunurAlan.isEmpty
        ? Offset.zero & Size(scene.size.width, scene.size.height)
        : gorunurAlan;
    // Horizontally against what is on screen, vertically against the design
    // box: the camera reports a visible rect a little taller than the window
    // actually is, and a corner anchored to that hangs off the bottom.
    final bottom = math.min(area.bottom, scene.size.height);
    return [
      Rect.fromLTWH(
        area.left,
        bottom - _copKose.height,
        _copKose.width,
        _copKose.height,
      ),
      Rect.fromLTWH(
        area.right - _copKose.width,
        bottom - _copKose.height,
        _copKose.width,
        _copKose.height,
      ),
    ];
  }

  /// Whether the corners are open.
  ///
  /// Three things go in the bin and nothing else: a finished wrap, a
  /// finished plate, and a burnt skewer. Opening them for every pinch of
  /// onion put two panels over the counter for most of the run, and none of
  /// those is a thing anybody throws away — a handful goes back to its tray
  /// on its own the moment the drop is refused.
  bool get copeAtilabilir => carried != null && copeGider(carried!);

  static bool copeGider(Carried held) => switch (held) {
    FinishedProduct() => true,
    CookedMeat(yanik: true) => true,
    _ => false,
  };

  bool copKosesinde(Offset point) =>
      copeAtilabilir && copKoseleri.any((kose) => kose.contains(point));

  /// The same test at drop time, when [carried] has already been let go of.
  bool _copKoselerindeDusen(Offset point) =>
      copKoseleri.any((kose) => kose.contains(point));

  /// The key the bin flashes under. Not a region any more — there is nothing
  /// on the counter to light up — but the flash map and the run of mis-moves
  /// are both keyed by name.
  static const copAdi = 'cop';

  /// Seconds left on the paper's answer to somebody reaching for a wrap that
  /// has not been papered yet.
  double kagitCagiriyor = 0;

  /// Everything stops: the clock, the grill, the patience bars. The player
  /// asked for it, so it is not the free breather that stepping out of the
  /// counter would have been.
  bool duraklatildi = false;

  // --- Clock ---

  void tick(double dt) {
    if (bitti || duraklatildi) return;

    bosMangal = mangal.any((slot) => slot.unlocked && !slot.bos)
        ? 0
        : bosMangal + dt;
    bosDurum = durumIstasyonu == null ? bosDurum + dt : 0;
    bekleyenYanik = mangal.any((slot) => slot.yanmis) ? bekleyenYanik + dt : 0;
    if (kagitCagiriyor > 0) kagitCagiriyor -= dt;
    if (tempoIkramiyeKalan > 0) tempoIkramiyeKalan -= dt;

    tempo.tick(
      dt,
      bekleyen: musteriler.any((c) => c != null && c.yerinde),
      sizma: Balance.sizmaCarpani(progress.unlocks.cirakKademesi),
    );
    _tempoTasmasi();

    for (final slot in mangal) {
      final pismisti = slot.alinabilir;
      if (slot.tick(dt, day, tempo.pismeCarpani)) {
        final penalty = Balance.burnPenalty(day).round();
        progress.cezalandir(penalty);
        yanikSayisi++;
        tempo.etYandi();
        _cue(
          DayEvent.yandi,
          scene['mangal_alani'].slots[mangal.indexOf(slot)].center,
          amount: -penalty,
        );
        onEvent(DayEvent.yandi);
        onChanged();
      }
      if (!pismisti && slot.alinabilir) _kilometre(Milestone.etPisti);
    }

    for (final bardak in bardakBekletme) {
      final doluyordu = bardak?.doluyor ?? false;
      bardak?.tick(dt);
      if (doluyordu && !bardak!.doluyor) _kilometre(Milestone.bardakDoldu);
    }

    parlama
      ..updateAll((_, flash) => (left: flash.left - dt, ok: flash.ok))
      ..removeWhere((_, flash) => flash.left <= 0);

    for (var i = 0; i < altin.length; i++) {
      final pile = altin[i];
      if (pile == null) continue;
      pile.kalan -= dt;
      if (pile.kalan <= 0) {
        // Swept up rather than lost: leaving it costs the tip, not the sale.
        final kept =
            (pile.miktar * Balance.supurulenPay(progress.unlocks.kasaKademesi))
                .round();
        progress.kazan(kept);
        _cue(
          DayEvent.altinSupuruldu,
          scene['altin_alani'].slots[i].center,
          amount: kept - pile.miktar,
        );
        altin[i] = null;
        tempo.altinSupuruldu();
        onEvent(DayEvent.altinSupuruldu);
        onChanged();
      }
    }

    for (var i = 0; i < musteriler.length; i++) {
      final customer = musteriler[i];
      if (customer == null) continue;
      if (!customer.yerinde) {
        customer.varis = math.min(
          1,
          customer.varis + dt * customer.hiz / Balance.arrivalWalk,
        );
        continue;
      }
      customer.yerindeSure += dt;
      if (customer.hataKalan > 0) customer.hataKalan -= dt;
      // Nothing runs out mid-lesson: being taught is not being tested.
      if (!ogretiliyor) customer.sabirKalan -= dt / tempo.sabirCarpani;
      _fikirDegisirMi(i, customer);
      if (customer.sabirKalan <= 0) {
        _ayril(i, memnun: false);
      }
    }

    for (final leaving in ayrilanlar) {
      leaving.gidis += dt * leaving.hiz / Balance.arrivalWalk;
    }
    ayrilanlar.removeWhere((leaving) => leaving.gitti);

    // A lesson holds the door and stops the clock. The counter still cooks
    // — a step that says "wait for it to brown" has to be able to happen —
    // but nothing arrives and no time is lost, because a first run played
    // against a ticking day teaches only that the game does not wait.
    if (ogretiliyor) {
      _dersMusterisi();
      return;
    }

    _sonrakiGelis -= dt;
    // Nobody new past the last order, and nobody at all once the buzzer has
    // gone: the closing stretch is for finishing what is already ordered.
    if (_sonrakiGelis <= 0 && !sonSiparisZamani) {
      final free = _bosMusteriSlotu();
      if (free != null) {
        musteriler[free] = Customer(
          order: _maker.make(),
          day: day,
          ikram: progress.unlocks.ikramKademesi,
          kural: kural.sabirCarpani,
          hiz:
              Balance.slowestWalk +
              _random.nextDouble() * (1 - Balance.slowestWalk),
        );
        _sonrakiGelis = _gelisAraligi;
        onEvent(DayEvent.musteriGeldi);
        onChanged();
      }
    }

    if (sonSiparisZamani && !_sonSiparisBildirildi) {
      _sonSiparisBildirildi = true;
      // On the ledge, in the middle of the room. The clock was the obvious
      // anchor and the wrong one: that corner is already the clock, the
      // calendar and the purse, and the badge landed on the money. The news
      // is about the queue anyway — these are the last of them.
      _cue(
        DayEvent.sonSiparis,
        scene['tezgah_ust_kenari'].quad.bounds.topCenter,
      );
      onEvent(DayEvent.sonSiparis);
    }

    kalanSure -= dt;
    if (kalanSure > 0) return;
    kalanSure = 0;
    // The buzzer is not the end. Whoever is at the counter is still owed
    // what they ordered, and a day that cuts mid-order ends by taking
    // something away from the player. It closes when the last of them has
    // gone — or when the grace runs out, so putting the phone down does not
    // hold the shop open.
    _kapanisKalan -= dt;
    if (_kapanisKalan > 0 && musteriler.any((c) => c != null)) return;
    bitti = true;
    onEvent(DayEvent.gunBitti);
    onChanged();
  }

  /// Seats somebody the moment a step needs one, rather than waiting for
  /// the door: the lesson decides when the shop is busy.
  void _dersMusterisi() {
    final adim = ogretmen!.adim;
    if (adim == null || !adim.musteri) return;
    if (musteriler.any((c) => c != null)) return;
    musteriler[0] = Customer(
      order: Order(
        tip: ProductKind.durum,
        ister: {...adim.ister},
        istemez: {},
      ),
      day: day,
      ikram: progress.unlocks.ikramKademesi,
    )..varis = 1;
    onEvent(DayEvent.musteriGeldi);
    onChanged();
  }

  /// A tip every fifth customer in a row, so a good stretch is worth
  /// something the player can see rather than only a steadier meter.
  void _seriIkramiyesi(int index) {
    if (tempo.seri % Balance.seriIkramiyeAdimi != 0) return;
    final miktar = Balance.seriIkramiyesi(tempo.seri, day);
    if (miktar <= 0) return;
    progress.kazan(miktar);
    _cue(DayEvent.seri, yeri(index), amount: miktar, asset: 'altin');
    onEvent(DayEvent.seri);
  }

  /// Pays the day's goal the moment it lands, not at the summary: a reward
  /// that arrives after the run is over is a number, where one that lands
  /// mid-shift is a moment.
  void _gunlukHedef() {
    if (hedefTamam || memnunMusteri < gunlukHedef) return;
    hedefTamam = true;
    final odul = Balance.gunlukOdul(day);
    progress.kazan(odul);
    _cue(
      DayEvent.gunlukHedef,
      scene['tezgah_ust_kenari'].quad.bounds.center,
      amount: odul,
      asset: 'altin',
    );
    onEvent(DayEvent.gunlukHedef);
  }

  /// Slots the day actually opens: a rule may close one, never below the
  /// grill day one had.
  static int _acikMangal(Progress progress) => math.max(
    Balance.enAzMangal,
    progress.unlocks.mangalSlots - DayRule.forDay(progress.gun).mangalKesintisi,
  );

  /// The gap to the next arrival: the day's base, stretched or squeezed by
  /// whichever stretch of the shift we are in.
  double get _gelisAraligi =>
      Balance.arrivalGap(day, tabela: progress.unlocks.tabelaKademesi) *
      profil.yogunlukAt(gunOrani).aralikCarpani;

  /// Halfway through the wait, an indecisive customer swaps one ingredient
  /// for another.
  ///
  /// It reuses the refusal marks: the two wells flash and the ticket shakes,
  /// which is already the language for "look at the card again". Silently
  /// editing the order would be the game cheating.
  void _fikirDegisirMi(int index, Customer customer) {
    final order = customer.order;
    if (order.musteriTipi != CustomerKind.kararsiz) return;
    if (customer.fikirDegisti || !customer.yerinde) return;
    if (customer.sabirOrani > Balance.kararsizAn) return;

    customer.fikirDegisti = true;
    final havuz = [
      for (final id
          in order.tip == ProductKind.durum
              ? progress.unlocks.malzemeler.map((m) => m.id)
              : progress.unlocks.bilesenler.map((b) => b.id))
        if (!order.ister.contains(id) && !order.istemez.contains(id)) id,
    ];
    if (havuz.isEmpty || order.ister.isEmpty) return;

    final cikan = order.ister.first;
    final giren = havuz[_random.nextInt(havuz.length)];
    order.fikirDegistir(cikan, giren);
    customer
      ..hatali = {cikan, giren}
      ..hataKalan = 1.8;
    _cue(DayEvent.fikirDegisti, yeri(index));
    onEvent(DayEvent.fikirDegisti);
    onChanged();
  }

  /// A meter with no room left still has to pay for good play, or the last
  /// stretch of a strong run goes quiet. What it could not absorb becomes
  /// gold, straight into the till.
  void _tempoTasmasi() {
    final over = tempo.bosalt();
    if (over <= 0) return;
    final gold = (over * Balance.tempoBonus).round();
    if (gold <= 0) return;
    tempoIkramiye = gold;
    tempoIkramiyeKalan = 1.2;
    progress.kazan(gold);
    onEvent(DayEvent.tempoBonusu);
    onChanged();
  }

  /// The last overflow payout, still on screen.
  int tempoIkramiye = 0;
  double tempoIkramiyeKalan = 0;

  int? _bosMusteriSlotu() {
    for (var i = 0; i < progress.unlocks.musteriSlots; i++) {
      if (musteriler[i] == null) return i;
    }
    return null;
  }

  // --- Hit testing ---

  /// The region under [point] that money has already opened.
  ///
  /// Areas the shop has not sold yet are skipped: nothing is drawn there, so
  /// a touch that hit one would light up a patch of bare counter.
  SceneRegion? regionAt(Offset point) =>
      scene.at(point, kabul: (region) => progress.unlocks.shows(region.name));

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
    CookedMeat(slot: final from) when region == 'mangal_alani' => from == slot,
    FinishedProduct(fromSource: false, :final origin, slot: final from) =>
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
      case 'altin_alani':
        if (_altinTopla(_slotAt(region!, point))) {
          _flash('altin_alani', sayilir: false);
          return;
        }
      case 'tabak_kaynak':
        if (tabakIstasyonu == null) {
          tabakIstasyonu = Plate(
            gerekenTutam: progress.unlocks.tutamAdedi,
          );
          _kilometre(Milestone.tabakBasladi);
          _flash('tabak_kaynak');
          return;
        }
      case 'bardak_kaynak':
        final free = bardakBekletme.indexWhere((b) => b == null);
        if (free >= 0 && free < progress.unlocks.bardakGozu) {
          bardakBekletme[free] = Glass();
          _kilometre(Milestone.bardakAlindi);
          _flash('bardak_kaynak');
          return;
        }
    }
    if (region == null) return;

    final held = _pickUp(region, point);
    if (held == null) {
      // Bare counter has nothing to refuse. Now that locked areas are not
      // drawn at all, a touch on one lands here, and lighting the surface
      // they sit on would flash half the scene red.
      if (region.category == 'yapi') return;
      _flash(region.name, ok: false);
      _cue(DayEvent.gecersiz, region.quad.bounds.center);
      onEvent(DayEvent.gecersiz);
      return;
    }
    _flash(region.name, sayilir: false);
    if (_yerlestir(held)) {
      onChanged();
      return;
    }
    // A tap on something with no single destination is not a wrong move, it
    // is an unfinished one: the source lights up and the drag says who for.
    // And the grill announces its own refusal — it is four small slots at
    // the edge of the scene and a skewer that quietly fails to appear reads
    // as a lost input — so raw meat has already been answered by now.
    if (held is RawMince || !_tekYer(held)) return;
    _flash(region.name, ok: false);
    _cue(DayEvent.gecersiz, region.quad.bounds.center);
    onEvent(DayEvent.gecersiz);
  }

  /// Whether a touch alone is enough to say where [held] goes.
  ///
  /// A pinch of onion has exactly one destination, so a tap can place it and
  /// a tap that cannot is a refusal worth saying out loud. A baklava, a
  /// finished wrap or a poured glass could be for any of three people, so a
  /// tap on one of those only lifts it and costs nothing.
  static bool _tekYer(Carried held) => switch (held) {
    RawMince() ||
    Flatbread() ||
    CookedMeat(yanik: false) ||
    IngredientHandful() ||
    Paper() ||
    PlateItemHandful() ||
    Jug() => true,
    _ => false,
  };

  /// The one place the thing in [held] can go, if there is only one.
  bool _yerlestir(Carried held) {
    bool at(String region, bool Function() place) {
      if (!place()) return false;
      _flash(region);
      return true;
    }

    return switch (held) {
      RawMince() => at('mangal_alani', _mangalaKoy) || _mangalDolu(),
      // Bread goes to the wrap while that is free, and to the plate after —
      // the plate cannot start without it either.
      Flatbread() =>
        at('durum_hazirlama', () => _durumaBirak(held)) ||
            at('tabak_hazirlama', () => _tabagaBirak(held)),
      CookedMeat(yanik: false) =>
        at('durum_hazirlama', () => _durumaBirak(held)) ||
            at('tabak_hazirlama', () => _tabagaBirak(held)),
      IngredientHandful() => at('durum_hazirlama', () => _durumaBirak(held)),
      Paper() => at('durum_hazirlama', () => _durumaBirak(held)),
      PlateItemHandful() => at('tabak_hazirlama', () => _tabagaBirak(held)),
      Jug() => at('bardak_bekletme', () => _surahiyiDok(held)),
      _ => false,
    };
  }

  /// Takes the pile under the finger, or the nearest one there is.
  bool _altinTopla(int preferred) {
    var pick = altin[preferred] == null ? -1 : preferred;
    if (pick < 0) {
      var distance = altin.length;
      for (var i = 0; i < altin.length; i++) {
        if (altin[i] == null || (i - preferred).abs() >= distance) continue;
        distance = (i - preferred).abs();
        pick = i;
      }
    }
    if (pick < 0) return false;
    final taken = altin[pick]!.miktar;
    progress.kazan(taken);
    _cue(
      DayEvent.kabul,
      scene['altin_alani'].slots[pick].center,
      amount: taken,
      asset: 'altin',
    );
    altin[pick] = null;
    tempo.altinAlindi();
    _kilometre(Milestone.altinToplandi);
    onChanged();
    return true;
  }

  /// The one refusal that gets said out loud.
  ///
  /// Everywhere else a drop that will not take is obvious from the counter —
  /// the wrap already has onion on it, the shelf is visibly full. The grill
  /// is four small slots on a dark surface at the edge of the scene, and a
  /// skewer that quietly does not appear reads as a lost input.
  bool _mangalDolu() {
    _flash('mangal_alani', ok: false);
    // The far edge, so what is said about the grill does not cover it.
    _cue(DayEvent.mangalDolu, scene['mangal_alani'].quad.at(.5, 0));
    onEvent(DayEvent.mangalDolu);
    return false;
  }

  bool _mangalaKoy() {
    final target = _bosSlot(0);
    if (target == null) return false;
    mangal[target].koy();
    _kilometre(Milestone.kiymaMangalda);
    return true;
  }

  bool _surahiyiDok(Jug held) {
    for (final bardak in bardakBekletme) {
      if (bardak != null && bardak.bos) {
        bardak.doldur(
          held.icecek,
          Balance.dokumSuresi(progress.unlocks.surahiKademesi(held.icecek)),
        );
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
      _kilometre(Milestone.durumSarildi);
      _flash('durum_hazirlama');
      onChanged();
      return;
    }
    _flash('durum_hazirlama', ok: false);
    _cue(DayEvent.gecersiz, scene['durum_hazirlama'].quad.bounds.center);
    onEvent(DayEvent.gecersiz);
  }

  bool beginDrag(Offset point) {
    if (bitti || duraklatildi) return false;
    final region = regionAt(point);
    if (region == null) return false;
    carried = _pickUp(region, point);
    carriedAt = point;
    if (carried != null) _flash(region.name, sayilir: false);
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
      // Raw meat is the only thing the grill takes, so a refusal there is
      // always a full grill.
      if (landed?.name == 'mangal_alani' && held is RawMince) {
        _mangalDolu();
      } else {
        if (landed != null) _flash(landed.name, ok: false);
        _cue(DayEvent.gecersiz, landed?.quad.bounds.center ?? point);
        onEvent(DayEvent.gecersiz);
      }
      _putBack(held);
    }
    onChanged();
  }

  Carried? _pickUp(SceneRegion region, Offset point) {
    final unlocks = progress.unlocks;

    if (region.name == 'malzeme_kiyma') return const RawMince();
    if (region.name == 'lavas_kaynak') return const Flatbread();
    if (region.name == 'kagit_kaynak') return const Paper();

    for (final malzeme in unlocks.malzemeler) {
      if (region.name == malzeme.region) return IngredientHandful(malzeme);
    }
    for (final bilesen in unlocks.bilesenler) {
      if (region.name == bilesen.region) return PlateItemHandful(bilesen);
    }
    for (final icecek in unlocks.icecekler) {
      if (region.name != icecek.sourceRegion) continue;
      return icecek.poured
          ? Jug(icecek)
          : FinishedProduct(
              DrinkProduct(icecek),
              region.name,
              fromSource: true,
            );
    }
    for (final tatli in unlocks.tatlilar) {
      if (region.name == tatli.region) {
        return FinishedProduct(
          DessertProduct(tatli),
          region.name,
          fromSource: true,
        );
      }
    }

    switch (region.name) {
      case 'mangal_alani':
        return _mangaldanAl(_slotAt(region, point));

      case 'durum_hazirlama':
        final station = durumIstasyonu;
        if (station != null && station.hazir) {
          return FinishedProduct(WrapProduct(station), region.name);
        }
        // Reaching for a rolled wrap with no paper on it: the paper is the
        // step being skipped, so the paper is what answers.
        if (station != null && station.kagitBekliyor) {
          kagitCagiriyor = Balance.hintFor;
        }

      case 'tabak_hazirlama':
        final station = tabakIstasyonu;
        if (station != null && station.hazir) {
          return FinishedProduct(PlateProduct(station), region.name);
        }

      case 'bekleme_alani':
        final index = _slotAt(region, point);
        final urun = bekleme[index];
        if (urun != null) {
          return FinishedProduct(urun, region.name, slot: index);
        }

      case 'bardak_bekletme':
        final index = _slotAt(region, point);
        final bardak = bardakBekletme[index];
        if (bardak != null && bardak.hazir) {
          return FinishedProduct(
            DrinkProduct(bardak.icerik!),
            region.name,
            slot: index,
          );
        }
    }
    return null;
  }

  /// The bin is the last taker, not the first.
  ///
  /// It used to be checked before the scene, and the corners are 176 x 124 in
  /// a 1024 x 576 room: the right-hand one covers four fifths of the glass
  /// shelf and the left-hand one half the grill. A poured drink set back down
  /// on its own shelf was therefore thrown away — and `_drop` returned true,
  /// so the counter reported it as a successful drop and the player was left
  /// pouring another.
  ///
  /// Everything the bin is for still reaches it: a burnt skewer dropped on
  /// the grill is refused by the grill first, a finished wrap dropped on
  /// anything that will not take it likewise. The only drops it no longer
  /// swallows are the ones that worked.
  bool _drop(Carried held, Offset point) {
    if (_sahneyeBirak(held, point)) return true;
    if (!copeGider(held) || !_copKoselerindeDusen(point)) return false;
    // And never the thing's own home. The shelf refuses a poured glass —
    // there is no putting one back, it is picked up to be handed over — so
    // without this the refusal fell straight into the bin underneath it.
    final bolge = regionAt(point)?.name;
    if (held is FinishedProduct &&
        (bolge == held.urun.beklemeBolgesi || bolge == held.urun.evi)) {
      return false;
    }
    _consume(held);
    _flash(copAdi);
    return true;
  }

  bool _sahneyeBirak(Carried held, Offset point) {
    final region = regionAt(point);
    if (region == null) return false;

    if (region.name.startsWith('musteri_slot_')) {
      final index = int.parse(region.name.split('_').last) - 1;
      final customer = musteriler[index];
      if (customer == null || !customer.yerinde || held is! FinishedProduct) {
        return false;
      }
      return _servis(index, customer, held, point);
    }

    switch (region.name) {
      case 'mangal_alani':
        if (held is! RawMince) return false;
        final target = _bosSlot(_slotAt(region, point));
        if (target == null) return false;
        mangal[target].koy();
        _kilometre(Milestone.kiymaMangalda);
        return true;

      case 'durum_hazirlama':
        return _durumaBirak(held);

      case 'tabak_hazirlama':
        return _tabagaBirak(held);

      case 'bekleme_alani':
        if (held is! FinishedProduct ||
            held.urun.beklemeBolgesi != region.name) {
          return false;
        }
        return _rafaKoy(held, _slotAt(region, point));

      case 'bardak_bekletme':
        if (held is! Jug) return false;
        final bardak = bardakBekletme[_slotAt(region, point)];
        if (bardak == null || !bardak.bos) return false;
        bardak.doldur(
          held.icecek,
          Balance.dokumSuresi(progress.unlocks.surahiKademesi(held.icecek)),
        );
        return true;
    }
    return false;
  }

  bool _durumaBirak(Carried held) {
    if (held is Flatbread) {
      if (durumIstasyonu != null) return false;
      durumIstasyonu = Wrap(gerekenTutam: progress.unlocks.tutamAdedi);
      _kilometre(Milestone.durumBasladi);
      return true;
    }
    final station = durumIstasyonu;
    if (station == null) return false;
    switch (held) {
      case CookedMeat(yanik: false):
        if (station.etli || station.sarili) return false;
        station.etli = true;
        _kilometre(Milestone.etDurumda);
      case IngredientHandful(:final malzeme):
        if (!station.malzemeKabul(malzeme)) return false;
        station.malzemeEkle(malzeme);
        if (station.malzemeler.contains(malzeme)) {
          _kilometre(Milestone.malzemeTam);
        }
      case Paper():
        if (!station.kagitBekliyor) return false;
        station.kagitli = true;
        _kilometre(Milestone.durumKagitlandi);
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
      case Flatbread():
        if (!station.lavasBekliyor) return false;
        station.lavasli = true;
        _kilometre(Milestone.tabagaLavas);
      case CookedMeat(yanik: false):
        if (!station.lavasli || station.etli) return false;
        station.etli = true;
        _kilometre(Milestone.tabagaEt);
      case PlateItemHandful(:final bilesen):
        if (!station.bilesenKabul(bilesen)) return false;
        station.bilesenEkle(bilesen);
      case _:
        return false;
    }
    _consume(held);
    return true;
  }

  bool _rafaKoy(FinishedProduct held, int preferred) {
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
    if (under.alinabilir) return CookedMeat(index);
    if (under.yanmis) return CookedMeat(index, yanik: true);

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
    if (pick >= 0) return CookedMeat(pick);

    final burnt = _nearest(index, (slot) => slot.yanmis);
    return burnt == null ? null : CookedMeat(burnt, yanik: true);
  }

  /// [preferred] when it is free, otherwise the closest slot that is.
  int? _bosSlot(int preferred) {
    final slot = mangal[preferred];
    if (slot.unlocked && slot.bos) return preferred;
    return _nearest(preferred, (slot) => slot.bos);
  }

  int? _nearest(int from, bool Function(GrillSlot slot) matches) {
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

  bool _servis(
    int index,
    Customer customer,
    FinishedProduct held,
    Offset point,
  ) {
    final order = customer.order;
    // Which line of the ticket this settles. A big order has two, and the
    // first one it fits is the one it goes against.
    final ikinci = order.ikinci;
    final anaUyar = !customer.anaUrunVerildi && order.anaUrunKabul(held.urun);
    final ikinciUyar =
        !anaUyar &&
        ikinci != null &&
        !customer.ikinciVerildi &&
        ikinci.anaUrunKabul(held.urun);

    final kazanc = switch (held.urun) {
      DessertProduct(:final tatli)
          when order.tatli == tatli && !customer.tatliVerildi =>
        Balance.income(Balance.tatliBase[tatli]!, day),
      DrinkProduct(:final icecek)
          when order.icecek == icecek && !customer.icecekVerildi =>
        Balance.income(Balance.icecekBase[icecek]!, day),
      final urun when anaUyar || ikinciUyar => _anaUrunGeliri(
        urun,
        order.musteriTipi,
      ),
      _ => null,
    };

    if (kazanc == null) {
      customer
        ..reddet()
        // Blamed on whichever line is still owed, or the ticket would
        // explain the half already handed over.
        ..hatali = (customer.anaUrunVerildi ? ikinci ?? order : order).ihlal(
          held.urun,
        )
        ..hataKalan = 1.2;
      tempo.urunReddedildi();
      _cue(DayEvent.reddedildi, yeri(index));
      onEvent(DayEvent.reddedildi);
      // Handled, not invalid: the drop was a legal move that the customer
      // turned down, so the product goes to its shelf rather than reporting a
      // mis-drop.
      _putBack(held);
      return true;
    }

    switch (held.urun) {
      case DessertProduct():
        customer.tatliVerildi = true;
      case DrinkProduct():
        customer.icecekVerildi = true;
      case _:
        if (anaUyar) {
          customer.anaUrunVerildi = true;
        } else {
          customer.ikinciVerildi = true;
        }
    }

    _consume(held);
    // The bottom of the bar pays like the top: a handover made with seconds
    // left is the hardest thing the counter asks for.
    //
    // This used to ask a question of its own — "is the finishing line still
    // outstanding?" — computed *after* the switch above had already ticked
    // that line off, so it was true on every handover except the one that
    // finished the visit. A baklava passed to somebody about to walk out paid
    // half again; the wrap that saved them paid flat. `tamamlandi` is the
    // same question asked of the customer, and it is the one the badge below
    // has always used, so the till and the badge now agree by construction.
    final kritik =
        customer.tamamlandi && customer.sabirOrani <= Balance.kritikSabir;
    final paid =
        (kazanc * tempo.paraCarpani * (kritik ? Balance.kritikCarpani : 1))
            .round();
    customer.odenen += paid;
    _cue(
      DayEvent.kabul,
      point,
      to: yeri(index),
      amount: paid,
      asset: held.asset,
    );
    if (kritik) kritikServis++;
    tempo.servisEdildi(
      tamami: customer.tamamlandi,
      sabirOrani: customer.sabirOrani,
      kritik: kritik,
    );
    onEvent(DayEvent.kabul);
    _kilometre(Milestone.servisEdildi);

    if (customer.tamamlandi) {
      _seriIkramiyesi(index);
      _bahsis(index, customer);
      _ayril(index, memnun: true);
    }
    return true;
  }

  /// A generous customer served while they are still calm leaves something
  /// on top. Paid at the end rather than per item, so it reads as a tip and
  /// not as a better price.
  void _bahsis(int index, Customer customer) {
    if (customer.order.musteriTipi != CustomerKind.comert) return;
    if (customer.sabirOrani < Balance.comertEsigi) return;
    final miktar = (customer.odenen * Balance.comertBahsis).round();
    if (miktar <= 0) return;
    customer.odenen += miktar;
    _cue(DayEvent.bahsis, yeri(index), amount: miktar, asset: 'altin');
    onEvent(DayEvent.bahsis);
  }

  /// What the ticket quotes: the same arithmetic the till runs, asked of the
  /// order instead of the finished product.
  ///
  /// The renderer used to keep its own copy of this and the copy was missing
  /// two terms — the butcher's lift on the base and the day rule's factor —
  /// so the number printed on the card read low after any butcher rung and
  /// was out by anything from 0.85x to 1.5x on every rule day from the fourth
  /// on. The card is the thing the whole game is read from; it cannot be the
  /// one number nobody checks.
  ///
  /// It counts what was *asked for* rather than what went in, which is the
  /// one place it may differ from [_anaUrunGeliri]: the bonus an unmentioned
  /// ingredient earns is not a promise, so a quote must not include it.
  int siparisDegeri(Order order) {
    final kasap = Balance.kasapPayi * progress.unlocks.kasapKademesi;
    final taban = Balance.income(
      (order.tip == ProductKind.durum
              ? Balance.durumBase
              : Balance.porsiyonBase) +
          kasap,
      day,
      ingredients: order.ister.length,
    );
    return (taban * order.musteriTipi.odemeCarpani * kural.odeme).round();
  }

  int _anaUrunGeliri(Product urun, CustomerKind tipi) {
    // Better mince lifts the base the day multiplies, so it compounds with
    // the day rather than sitting on top as a flat tip.
    final kasap = Balance.kasapPayi * progress.unlocks.kasapKademesi;
    final taban = switch (urun) {
      WrapProduct(:final durum) => Balance.income(
        Balance.durumBase + kasap,
        day,
        ingredients: durum.malzemeler.length,
      ),
      PlateProduct(:final porsiyon) => Balance.income(
        Balance.porsiyonBase + kasap,
        day,
        ingredients: porsiyon.bilesenler.length,
      ),
      _ => 0,
    };
    // Applied to the main product only: an extra is the same baklava
    // whoever asked for it.
    return (taban * tipi.odemeCarpani * kural.odeme).round();
  }

  void _ayril(int index, {required bool memnun}) {
    final customer = musteriler[index];
    if (customer == null) return;
    musteriler[index] = null;
    ayrilanlar.add(
      Departure(slot: index, hal: customer.cikisHali, hiz: customer.hiz),
    );

    // They pay on the way out, onto the ledge they were standing at. Nothing
    // reaches the till until somebody picks it up — and the clock on it
    // restarts, so a second payment onto the same spot is not half-swept.
    if (customer.odenen > 0) {
      altin[index] = CoinPile(
        (altin[index]?.miktar ?? 0) + customer.odenen,
        tip: _random.nextInt(CoinPile.tipler.length),
        kasa: progress.unlocks.kasaKademesi,
      );
    }

    if (memnun) {
      memnunMusteri++;
      _gunlukHedef();
    } else {
      kizginSayisi++;
      tempo.musteriKizdi();
      _cue(DayEvent.musteriKizgin, yeri(index));
    }
    onEvent(memnun ? DayEvent.musteriMemnun : DayEvent.musteriKizgin);
    _sonrakiGelis = math.max(_sonrakiGelis, _gelisAraligi);
    onChanged();
  }

  // --- Where things go ---

  /// Removes what was picked up from wherever it was sitting. Called only on
  /// a successful drop, so a drop that fails needs no undo.
  void _consume(Carried held) {
    switch (held) {
      case CookedMeat(:final slot):
        mangal[slot].bosalt();
      case FinishedProduct(fromSource: false, :final origin, :final slot):
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
    if (held is! FinishedProduct || held.fromSource) return;
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
