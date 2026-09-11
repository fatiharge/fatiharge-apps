import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart' hide Quad;
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Curves, IconData, Icons;
import 'package:kiyma/config/dev.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/gesture.dart';
import 'package:kiyma/domain/model/carried.dart';
import 'package:kiyma/domain/model/customer_kind.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/quad.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/gold_text.dart';
import 'package:kiyma/presentation/render/bubble.dart';
import 'package:kiyma/presentation/render/customer_figure.dart';
import 'package:kiyma/presentation/render/effects.dart';
import 'package:kiyma/presentation/render/figure.dart';
import 'package:kiyma/presentation/render/glyphs.dart';
import 'package:kiyma/presentation/render/grill.dart';
import 'package:kiyma/presentation/render/halo.dart';
import 'package:kiyma/presentation/render/notice.dart';
import 'package:kiyma/presentation/render/painter.dart';
import 'package:kiyma/presentation/render/skewer.dart';
import 'package:kiyma/presentation/render/tempo_bar.dart';
import 'package:kiyma/presentation/render/usta_acting.dart';
import 'package:kiyma/presentation/render/usta_figure.dart';

/// The whole counter: every pixel of the game world and every gesture on it.
///
/// One component rather than a tree of them. The scene is a single painting
/// with a fixed draw order and one thing in the hand at a time, so a tree
/// would buy component lifecycle management for a z-order this file can state
/// in eight lines.
class CounterComponent extends PositionComponent with DragCallbacks {
  CounterComponent({
    required this.scene,
    required this.assets,
    required this.halos,
    required this.run,
    required this.onPause,
    required this.ceviri,
    this.visible,
  }) : super(size: Vector2(scene.size.width, scene.size.height));

  final SceneData scene;
  final GameAssets assets;
  final Halos halos;
  final DayRun run;
  final VoidCallback onPause;

  /// No panel anywhere. Everything the counter says is said by an object in
  /// the room: the time by the clock on the wall, the day by the calendar
  /// under it, the tempo by a heat gauge hung over the grill it measures,
  /// and the money by the cash box on the wall behind the till.
  ///
  /// A floating plate is the single loudest thing on a screen that is
  /// otherwise a painted kitchen, and it was reading as an app drawn on top
  /// of a game. The cost of losing it is that the numbers take a fraction
  /// longer to find; what is bought is that the scene is the whole screen.
  ///
  /// The left wall above the grill is the only large clear area in the
  /// scene — the counter surface is booked end to end — so the two
  /// instruments hang there, one above the other, beside the calendar.

  /// Above the calendar, and small: it is a tally, not a headline. The wall
  /// already carries a gauge and a calendar, and a third large object on it
  /// was reading as a row of panels.

  /// The one control that is not a kitchen object, so it is put where no
  /// drag ever goes: the bottom corner, past the end of the counter.
  static const _pause = Rect.fromLTWH(966, 508, 50, 50);

  /// The band above the heads, which the hand never enters. The tickets used
  /// to sit beside each face, in the middle of every drag.
  static const _ticket = Size(148, 78);

  /// What a card with nothing to constrain shrinks to: the band and the
  /// torn edge, and no empty room between them.
  static const _ticketBare = 46.0;
  static const _ticketTop = 10.0;

  static const Map<TempoBand, Color> _tempoColours = {
    TempoBand.soguk: Color(0xFF6C8AA6),
    TempoBand.normal: Color(0xFFCBA23C),
    TempoBand.isiniyor: Color(0xFFE8862A),
    TempoBand.ates: Color(0xFFE0452A),
  };

  /// Areas whose contents change during play, so their idle art is never the
  /// whole story and is drawn by the passes further down.
  static const _dynamic = {
    'mangal_alani',
    'durum_bekleme',
    'bardak_bekletme',
    'tabak_hazirlama',
    'durum_hazirlama',
  };

  // What a slot is doing, in one badge. A tick rather than a clock on the
  // ready one: green and a clock reads as "waiting", and what the player has
  // to know is that this skewer is done and the ring is running out.
  static const ({Color lit, Color dark, IconData icon}) _cooking = (
    lit: Color(0xFFE87A28),
    dark: Color(0xFF4A1712),
    icon: Icons.local_fire_department_rounded,
  );
  static const ({Color lit, Color dark, IconData icon}) _ready = (
    lit: Color(0xFFFFD32B),
    dark: Color(0xFF3D2E05),
    icon: Icons.check_rounded,
  );

  static const _want = Color(0xFF6FCF7C);
  static const _avoid = Color(0xFFE0574A);

  static const ({Color lit, Color dark, IconData icon}) _burnt = (
    lit: Color(0xFFD93B2B),
    dark: Color(0xFF2A1310),
    icon: Icons.priority_high_rounded,
  );

  /// Turns a key into the player's own language. The counter draws its own
  /// text and must not carry any: a hardcoded line here is a line that never
  /// gets translated, and there is a test that says so.
  final String Function(String) ceviri;

  /// Where the lesson's skip button was last drawn, so a touch can find it.
  Rect _atlaKutusu = Rect.zero;

  /// What the camera can see, in scene units. The bin corners are placed
  /// against this rather than against the design box, so they land in the
  /// corners of the screen on a phone whose shape is not 16:9.
  final Rect Function()? visible;

  /// How open the bin corners are, 0..1. Eased rather than switched: two
  /// panels appearing the instant a finger closes reads as a glitch.
  double _cop = 0;

  /// Everything short-lived the counter draws.
  /// Seeded: a golden that renders a pool has to be the same picture twice.
  late final Effects fx = Effects(assets, random: math.Random(7));

  /// The seams effects need: a moment of slowed time on a hit, and a room
  /// that can be knocked. The instrument is drawn outside the shake, so it
  /// stays bolted to the screen.
  double _freeze = 0;
  double _shake = 0;
  double _shakeFor = 0;

  /// The last number written on the slate, and how long the chalk has been
  /// wet. Chalk does not roll: it is wiped and put back.
  int _yazilan = -1;
  double _yazma = 0;

  static const _yazmaSuresi = 0.42;

  Offset _last = Offset.zero;
  Offset _start = Offset.zero;

  /// Where the carried thing is drawn, always a little behind the finger.
  Offset _held = Offset.zero;
  double _elapsed = 0;

  /// How far this drag has ever got from where it started.
  double _travel = 0;

  @override
  void update(double dt) {
    // Nothing moves behind the pause card. `DayRun.tick` already returns
    // early, but `_elapsed` kept climbing, so every halo and shine went on
    // breathing over a frozen game.
    if (run.duraklatildi) return;
    _elapsed += dt;

    // Hit-stop: the world crawls for a few frames on a hit while the pulses
    // keep breathing, which is what makes a serve land. `Dev.hiz` is 1 in
    // anything but a debug build.
    if (_freeze > 0) {
      _freeze -= dt;
      run.tick(dt * 0.12 * Dev.hiz);
    } else {
      run.tick(dt * Dev.hiz);
    }

    _tempoDurumu.tick(dt, run.tempo);
    if (run.tempo.degisimKalan > 1.05 && _tempoDurumu.halka <= 0) {
      _tempoDurumu.darbe(
        run.tempo.deger,
        _tempoKasa.left + _tempoKasa.height * .71,
        _tempoKasa.width - _tempoKasa.height * .85,
      );
    }

    final area = visible?.call();
    if (area != null) run.gorunurAlan = area;
    final wanted = run.copeAtilabilir ? 1.0 : 0.0;
    _cop += (wanted - _cop) * (1 - math.exp(-16 * dt));

    if (_shake > 0) _shake -= dt;
    _susan.updateAll((_, kalan) => kalan - dt);
    // Set here rather than while drawing: the usta is painted eight passes
    // before the lesson is, so a target handed over during the lesson's own
    // render arrives a frame late — and on a still frame it never arrives.
    final ders = run.ogretmen;
    final dersHedefi = ders == null || ders.bitti || ders.adim?.hedef == null
        ? null
        : scene.maybe(ders.adim!.hedef!)?.quad.bounds.center;
    _usta
      ..isaret = dersHedefi
      ..konusma(acik: run.ogretmen?.adim != null && !run.ogretmen!.bitti)
      ..tick(
        dt,
        // Nobody waiting and nothing cooking. It is the only thing he is told
        // about the counter, and it buys one beat: the yawn.
        bosTezgah:
            run.musteriler.every((c) => c == null) &&
            run.mangal.every((s) => s.bos),
      );
    fx.update(dt);
    _drain();
    _emit(dt);

    if (_yazilan != run.progress.para) {
      _yazilan = run.progress.para;
      _yazma = _yazmaSuresi;
    } else if (_yazma > 0) {
      _yazma -= dt;
    }

    final target = run.carried == null ? run.carriedAt : run.carriedAt;
    _held += (target - _held) * (1 - math.exp(-22 * dt));
  }

  /// What each event is called on screen, and in what colour.
  ///
  /// The four that are missing are missing on purpose. `kabul` fires once per
  /// line item — 114 times in a measured day-30 run — `musteriGeldi` and
  /// `musteriMemnun` once per customer at about one every four seconds, and
  /// `tempoBonusu` on very nearly every move once the meter is pinned. A
  /// badge on any of them is a badge that is always on screen, which is a
  /// badge nobody reads. Each already has its own answer: the coins, the
  /// ring, the meter, the person walking away happy.
  static const _soylenen = <DayEvent, (String, BildirimTonu)>{
    DayEvent.musteriKizgin: ('olay.musteri_kizgin', BildirimTonu.kotu),
    DayEvent.reddedildi: ('olay.reddedildi', BildirimTonu.kotu),
    DayEvent.yandi: ('olay.yandi', BildirimTonu.kotu),
    DayEvent.altinSupuruldu: ('olay.altin_supuruldu', BildirimTonu.kotu),
    DayEvent.mangalDolu: ('olay.mangal_dolu', BildirimTonu.uyari),
    DayEvent.fikirDegisti: ('olay.fikir_degisti', BildirimTonu.uyari),
    DayEvent.sonSiparis: ('olay.son_siparis', BildirimTonu.uyari),
    DayEvent.gecersiz: ('olay.gecersiz', BildirimTonu.uyari),
    DayEvent.bahsis: ('olay.bahsis', BildirimTonu.iyi),
    DayEvent.gunlukHedef: ('olay.gunluk_hedef', BildirimTonu.iyi),
    DayEvent.seri: ('olay.seri', BildirimTonu.iyi),
  };

  /// How long a kind stays quiet after it has spoken. Everything gets a beat
  /// so one event cannot stack two identical badges; the two a frustrated
  /// thumb can fire four times in two seconds get much longer.
  static const _sessizlik = <DayEvent, double>{
    DayEvent.gecersiz: 2.4,
    DayEvent.mangalDolu: 2.4,
    DayEvent.seri: 1.8,
  };
  static const _sessizlikTaban = 0.45;

  final Map<DayEvent, double> _susan = {};

  /// What he is doing. His own clock and his own state — the rules never see
  /// him, and nothing he does reaches them.
  final UstaYonetmeni _usta = UstaYonetmeni();

  /// Says one thing, at the place it is about, unless it has just said it.
  void _soyle(Cue cue) {
    final kayit = _soylenen[cue.kind];
    if (kayit == null) return;
    // The first two mis-moves in a row are answered by the region flashing
    // red and by nothing else. A sentence about a slip that cost nothing is
    // nagging, and this is the one event a moving thumb produces by itself.
    if (cue.kind == DayEvent.gecersiz && !run.tempo.affedilmez) return;
    if ((_susan[cue.kind] ?? 0) > 0) return;
    _susan[cue.kind] = _sessizlik[cue.kind] ?? _sessizlikTaban;
    // The money goes in the badge rather than beside it. It used to be a
    // floater at the same anchor, in the same red, and it sat on top of the
    // sentence and rubbed a letter out of it.
    final para = cue.amount == 0
        ? ''
        : '  ${cue.amount > 0 ? '+' : ''}${cue.amount}';
    fx.notice(
      at: cue.at,
      text: '${ceviri(kayit.$1)}$para',
      tone: kayit.$2,
      scene: scene.size,
      keepClear: const [_kese, _keseCip, _tempoKasa],
    );
  }

  /// Turns what the rules said happened into something to look at.
  void _drain() {
    for (final cue in run.cues) {
      _soyle(cue);
      _usta.olay(cue.kind);
      switch (cue.kind) {
        case DayEvent.kabul:
          _serve(cue);
        case DayEvent.yandi:
          _knock(3.4, 0.12);
          fx.burst(
            at: cue.at,
            colour: const Color(0xFF3A302A),
            count: 10,
            speed: 150,
          );
        case DayEvent.musteriKizgin:
          _knock(6, 0.3);
        case DayEvent.altinSupuruldu:
          fx.burst(
            at: cue.at,
            colour: const Color(0xFF8E8578),
            count: 8,
            speed: 90,
            up: math.pi / 2,
            gravity: 120,
          );
        // Paid, and until now paid silently: the purse went up and nothing
        // on screen said where from. They are not a service — no freeze, no
        // knock — so they get the flight and the ring and nothing else.
        case DayEvent.bahsis || DayEvent.seri || DayEvent.gunlukHedef:
          fx
            ..ring(at: cue.at, colour: const Color(0xFFFFD98A))
            ..coins(from: cue.at, to: _kese.center);
        case _:
          break;
      }
    }
    run.cues.clear();
  }

  /// The one hit in the game, given the weight of one.
  void _serve(Cue cue) {
    final band = _tempoColours[run.tempo.hal]!;
    final to = cue.to;
    _freeze = to == null ? 0.04 : 0.07;
    if (to != null) _knock(4, 0.18);

    final asset = cue.asset;
    if (asset != null && to != null) {
      fx.flight(from: cue.at, to: to, asset: asset, width: 74);
    }
    fx
      ..ring(at: cue.at, colour: band)
      ..burst(at: cue.at, colour: const Color(0xFFF5E9D7))
      ..burst(at: cue.at, colour: band, count: 8, speed: 190)
      ..floater(
        at: (to ?? cue.at) - const Offset(0, 24),
        text: '+${cue.amount}',
        colour: const Color(0xFFFFE9B0),
        size: 24,
      );
    if (cue.asset == 'altin') {
      // Into the slot, not onto a panel.
      fx.coins(from: cue.at, to: _kese.center);
    }
  }

  void _knock(double amount, double seconds) {
    _shake = seconds;
    _shakeFor = seconds;
    _shakeAmount = amount;
  }

  double _shakeAmount = 0;

  /// The kitchen, doing what a kitchen does whether or not anybody touches
  /// it: smoke off the coals, steam off what is ready.
  void _emit(double dt) {
    _sinceSmoke += dt;
    if (_sinceSmoke < 0.16) return;
    _sinceSmoke = 0;

    final slots = scene['mangal_alani'].slots;
    for (var i = 0; i < run.mangal.length; i++) {
      final slot = run.mangal[i];
      if (!slot.unlocked || slot.bos) continue;
      final at = slots[i].center;
      if (slot.yanmis) {
        fx.puff(
          at: at,
          asset: 'duman',
          tint: const Color(0xFF2A2320),
          life: 3.4,
          from: 18,
          to: 62,
          rise: 150,
          peak: 0.7,
        );
      } else if (slot.durum == Doneness.pismis) {
        fx.puff(
          at: at,
          asset: 'buhar',
          life: 1.4,
          from: 8,
          to: 24,
          rise: 44,
          peak: 0.4,
        );
      } else {
        fx.puff(at: at, asset: 'duman', peak: 0.45, from: 12, to: 40);
      }
    }

    if (run.durumIstasyonu?.etli ?? false) {
      fx.puff(
        at: scene['durum_hazirlama'].quad.center - const Offset(0, 26),
        asset: 'buhar',
        life: 1.5,
        from: 8,
        to: 22,
        rise: 40,
        peak: 0.35,
      );
    }
  }

  double _sinceSmoke = 0;

  // --- Gestures (design doc 13: tap, drag, upward flick — nothing else) ---

  /// Scene coordinates from a point in the game widget.
  ///
  /// Not `localPosition`: Flame fills that in only while an event is being
  /// delivered by hit test, and a drag that wanders off the component still
  /// has to report where the finger is.
  Offset _scene(Vector2 canvas) =>
      findGame()!.camera.globalToLocal(canvas).toOffset();

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _start = _last = _scene(event.canvasPosition);
    _travel = 0;
    run.beginDrag(_start);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _last = _scene(event.canvasEndPosition);
    _travel = furthest(_travel, _start, _last);
    run.carriedAt = _last;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    switch (classifyTouch(start: _start, end: _last, maxTravel: _travel)) {
      case TouchKind.tap:
        // A tap arrives as a drag that never moved, so by now the source has
        // already been picked up. Put it back before treating it as a tap, or
        // every touch on a tray reads as a drop onto itself.
        run.cancelDrag();
        // A lesson owns the touch before the counter does: its own button,
        // and then the whole screen while the usta is only talking.
        if (run.ogretiliyor) {
          if (_atlaKutusu.contains(_start)) {
            run.dersiAtla();
            return;
          }
          if (run.ogretmen!.dokunusBekliyor) {
            run.dersiIlerlet();
            return;
          }
        }
        if (_pause.contains(_start)) {
          onPause();
          return;
        }
        run.tap(_start);
      case TouchKind.drag:
        if (run.carried != null) run.endDrag(_last);
      case TouchKind.flick:
        if (run.carried != null) {
          run.endDrag(_last);
          return;
        }
        run.flickUp(_start);
      case TouchKind.none:
        run.cancelDrag();
    }
  }

  /// A cancelled pointer is not a finished drag.
  ///
  /// Flame's default body for this is `onDragEnd(event.toDragEnd())`, so the
  /// notification shade coming down mid-touch would run the whole
  /// classification on wherever the finger happened to be: binning a wrap,
  /// opening the pause menu, rolling a durum. Only the mixin's own bookkeeping
  /// is wanted from `super`.
  @override
  // The super call this asks for is the thing being avoided; the half of it
  // that matters is made by hand above.
  // ignore: must_call_super
  void onDragCancel(DragCancelEvent event) {
    super.onDragEnd(event.toDragEnd());
    run.cancelDrag();
  }

  // --- Drawing ---

  @override
  void render(Canvas canvas) {
    // Clipped to the design box. The camera is no longer a 16:9 window, so
    // without this a customer still walking in from off-stage is drawn out
    // in the margin, on top of the blurred room.
    // The room is knocked, the instrument is not: a HUD that shakes with the
    // scene reads as a broken screen rather than as an impact.
    canvas
      ..save()
      ..clipRect(Offset.zero & Size(size.x, size.y))
      ..save();
    if (_shake > 0) {
      final left = _shakeFor <= 0 ? 0.0 : _shake / _shakeFor;
      canvas.translate(
        math.sin(_elapsed * 61) * _shakeAmount * left,
        math.cos(_elapsed * 47) * _shakeAmount * left * 0.6,
      );
    }
    _renderScene(canvas);
    _renderWall(canvas);
    // Hung on the wall, so it takes the knock with the room.
    _renderTempoBar(canvas);
    _renderPara(canvas);
    // Somebody still crossing the shop passes behind what is standing on the
    // counter; by the time they are at their place nothing is in front of
    // them anyway, so the two passes never disagree about one customer.
    _renderMovers(canvas);
    _renderSources(canvas);
    _renderMangal(canvas);
    // Smoke passes in front of the skewers and behind everything on the
    // counter, which is where smoke is.
    fx.render(canvas, EffectLayer.room);
    _renderDurum(canvas);
    _renderTabak(canvas);
    _renderShelves(canvas);
    _renderSeated(canvas);
    _renderGold(canvas);
    fx.render(canvas, EffectLayer.counter);
    _renderCarried(canvas);
    _renderFlashes(canvas);
    _renderLight(canvas);
    canvas.restore();

    fx.render(canvas, EffectLayer.over);
    // Outside the knock, alone: the one thing that has to be in the same
    // place every frame is the button that stops the game.
    _renderPause(canvas);
    canvas.restore();

    // Outside the clip on purpose: the corners belong to the screen, not to
    // the design box, and on a wide phone the box does not reach the edge.
    _renderCopKoseleri(canvas);
    _renderDers(canvas);
  }

  /// The usta, teaching on the counter rather than on a card.
  ///
  /// A card between runs can only say things; here he can point, and the run
  /// waits until the thing is actually done. The bubble crosses to the other
  /// end of the scene when the target is under it — a tutorial that covers
  /// what it is pointing at is worse than none.
  void _renderDers(Canvas canvas) {
    final ogretmen = run.ogretmen;
    if (ogretmen == null || ogretmen.bitti) {
      _atlaKutusu = Rect.zero;
      return;
    }
    final adim = ogretmen.adim!;
    final hedef = adim.hedef == null ? null : scene.maybe(adim.hedef!);

    if (hedef != null) {
      _breathing(canvas, hedef.quad.bounds.center, () {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            hedef.quad.bounds.inflate(7),
            const Radius.circular(12),
          ),
          Paint()
            ..color = const Color(
              0xFFFFC24A,
            ).withValues(alpha: 0.55 + _pulse * 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      });
    }
    // Everything the player has to be able to see while the usta talks. The
    // gauge and the money are on the list because they are drawn here rather
    // than in the scene, so nothing else knows they are in the way; the wall
    // pair is on it because a step with nothing to touch has no target to
    // avoid. The prep areas count only while they hold something — an empty
    // board is not work, and treating it as work leaves the bubble nowhere.
    final dolu = <Rect>[
      if (hedef != null) hedef.quad.bounds,
      _tempoKasa.inflate(_tempoKasa.height * .4),
      _kese.expandToInclude(_keseCip),
      // The one control on the counter. A bubble over it is a run that
      // cannot be paused until the usta has finished talking.
      _pause,
      // And the man himself: a bubble over the face that is speaking is the
      // one placement worse than all the others.
      const Rect.fromLTRB(40, 140, 300, 300),
      // The working surface. Every one of these steps ends in a drag across
      // it, and the empty corners of the room are all on it — which is how
      // the first pass put "pick up the flatbread" on top of the flatbread.
      if (scene.maybe('mangal_alani') case final bolge?)
        bolge.quad.bounds.inflate(24),
      Rect.fromLTRB(250, 386, size.x, size.y),
      for (final ad in const ['duvar_saati', 'duvar_takvimi'])
        if (scene.maybe(ad) case final bolge?) bolge.quad.bounds,
      if (run.durumIstasyonu != null)
        if (scene.maybe('durum_hazirlama') case final bolge?) bolge.quad.bounds,
      if (run.tabakIstasyonu != null)
        if (scene.maybe('tabak_hazirlama') case final bolge?) bolge.quad.bounds,
      if (run.bekleme.any((urun) => urun != null))
        if (scene.maybe('bekleme_alani') case final bolge?) bolge.quad.bounds,
      for (var i = 0; i < run.musteriler.length; i++)
        if (run.musteriler[i] != null) ...[
          if (scene.maybe('musteri_slot_${i + 1}') case final bolge?)
            bolge.quad.bounds,
          // The ticket over their head, which is the thing being read.
          Rect.fromLTWH(
            math.max(
              306,
              scene['musteri_slot_${i + 1}'].quad.bounds.center.dx -
                  _ticket.width / 2,
            ),
            _ticketTop,
            _ticket.width,
            _ticket.height,
          ),
        ],
    ];

    final metin = ceviri(adim.metin ?? 'ders.${ogretmen.ders.id}.${adim.id}');
    final boyut = balonBoyu(metin);
    // His mouth, breathing with him.
    final agiz = Offset(ustaMerkez + 6, 262 + _usta.poz(_elapsed).dy);
    final cerceve = Rect.fromLTWH(0, 0, size.x, size.y);
    var kasa = Rect.zero;
    var enAz = double.infinity;
    for (final aday in balonYerleri(Size(size.x, size.y), boyut)) {
      var ceza = 0.0;
      for (final bolge in dolu) {
        final kesisim = aday.intersect(bolge);
        if (!kesisim.isEmpty) ceza += kesisim.width * kesisim.height;
      }
      // Off the edge counts as covered, three times over: a sentence half
      // past the frame is not a sentence, and on a tall phone the design box
      // does not reach the glass.
      final ic = aday.intersect(cerceve);
      ceza += (aday.width * aday.height - ic.width * ic.height) * 3;
      // And it wants to be beside him. Without this the empty corner always
      // won — nothing overlaps nothing — and the man doing the talking stood
      // at one end of the room with his words at the other.
      ceza += (aday.center - agiz).distance * 34;
      if (ceza < enAz) {
        enAz = ceza;
        kasa = aday;
      }
    }

    balonCiz(
      canvas,
      kasa,
      yazi: metin,
      agiz: agiz,
      adim: ogretmen.sira,
      toplam: ogretmen.toplam,
    );

    // Out of the bubble and into the corner furthest from it: inside, it was
    // a button in the middle of a sentence, and the sentence had to be short
    // enough to leave room for it.
    // Bottom corner, on the side the bubble is not: the top corners are the
    // meter and the clock, and a skip button over either of them is a skip
    // button the player hits while trying to read the time.
    _atlaKutusu = kasa.center.dx > size.x / 2
        ? Rect.fromLTWH(20, size.y - 54, 76, 34)
        : Rect.fromLTWH(size.x - 96, size.y - 54, 76, 34);
    drawKey(canvas, _atlaKutusu, const Color(0xFF6E6155));
    drawText(
      canvas,
      ceviri('tanitim.atla'),
      _atlaKutusu.center,
      size: 15,
      weight: 800,
      family: 'Rubik',
      center: true,
      middle: true,
      color: const Color(0xFFFFF6E8),
    );

    // A step with nothing to do is the usta talking: the whole screen is the
    // button.
    if (!ogretmen.dokunusBekliyor) return;
    drawGlyph(
      canvas,
      Icons.touch_app_rounded,
      Offset(kasa.right - 26, kasa.bottom - 20),
      24,
      const Color(0x662E2A26),
    );
  }

  /// The bin, as two corners that open when there is something to throw.
  ///
  /// It used to be a bucket painted on the floor by the grill. A bucket has
  /// to stand somewhere: the only free floor put it behind the grill in
  /// depth and half a counter away from the shelf, so binning a refused wrap
  /// was a drag across the whole scene. These are under the thumb already
  /// holding the thing, and they cost nothing when the hand is empty.
  void _renderCopKoseleri(Canvas canvas) {
    if (_cop <= 0.01) return;
    final corners = run.copKoseleri;
    for (final (i, kose) in corners.indexed) {
      final over = kose.contains(run.carriedAt);
      // Slides in from its own corner, so each one reads as belonging to the
      // edge it came from.
      final slide = (1 - _cop) * 46;
      final rect = kose.translate(i == 0 ? -slide : slide, slide);
      final inner = Radius.circular(26 * _cop);
      final shape = RRect.fromRectAndCorners(
        rect,
        topLeft: i == 0 ? Radius.zero : inner,
        topRight: i == 0 ? inner : Radius.zero,
      );
      final lit = over || run.copCagiriyor;
      canvas
        ..drawRRect(
          shape,
          Paint()
            ..color = (over ? const Color(0xFFE0452A) : const Color(0xFF241D18))
                .withValues(alpha: (over ? 0.94 : 0.8) * _cop),
        )
        ..drawRRect(
          shape.deflate(6),
          Paint()
            ..color = const Color(
              0xFFF7EEDF,
            ).withValues(alpha: (lit ? 0.9 : 0.4) * _cop * (lit ? _pulse : 1))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      drawGlyph(
        canvas,
        Icons.delete_outline_rounded,
        rect.center,
        52 * (over ? 1.15 : 1),
        const Color(0xFFF7EEDF).withValues(alpha: _cop),
      );
    }
  }

  /// What the room is made of besides its paint: a vignette that pulls the
  /// eye in, coals that breathe, and the whole kitchen taking the colour of
  /// the tempo — grey-blue and dead when it is cold, warm when it is not.
  void _renderLight(Canvas canvas) {
    final stage = Offset.zero & Size(size.x, size.y);
    final tempo = run.tempo.oran;

    canvas
      ..drawRect(
        stage,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = Color.lerp(
            const Color(0x0C1B3A5E),
            const Color(0x18FF7A1F),
            tempo,
          )!,
      )
      ..drawRect(
        stage,
        Paint()
          ..shader = Gradient.radial(
            stage.center,
            size.x * 0.62,
            const [Color(0x00000000), Color(0x59140F0C)],
            const [0.5, 1],
          ),
      );

    // The last twenty seconds, closing in.
    if (run.kalanSure < 20 && run.kalanSure > 0) {
      final urgency =
          (1 - run.kalanSure / 20) * (0.6 + 0.4 * math.sin(_elapsed * 6));
      canvas.drawRect(
        stage,
        Paint()
          ..shader = Gradient.radial(
            stage.center,
            size.x * 0.6,
            [
              const Color(0x00000000),
              const Color(0xFFD93B2B).withValues(alpha: 0.22 * urgency),
            ],
            const [0.45, 1],
          ),
      );
    }
  }

  void _renderScene(Canvas canvas) {
    for (final layer in scene.layers) {
      // Between the wall and the grill: the mangal is painted over him, and
      // that is the whole of what puts him behind it.
      if (layer.name == 'mangal_katman') {
        _renderSef(canvas);
        // The grill is drawn, not blitted: the region used to be fitted to
        // the picture, so moving a skewer meant refitting art. Now the top
        // face IS the region and the slots are that face divided.
        mangalCiz(
          canvas,
          scene['mangal_alani'].quad,
          t: _elapsed,
          isi: _mangalIsisi,
        );
        continue;
      }
      final image = assets[layer.src];
      if (image == null) continue;
      // The painted room bleeds a little, so a knock cannot expose a strip
      // the scene never drew. scene.json is generated; this belongs here.
      final rect = layer.z == 0 ? layer.rect.inflate(16) : layer.rect;
      drawInQuad(canvas, image, Quad.fromRect(rect), AssetFit.doldur);
    }
  }

  void _renderSources(Canvas canvas) {
    for (final region in scene.regions) {
      final asset = region.asset;
      if (asset == null ||
          region.category == 'dekor' ||
          _dynamic.contains(region.name) ||
          !run.progress.unlocks.shows(region.name)) {
        continue;
      }
      final image = assets[asset];
      if (_nudging(region.name)) {
        _renderNudge(canvas, region, image);
        continue;
      }
      if (image != null) drawInQuad(canvas, image, region.quad, region.fit);
    }
  }

  /// The three places the counter points at, and why.
  ///
  /// An empty grill or an empty wrap station stalls a line and costs nothing
  /// to notice. Reaching for a rolled wrap says the player has not seen that
  /// the paper is a step. None of it is a rule change — only the counter
  /// answering.
  bool _nudging(String region) => switch (region) {
    'malzeme_kiyma' => run.mangalCagiriyor,
    'lavas_kaynak' => run.lavasCagiriyor,
    'kagit_kaynak' => run.kagitCagiriyor > 0,
    _ => false,
  };

  /// The region's own art, breathing inside a halo of its own shape.
  void _renderNudge(Canvas canvas, SceneRegion region, Image? image) {
    if (image == null) return;
    _breathing(canvas, region.quad.center, () {
      _halo(canvas, region.name, region.quad);
      drawInQuad(canvas, image, region.quad, region.fit);
    });
  }

  void _halo(Canvas canvas, String key, Quad quad) {
    final baked = halos[key];
    if (baked == null) return;
    drawHalo(canvas, baked, quad.bounds, Halos.pad, _pulse);
  }

  /// `0..1`, twice a second or so: the beat everything that asks shares.
  double get _pulse => 0.55 + 0.45 * math.sin(_elapsed * 6);

  /// Runs [draw] scaled about [centre] on that same beat.
  void _breathing(Canvas canvas, Offset centre, void Function() draw) {
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..scale(0.96 + 0.09 * _pulse)
      ..translate(-centre.dx, -centre.dy);
    draw();
    canvas.restore();
  }

  /// How hard the fire is going: a lit grill with meat on it, hotter the
  /// fuller it is. One number so the coals, the flames and the room's glow
  /// cannot disagree about it.
  double get _mangalIsisi {
    final busy = run.mangal.where((s) => s.unlocked && !s.bos).length;
    return (0.34 + busy * 0.18).clamp(0.0, 1.0);
  }

  void _renderMangal(Canvas canvas) {
    final region = scene['mangal_alani'];
    final slots = region.slots;

    // Coals that breathe, and burn hotter the fuller the grill is.
    final busy = run.mangal.where((s) => s.unlocked && !s.bos).length;
    final burning = run.mangal.any((s) => s.yanmis);
    // Its own slow, non-harmonic beat rather than `_pulse`: coals breathing
    // in lockstep with the hint halos read as a mechanism, not a fire.
    final breath =
        0.5 +
        0.28 * math.sin(_elapsed * 2.1) +
        0.22 * math.sin(_elapsed * 3.37);
    final heat = (0.35 + busy * 0.2).clamp(0.0, 1.0) * (0.62 + 0.38 * breath);
    canvas.drawCircle(
      region.quad.center,
      140,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = Gradient.radial(
          region.quad.center,
          140,
          [
            (burning ? const Color(0xFFD93B2B) : const Color(0xFFFF7A1F))
                .withValues(alpha: 0.26 * heat),
            const Color(0x00000000),
          ],
        ),
    );
    for (var i = 0; i < slots.length; i++) {
      final slot = run.mangal[i];
      if (!slot.unlocked) continue;
      final durum = slot.durum;
      if (durum == null || run.lifted('mangal_alani', i)) continue;

      // Drawn, not picked from four pictures: cooking is continuous and the
      // pictures were not. `kavrulma` is the second ramp — how far into the
      // window to take it we are — so the meat visibly darkens toward burnt
      // instead of switching to a burnt sprite.
      sisCiz(
        canvas,
        // Transposed: the slot is cut across the trough's length, so its u
        // is the width of one bay and a skewer lies along its v. Turned, and
        // turned near-end-first, so the flat tang lands at the front — the
        // end you would reach for.
        Quad(
          slots[i].bottomLeft,
          slots[i].topLeft,
          slots[i].topRight,
          slots[i].bottomRight,
        ),
        kizarma: slot.pismeOrani,
        kavrulma: switch (durum) {
          Doneness.pismis => slot.ilerleme(run.day),
          Doneness.yanmis => 1,
          _ => 0,
        },
      );
      // Filling while it cooks, draining while it is worth taking, and full
      // red once it is only taking up a slot.
      final (dial, value) = switch (durum) {
        Doneness.pismis => (_ready, 1 - slot.ilerleme(run.day)),
        Doneness.yanmis => (_burnt, 1.0),
        _ => (_cooking, slot.pismeOrani),
      };
      // Only the ready one breathes. On a grill of four badges the one that
      // moves should be the one there is something to do about.
      final radius = durum == Doneness.pismis
          ? 13 * (1 + 0.13 * math.sin(_elapsed * 8))
          : 13.0;
      drawDial(
        canvas,
        slots[i].center,
        radius,
        value,
        lit: dial.lit,
        dark: dial.dark,
        icon: dial.icon,
      );
    }

    // Flames last, over the meat: that is where a flame on a mangal is, and
    // drawn under the skewers they read as a glow behind glass.
    alevCiz(canvas, region.quad, _elapsed, _mangalIsisi);
  }

  void _renderDurum(Canvas canvas) {
    final region = scene['durum_hazirlama'];
    final station = run.durumIstasyonu;
    if (station == null || run.lifted('durum_hazirlama')) return;
    final composition = region.composition!;

    // Rolled but unwrapped is a different picture from wrapped: the paper is
    // the step between them and the player has to see which one is missing.
    if (station.kagitli) {
      final paper = assets['doner_bekleme'];
      if (paper != null) drawInQuad(canvas, paper, region.quad, AssetFit.orta);
      _renderContents(canvas, region.quad, WrapProduct(station));
      return;
    }
    if (station.sarili) {
      _layer(canvas, region.quad, composition.finished);
      return;
    }

    for (final layer in composition.base) {
      _layer(canvas, region.quad, layer);
    }
    if (station.etli) _layer(canvas, region.quad, composition.ingredient('et'));
    for (final malzeme in Ingredient.values) {
      final tutam = station.tutam(malzeme);
      if (tutam == 0) continue;
      _layer(
        canvas,
        region.quad,
        composition.ingredient(malzeme.id),
        portion: tutam / station.gerekenTutam,
      );
    }
  }

  void _renderTabak(Canvas canvas) {
    final region = scene['tabak_hazirlama'];
    if (!run.progress.unlocks.shows(region.name)) return;
    final station = run.tabakIstasyonu;
    if (station == null || run.lifted('tabak_hazirlama')) return;
    final composition = region.composition!;

    for (final layer in composition.base) {
      _layer(canvas, region.quad, layer);
    }
    if (station.lavasli) {
      _layer(canvas, region.quad, composition.ingredient('lavas'));
    }
    if (station.etli) _layer(canvas, region.quad, composition.ingredient('et'));
    for (final bilesen in PlateItem.values) {
      final tutam = station.tutam(bilesen);
      if (tutam == 0) continue;
      _layer(
        canvas,
        region.quad,
        composition.ingredient(bilesen.id),
        portion: tutam / station.gerekenTutam,
      );
    }
  }

  /// [portion] below one draws only that much of the layer, from the left:
  /// an ingredient goes on in handfuls, so a third of an onion has to look
  /// like a third of an onion rather than like a whole one.
  void _layer(
    Canvas canvas,
    Quad quad,
    CompositionLayer? layer, {
    double portion = 1,
  }) {
    if (layer == null) return;
    final image = assets[layer.asset];
    if (image == null) return;
    if (portion >= 1) {
      drawCompositionLayer(canvas, image, quad, layer);
      return;
    }
    final bounds = quad.bounds;
    canvas
      ..save()
      ..clipRect(
        Rect.fromLTWH(
          bounds.left,
          bounds.top,
          bounds.width * portion,
          bounds.height,
        ),
      );
    drawCompositionLayer(canvas, image, quad, layer);
    canvas.restore();
  }

  void _renderShelves(Canvas canvas) {
    _renderShelf(canvas);

    final region = scene['bardak_bekletme'];
    if (!run.progress.unlocks.shows(region.name)) return;
    final slots = region.slots;
    for (var i = 0; i < slots.length; i++) {
      final bardak = run.bardakBekletme[i];
      if (bardak == null || run.lifted('bardak_bekletme', i)) continue;

      final empty = assets['bos_bardak'];
      if (empty != null) drawInQuad(canvas, empty, slots[i], AssetFit.alt);

      // The full glass, clipped to how much of it has been poured, so the
      // drink is seen rising rather than appearing.
      final drink = assets[bardak.icecek?.servedAsset ?? ''];
      if (drink == null) continue;
      final bounds = slots[i].bounds;
      canvas
        ..save()
        ..clipRect(
          Rect.fromLTRB(
            bounds.left,
            bounds.bottom - bounds.height * bardak.dolumOrani,
            bounds.right,
            bounds.bottom,
          ),
        );
      drawInQuad(canvas, drink, slots[i], AssetFit.alt);
      canvas.restore();
    }
  }

  /// The one shelf, front to back. Later slots overlap earlier ones, so they
  /// are drawn in order and the newest sits in front.
  void _renderShelf(Canvas canvas) {
    final region = scene['bekleme_alani'];
    final slots = region.slots;
    final capacity = run.progress.unlocks.bekleme;

    for (var i = 0; i < slots.length; i++) {
      if (i >= capacity) continue;
      final urun = run.bekleme[i];
      if (urun == null || run.lifted(region.name, i)) continue;
      final image =
          assets[switch (urun) {
            WrapProduct() => 'doner_bekleme',
            PlateProduct() => 'porsiyon_hazirlama',
            _ => '',
          }];
      if (image != null) drawInQuad(canvas, image, slots[i], AssetFit.alt);
    }

    // The labels go on in a second pass. The slots overlap on purpose, so a
    // chip drawn with its own item is covered by the next one along — which
    // hides the label on exactly the wraps that need one.
    for (var i = 0; i < slots.length; i++) {
      if (i >= capacity) continue;
      final urun = run.bekleme[i];
      if (urun == null || run.lifted(region.name, i)) continue;
      _renderContents(canvas, slots[i], urun);
    }
  }

  /// What is inside something that has stopped showing it.
  ///
  /// A wrapped durum is a paper cylinder and a plated portion is drawn from
  /// one sprite: three on the shelf are the same picture, and the player who
  /// built them forty seconds ago has to remember which is which — while a
  /// customer is asking for the one with no onion. The chip is what a
  /// counter would actually do, which is write it on the paper.
  void _renderContents(Canvas canvas, Quad quad, Product urun) {
    final ids = switch (urun) {
      WrapProduct(:final durum) => [
        for (final m in Ingredient.values)
          if (durum.malzemeler.contains(m)) m.id,
      ],
      PlateProduct(:final porsiyon) => [
        for (final b in PlateItem.values)
          if (porsiyon.bilesenler.contains(b)) b.id,
      ],
      // A baklava is a baklava; there is nothing hidden inside it.
      _ => const <String>[],
    };
    if (ids.isEmpty) return;

    const pitch = 15.0;
    final bounds = quad.bounds;
    final chip = Rect.fromCenter(
      center: Offset(bounds.center.dx, bounds.bottom - 7),
      width: pitch * ids.length + 9,
      height: 19,
    );
    final shape = RRect.fromRectAndRadius(chip, const Radius.circular(9));
    canvas
      ..drawRRect(
        shape.shift(const Offset(0, 2)),
        Paint()..color = const Color(0x552E2A26),
      )
      ..drawRRect(shape, Paint()..color = const Color(0xFFFBF6EC))
      ..drawRRect(
        shape.deflate(0.9),
        Paint()
          ..color = const Color(0xFF2E2A26)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    for (var i = 0; i < ids.length; i++) {
      drawGameGlyph(
        canvas,
        ids[i],
        Offset(chip.left + 4.5 + pitch * (i + 0.5), chip.center.dy),
        13,
      );
    }
  }

  /// A short glow where a touch landed: warm when it took, red when the drop
  /// had nowhere to go.
  void _renderFlashes(Canvas canvas) {
    for (final entry in run.parlama.entries) {
      final region = scene.maybe(entry.key);
      if (region == null) continue;
      final alpha = run.flashAt(entry.key).clamp(0.0, 1.0);
      final colour = entry.value.ok
          ? const Color(0xFFFFE9B0)
          : const Color(0xFFE0574A);
      canvas
        ..drawPath(
          region.quad.toPath(),
          Paint()..color = colour.withValues(alpha: alpha * 0.45),
        )
        ..drawPath(
          region.quad.toPath(),
          Paint()
            ..color = colour.withValues(alpha: alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
    }
  }

  /// What a customer left behind, on the ledge they stood at.
  void _renderGold(Canvas canvas) {
    final region = scene['altin_alani'];
    final slots = region.slots;

    for (var i = 0; i < slots.length; i++) {
      final pile = run.altin[i];
      if (pile == null) continue;
      final image = assets[pile.asset];
      if (image != null) {
        if (pile.aceleli) {
          _breathing(canvas, slots[i].center, () {
            _halo(canvas, Halos.goldKey(pile.asset, i), slots[i]);
            drawInQuad(canvas, image, slots[i], AssetFit.alt);
          });
        } else {
          drawInQuad(canvas, image, slots[i], AssetFit.alt);
        }
      }
      // Above the pile on its own dark tag: gold on gold cannot be read. It
      // goes red for the last seconds before the counter sweeps it up.
      final tag = Offset(slots[i].center.dx, slots[i].bounds.top - 15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: tag + const Offset(0, 8),
            width: 40,
            height: 19,
          ),
          const Radius.circular(6),
        ),
        Paint()
          ..color = pile.aceleli
              ? const Color(0xE6A32718)
              : const Color(0xE62E2A26),
      );
      drawText(
        canvas,
        '${pile.miktar}',
        tag,
        size: 14,
        weight: 800,
        family: 'Rubik',
        center: true,
        color: const Color(0xFFFFE9B0),
      );
    }
  }

  /// The clock and the calendar, hung on the tiled wall.
  ///
  /// They are the room's, not the HUD's: the run is counted down on a clock
  /// that is part of the kitchen, and the day is read off a calendar nailed
  /// up by the grill. Only the numbers are drawn here — the cases are art.
  void _renderWall(Canvas canvas) {
    final clock = scene.maybe('duvar_saati');
    if (clock != null) {
      final bounds = clock.quad.bounds;
      final at = bounds.center;
      final r = math.min(bounds.width, bounds.height) / 2;
      // Last orders is the one thing the clock has to say that the number on
      // it cannot: the doors are shut, and whoever is at the counter is all
      // there is left to earn from.
      final son = run.sonSiparisZamani;
      final late = son || run.kalanSure < 20;
      final face = son
          ? Color.lerp(
              const Color(0xFFFF5A45),
              const Color(0xFFFFC24A),
              _pulse,
            )!
          : late
          ? const Color(0xFFFF5A45)
          : const Color(0xFFE8641A);

      canvas
        // Hung, not floating: a nail, a cord, and the shadow the wall casts
        // under it. Without those three it read as a dial pasted onto the
        // tiles, which is what it was.
        ..drawLine(
          Offset(at.dx, bounds.top - 14),
          Offset(at.dx, bounds.top + 4),
          Paint()
            ..color = const Color(0xFF2E2A26)
            ..strokeWidth = 3,
        )
        ..drawCircle(
          Offset(at.dx, bounds.top - 15),
          4,
          Paint()..color = const Color(0xFF6E6155),
        )
        ..drawCircle(
          at + const Offset(4, 7),
          r,
          Paint()..color = const Color(0x38000000),
        )
        ..drawCircle(at, r, Paint()..color = const Color(0xFF2E2A26))
        ..drawCircle(at, r - 4, Paint()..color = const Color(0xFFC08A3E))
        ..drawCircle(at, r - 11, Paint()..color = const Color(0xFFF7EEDF))
        // The day draining round the bezel. The clock is the run's timer, so
        // the timer is drawn on the clock rather than as a bar somewhere
        // else on the screen.
        ..drawArc(
          Rect.fromCircle(center: at, radius: r - 7.5),
          -math.pi / 2,
          math.pi * 2 * run.sureOrani,
          false,
          Paint()
            ..color = face
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..strokeCap = StrokeCap.round,
        );
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6;
        final dir = Offset(math.sin(a), -math.cos(a));
        canvas.drawLine(
          at + dir * (r - 16),
          at + dir * (r - (i % 3 == 0 ? 22 : 19)),
          Paint()
            ..color = const Color(0x442E2A26)
            ..strokeWidth = i % 3 == 0 ? 2.4 : 1.4,
        );
      }

      final left = run.kalanSure.ceil();
      drawText(
        canvas,
        '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}',
        Offset(at.dx, at.dy - r * 0.3),
        size: r * 0.52,
        weight: 900,
        family: 'Rubik',
        center: true,
        // Beats once a second in the last ten, so the last stretch is felt
        // without looking at the number.
        color: late && _elapsed % 1 < 0.5
            ? const Color(0xFFFF5A45)
            : const Color(0xFF2E2A26),
      );
    }

    final calendar = scene.maybe('duvar_takvimi');
    if (calendar != null) {
      final image = assets['takvim'];
      if (image != null) {
        drawInQuad(canvas, image, calendar.quad, calendar.fit);
      }
      final bounds = calendar.quad.bounds;
      drawText(
        canvas,
        '${run.day}',
        Offset(bounds.center.dx, bounds.top + bounds.height * 0.41),
        size: bounds.height * 0.44,
        weight: 900,
        family: 'Rubik',
        center: true,
        color: const Color(0xFF2E2A26),
      );
    }
  }

  void _renderPause(Canvas canvas) {
    drawKey(canvas, _pause, const Color(0xFF44403A));
    for (final dx in [-7.0, 7.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: _pause.center + Offset(dx, 0),
            width: 8,
            height: 22,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFFFF6E8),
      );
    }
  }

  /// The usta, at his grill.
  ///
  /// He was a jacket, a toque and a circle — the placeholder that stood in
  /// while the characters were unbuilt. He is drawn now, from the same rig as
  /// the customers, and he is painted second of the fifteen things in a
  /// frame: the grill goes over him from y ~430 down, which is what puts him
  /// behind it rather than standing in it.
  void _renderSef(Canvas canvas) => ustaCiz(canvas, _usta.poz(_elapsed));

  /// The takings, as a bag of money under the clock.
  ///
  /// It was a chalk slate on the left wall, and it was two things wrong at
  /// once. It stood where the usta stands now, and a number on a blackboard
  /// is not money — it is a number, and the one before it was a wooden cash
  /// box that read as a sign. A bag of coins needs no reading at all.
  ///
  /// It carries what the slate carried: the amount, the pop when it is
  /// rewritten, the day's progress toward its target as a line under it, and
  /// the meter's payout floating off the top.
  /// Where the money lives, and where collected coins fly to. One constant,
  /// because a coin that lands somewhere other than the bag it goes into is
  /// the kind of thing nobody notices until it looks wrong.
  static const _kese = Rect.fromLTWH(890, 130, 100, 53);
  static const _keseCip = Rect.fromLTWH(892, 172, 96, 28);

  void _renderPara(Canvas canvas) {
    const kese = _kese;
    const cip = _keseCip;

    final image = assets['altin_kese'];
    if (image != null) {
      drawInQuad(canvas, image, Quad.fromRect(kese), AssetFit.orta);
    }

    // Rewritten, not rolled: the number snaps.
    final pop = _yazma <= 0
        ? 0.0
        : Curves.easeOutBack.transform(
            (1 - _yazma / _yazmaSuresi).clamp(0.0, 1.0),
          );
    final scale = _yazma <= 0 ? 1.0 : 1.22 - 0.22 * pop;

    drawPanel(canvas, cip, fill: const Color(0xFF2E2A26));
    canvas
      ..save()
      ..translate(cip.center.dx, cip.center.dy)
      ..scale(scale)
      ..translate(-cip.center.dx, -cip.center.dy);
    drawText(
      canvas,
      goldText(run.progress.para),
      cip.center,
      size: 21,
      weight: 900,
      family: 'Rubik',
      center: true,
      middle: true,
      color: const Color(0xFFFFC24A),
    );
    canvas.restore();

    // How far the day has come toward its target. The slate said it with a
    // chalk line and the box before that flooded with gold; it is the same
    // reading either way, and it belongs beside the money it is about.
    final line = Rect.fromLTWH(cip.left + 6, cip.bottom + 4, cip.width - 12, 3);
    canvas
      ..drawRect(line, Paint()..color = const Color(0x33FFF6E8))
      ..drawRect(
        Rect.fromLTWH(
          line.left,
          line.top,
          line.width * Balance.ratio(run.progress.xp, run.day),
          line.height,
        ),
        Paint()..color = const Color(0xFFFFC24A),
      );

    // What a full meter paid out. It rises from under the bag rather than off
    // the top of it: the clock hangs there, and a number that floats behind a
    // clock face is a number nobody sees.
    if (run.tempoIkramiyeKalan <= 0) return;
    final fade = (run.tempoIkramiyeKalan / 1.2).clamp(0.0, 1.0);
    drawText(
      canvas,
      '+${run.tempoIkramiye}',
      Offset(cip.center.dx, cip.bottom + 6 + fade * 14),
      size: 22,
      weight: 900,
      family: 'Rubik',
      center: true,
      color: const Color(0xFF7BD98A).withValues(alpha: fade),
    );
  }

  /// Everybody crossing the shop, in or out.
  ///
  /// Drawn before what stands on the counter, because that is where they are
  /// walking: behind it. By the time somebody is at their place nothing is in
  /// front of them anyway, so the two passes never disagree about one person.
  void _renderMovers(Canvas canvas) {
    for (var i = 0; i < run.musteriler.length; i++) {
      final customer = run.musteriler[i];
      if (customer == null || customer.yerinde) continue;
      final home = scene['musteri_slot_${i + 1}'].quad;
      // In from the right, decelerating into the slot.
      final left = 1 - customer.varis;
      final from = scene.size.width - home.bounds.left + 40;
      _renderBody(
        canvas,
        home.shift(Offset(from * left * left, 0)),
        customer.hal,
        customer.hiz + i * 0.317,
      );
    }

    for (final leaving in run.ayrilanlar) {
      final home = scene['musteri_slot_${leaving.slot + 1}'].quad;
      // Out the way they came in, picking up speed as they go.
      final gone = leaving.gidis * leaving.gidis;
      final door = scene.size.width - home.bounds.left + 40;
      _renderBody(
        canvas,
        home.shift(Offset(door * gone, 0)),
        leaving.hal,
        leaving.hiz + leaving.slot * 0.317,
      );
    }
  }

  /// How far in somebody has to be before their ticket is readable.
  static const _erkenBilet = 0.3;

  /// The ones standing at the counter, with everything they came with — and
  /// the ticket of whoever is still walking to it.
  ///
  /// The order used to appear only once somebody had arrived, which made the
  /// waiting shelf a guess: there was no way to know what to build ahead
  /// except to build the commonest thing and hope. Reading the ticket on the
  /// way in is what turns the shelf from storage into a plan.
  void _renderSeated(Canvas canvas) {
    for (var i = 0; i < run.musteriler.length; i++) {
      final customer = run.musteriler[i];
      if (customer == null) continue;
      final quad = scene['musteri_slot_${i + 1}'].quad;
      final head = Offset(quad.bounds.center.dx, quad.bounds.top + 26);
      if (customer.yerinde) {
        _renderBody(canvas, quad, customer.hal, customer.hiz + i * 0.317);
        _renderOrder(canvas, head, customer, i);
      } else if (customer.varis > _erkenBilet) {
        _renderOrder(
          canvas,
          head,
          customer,
          i,
          solgun:
              ((customer.varis - _erkenBilet) / (1 - _erkenBilet)).clamp(0, 1) *
              0.7,
        );
      }
    }
  }

  /// Where the counter's ink line runs. The rail art is solid from here down
  /// across the whole width anybody walks, so a body cut here is a body
  /// standing behind it.
  static const _tezgahCizgisi = 226.6;

  /// One customer, drawn rather than blocked in.
  ///
  /// The body used to be a coloured rectangle: the characters were the one
  /// part of the art nobody had drawn. They are geometry now — the same paths
  /// the rig deforms — so the nine states of a visit are a pose and a flush
  /// rather than nine flat colours.
  ///
  /// The counter is a scene layer, painted before anybody has walked in, so
  /// it cannot paint over a body drawn later; the cut does from this side
  /// what the rail cannot do from its own.
  void _renderBody(Canvas canvas, Quad quad, CustomerMood hal, double tohum) {
    final bounds = quad.bounds;
    // Only the counter line clips. Cutting to the seat's own box as well
    // sheared off a swinging arm at the shoulder and took the top off a fez:
    // a body is wider and taller than the slot it stands in. The sides are
    // the scene's, so nothing spills into the letterbox.
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(0, 0, scene.size.width, _tezgahCizgisi));
    musteriCiz(
      canvas,
      kokta: bounds.topLeft,
      figur: _figuru(tohum),
      hal: hal,
      palet: _paleti(tohum),
      t: _elapsed,
      faz: tohum * 6.28,
    );
    canvas.restore();
  }

  /// Which of the fourteen silhouettes this person is. Keyed off the walk
  /// speed, which is already a stable random number the domain hands out per
  /// customer and carries through the walk out.
  String _figuru(double tohum) {
    final f = tohum * 5.77;
    return figurAdlari[((f - f.floorToDouble()) * figurAdlari.length).floor()];
  }

  final Map<double, CustomerPalette> _paletler = {};

  CustomerPalette _paleti(double tohum) => _paletler.putIfAbsent(
    tohum,
    () => CustomerPalette.forSeed(
      tohum,
      ak: figurler[_figuru(tohum)]!.ak,
    ),
  );

  /// The order, as the paper a kebab shop writes it on.
  ///
  /// Three fixed bands in every ticket, always the same size and always in
  /// the same order, so three of them can be read at a glance under time
  /// pressure: what they want, the four ingredients as wanted / forbidden /
  /// unmentioned, and the two extras. The rail is iterated in enum order
  /// rather than set order — a shuffled row cannot be scanned.
  void _renderOrder(
    Canvas canvas,
    Offset head,
    Customer customer,
    int slot, {
    double solgun = 1,
  }) {
    final rect = Rect.fromLTWH(
      math.max(306, head.dx - _ticket.width / 2),
      _ticketTop,
      _ticket.width,
      _wantedAll(customer.order).isEmpty ? _ticketBare : _ticket.height,
    );

    // Arrives rather than appears, and leans a little so a row of them reads
    // as three pieces of paper.
    final settle = (customer.yerindeSure / 0.35).clamp(0.0, 1.0);
    final drop = (1 - Curves.easeOutBack.transform(settle)) * 22;
    // Leaning out from the middle, so three of them read as three pieces
    // of paper rather than one sprite repeated.
    final tilt = (slot - 1) * 0.042;
    final panic = customer.sabirOrani < 0.3;
    final shake = customer.hataKalan > 0
        ? math.sin(customer.hataKalan * 46) * 5
        : 0.0;

    canvas
      ..saveLayer(
        rect.inflate(28),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: solgun),
      )
      ..translate(rect.center.dx + shake, rect.center.dy - drop)
      ..rotate(tilt * settle + (panic ? math.sin(_elapsed * 7) * 0.012 : 0))
      ..scale(0.7 + 0.3 * Curves.easeOutBack.transform(settle))
      ..translate(-rect.center.dx, -rect.center.dy);

    drawTicket(
      canvas,
      rect,
      fill: panic
          ? Color.lerp(
              const Color(0xFFF7EEDF),
              const Color(0xFFF2B9AC),
              0.35 + 0.25 * math.sin(_elapsed * 6),
            )!
          : const Color(0xFFF7EEDF),
    );

    _ticketTab(canvas, rect, customer.order.musteriTipi);
    _ticketHeader(canvas, rect, customer);
    _ticketRail(canvas, rect, customer);

    // Patience, printed along the torn edge.
    drawBar(
      canvas,
      Rect.fromLTWH(rect.left + 8, rect.bottom - 11, rect.width - 16, 6),
      customer.sabirOrani,
      color: Color.lerp(_avoid, _want, customer.sabirOrani)!,
      background: const Color(0x332E2A26),
    );
    canvas.restore();
  }

  /// One glyph per kind of customer, an actual character.
  ///
  /// Material rather than the drawn set: these are the card saying something
  /// about the person, not about the food, and an icon reads as an
  /// annotation where a painted mark would read as an ingredient.
  static const Map<CustomerKind, ({Color renk, IconData glif})> _tipRozeti = {
    CustomerKind.aceleci: (renk: Color(0xFFE0452A), glif: Icons.bolt_rounded),
    CustomerKind.titiz: (
      renk: Color(0xFF5B7C99),
      glif: Icons.checklist_rounded,
    ),
    CustomerKind.comert: (
      renk: Color(0xFF3E9D4C),
      glif: Icons.volunteer_activism_rounded,
    ),
    CustomerKind.kararsiz: (
      renk: Color(0xFF8A63B5),
      glif: Icons.swap_horiz_rounded,
    ),
    CustomerKind.kalabalik: (
      renk: Color(0xFF9A6A2E),
      glif: Icons.groups_rounded,
    ),
  };

  /// The kind of customer, clipped to the top corner of their ticket.
  ///
  /// Outside the paper rather than on it: the card is already three bands of
  /// what they want, and this is not a want — it is who is asking.
  void _ticketTab(Canvas canvas, Rect rect, CustomerKind tipi) {
    final rozet = _tipRozeti[tipi];
    if (rozet == null) return;
    final at = Offset(rect.left + 15, rect.top - 3);
    canvas
      ..drawCircle(
        at + const Offset(1, 2),
        14,
        Paint()..color = const Color(0x552E2A26),
      )
      ..drawCircle(at, 14, Paint()..color = const Color(0xFF2E2A26))
      ..drawCircle(at, 11.5, Paint()..color = rozet.renk);
    drawGlyph(canvas, rozet.glif, at, 15, const Color(0xFFFFF6E8));
  }

  /// The band across the top: what they came for, what else they asked for,
  /// and what the lot is worth.
  ///
  /// The two extras used to have a row of their own under the ingredients,
  /// which put them exactly where the patience bar is drawn — two things
  /// printed on top of each other on the one card that has to be read in a
  /// glance. There is room beside the product for both, and one row fewer is
  /// one row fewer to scan.
  void _ticketHeader(Canvas canvas, Rect rect, Customer customer) {
    final order = customer.order;
    final durum = order.tip == ProductKind.durum;
    final band = Rect.fromLTWH(
      rect.left + 5,
      rect.top + 5,
      rect.width - 10,
      26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(band, const Radius.circular(5)),
      Paint()
        ..color = durum ? const Color(0xFFE2A73C) : const Color(0xFF7C93A8),
    );
    _mark(
      canvas,
      durum ? 'durum' : 'porsiyon',
      Offset(band.left + 17, band.center.dy),
      23,
      done: customer.anaUrunVerildi,
    );
    // A big order is two products on one ticket, so the band carries two
    // marks and each one is ticked off on its own.
    if (order.ikinci case final ikinci?) {
      _mark(
        canvas,
        ikinci.tip == ProductKind.durum ? 'durum' : 'porsiyon',
        Offset(band.left + 38, band.center.dy),
        23,
        done: customer.ikinciVerildi,
      );
    }

    // Dessert always first and drink always second, printed as an empty ring
    // when there is none — so the eye learns one place to look rather than
    // reading a row whose length changes.
    for (final (i, entry) in [
      (order.tatli?.id, customer.tatliVerildi),
      (order.icecek?.id, customer.icecekVerildi),
    ].indexed) {
      final at = Offset(
        band.left + (order.ikinci == null ? 40 : 62) + i * 22,
        band.center.dy,
      );
      final id = entry.$1;
      if (id == null) {
        canvas.drawCircle(
          at,
          8,
          Paint()
            ..color = const Color(0x33FFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        continue;
      }
      _mark(canvas, id, at, 19, done: entry.$2);
    }

    drawText(
      canvas,
      '${_ticketWorth(customer)}',
      Offset(band.right - 8, band.center.dy),
      size: 16,
      weight: 900,
      family: 'Rubik',
      right: true,
      middle: true,
      color: const Color(0xFF2E2A26),
    );
  }

  int _ticketWorth(Customer customer) {
    final order = customer.order;
    var worth = customer.anaUrunVerildi ? 0 : _urunDegeri(order);
    if (order.ikinci case final ikinci? when !customer.ikinciVerildi) {
      worth += _urunDegeri(ikinci);
    }
    final tatli = order.tatli;
    if (tatli != null && !customer.tatliVerildi) {
      worth += Balance.income(Balance.tatliBase[tatli]!, run.day);
    }
    final icecek = order.icecek;
    if (icecek != null && !customer.icecekVerildi) {
      worth += Balance.income(Balance.icecekBase[icecek]!, run.day);
    }
    return worth;
  }

  int _urunDegeri(Order order) =>
      (Balance.income(
                order.tip == ProductKind.durum
                    ? Balance.durumBase
                    : Balance.porsiyonBase,
                run.day,
                ingredients: order.ister.length,
              ) *
              order.musteriTipi.odemeCarpani)
          .round();

  /// Only what was actually asked for: wanted, then forbidden, in enum order.
  ///
  /// It printed all four wells always, so a customer who cared about one
  /// ingredient still handed over a card with three grey boxes on it. The
  /// bonus an unmentioned ingredient earns was printed in those boxes and it
  /// is not worth the clutter — three quarters of every card said nothing.
  static List<String> _wanted(Order order) => [
    for (final id
        in order.tip == ProductKind.durum
            ? Ingredient.values.map((m) => m.id)
            : PlateItem.values.map((b) => b.id))
      if (order.ister.contains(id) || order.istemez.contains(id)) id,
  ];

  /// Both products' constraints on one rail.
  ///
  /// Wrap ingredients and plate components are disjoint sets, so a tomato
  /// can only belong to the wrap and ezme can only belong to the plate —
  /// which is what lets one row carry a big order without having to say
  /// which line each well is for.
  static List<String> _wantedAll(Order order) => [
    ..._wanted(order),
    if (order.ikinci case final ikinci?) ..._wanted(ikinci),
  ];

  void _ticketRail(Canvas canvas, Rect rect, Customer customer) {
    final order = customer.order;
    final ids = _wantedAll(order);
    if (ids.isEmpty) return;

    // Centred rather than spread across the card: the row is one to four
    // wide normally, and a stretched pair reads as a card with holes in it.
    // A big order brings more, so the pitch closes rather than the row
    // running off the paper.
    final pitch = math.min<double>(34, (rect.width - 14) / ids.length);
    final left = rect.center.dx - pitch * ids.length / 2;
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final at = Offset(left + pitch * (i + 0.5), rect.top + 50);
      final ikinci = order.ikinci;
      final wanted =
          order.ister.contains(id) || (ikinci?.ister.contains(id) ?? false);
      final banned =
          order.istemez.contains(id) || (ikinci?.istemez.contains(id) ?? false);
      final wrong = customer.hataKalan > 0 && customer.hatali.contains(id);
      final well = Rect.fromCenter(center: at, width: pitch - 4, height: 32);

      canvas.drawRRect(
        RRect.fromRectAndRadius(well, const Radius.circular(5)),
        Paint()
          ..color = wrong
              ? const Color(0xFFE0574A)
              : wanted
              ? const Color(0xFF6FCF7C)
              : banned
              ? const Color(0x33E0574A)
              : const Color(0x142E2A26),
      );
      if (wanted || banned || wrong) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(well, const Radius.circular(5)),
          Paint()
            ..color = const Color(0xFF2E2A26)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }

      drawGameGlyph(canvas, id, Offset(at.dx, at.dy - 3), pitch * 0.72);
      if (banned || wrong) {
        const r = 9.0;
        canvas
          ..drawLine(
            at + const Offset(-r, -r),
            at + const Offset(r, r),
            Paint()
              ..color = const Color(0xFFC4321F)
              ..strokeWidth = 2.6,
          )
          ..drawLine(
            at + const Offset(-r, r),
            at + const Offset(r, -r),
            Paint()
              ..color = const Color(0xFFC4321F)
              ..strokeWidth = 2.6,
          );
      }
    }
  }

  /// One mark on a ticket, dimmed and ticked once it has been handed over.
  void _mark(
    Canvas canvas,
    String id,
    Offset center,
    double size, {
    bool done = false,
  }) {
    drawGameGlyph(canvas, id, center, size, alpha: done ? 0.3 : 1);
    if (!done) return;
    canvas.drawCircle(
      center,
      size * 0.42,
      Paint()..color = const Color(0xFF3E9D4C),
    );
    drawGlyph(
      canvas,
      Icons.check_rounded,
      center,
      size * 0.62,
      const Color(0xFFFFF6E8),
    );
  }

  void _renderCarried(Canvas canvas) {
    final held = run.carried;
    if (held == null) return;

    // The paper is the one carryable whose source art is not what leaves it:
    // what a hand takes off a roll is a sheet.
    if (held is Paper) {
      drawTornSheet(
        canvas,
        run.carriedAt - const Offset(0, 14),
        78,
        math.sin(_elapsed * 5) * 0.06,
      );
      return;
    }

    final image = assets[held.asset];
    if (image == null) return;

    // The size it is at home, and a little more for having been lifted. Hard
    // numbers here had six of the eight carryables shrinking the moment they
    // were picked up.
    final home = scene.maybe(held.evi);
    final width = home == null
        ? 60.0
        : widthInQuad(image, home.slots.first) * 1.15;
    canvas
      ..save()
      ..translate(run.carriedAt.dx, run.carriedAt.dy - 12)
      ..scale(1.06)
      ..translate(-run.carriedAt.dx, -(run.carriedAt.dy - 12));
    drawCentered(canvas, image, run.carriedAt - const Offset(0, 12), width);
    canvas.restore();
  }

  /// The run's momentum, welded to the top edge of the screen.
  ///
  /// It was a needle on a dial bolted to the wall over the coals, and the
  /// argument for that shape was that a dial needs no explaining. What it
  /// actually cost was a fifth of the top-left corner, a spot the usta now
  /// stands in, and a reading the player had to turn their eyes to take. A
  /// bar on the frame is read without looking at it.
  ///
  /// Drawn outside the knock, unlike the dial: this is the frame, and a frame
  /// that jumps with the room reads as a broken screen rather than an impact.

  /// Where the meter hangs. Top left, above the usta's head: the corner the
  /// dial used to fill, which the usta has since taken the lower half of.
  static const _tempoKasa = Rect.fromLTWH(52, 26, 252, 46);

  final TempoBarDurumu _tempoDurumu = TempoBarDurumu();

  void _renderTempoBar(Canvas canvas) {
    // A frame can be drawn before any has been ticked — the goldens do
    // exactly that — and a meter that shows the wrong level in that frame is
    // showing the wrong level.
    _tempoDurumu.kur(run.tempo);
    tempoBariCiz(
      canvas,
      _tempoKasa,
      tempo: run.tempo,
      durum: _tempoDurumu,
      t: _elapsed,
      alev: assets['alev'],
    );
    _renderSeri(canvas);
  }

  /// How many in a row, hung off the meter's bottom right. It is not a
  /// reading of the level, so it does not ride the fill.
  static const _seriEsigi = 3;
  static const _seriYeri = Offset(276, 82);

  void _renderSeri(Canvas canvas) {
    final seri = run.tempo.seri;
    if (seri < _seriEsigi) return;
    // Swells on the step that pays, so the tip is seen rather than banked.
    final odul = seri % Balance.seriIkramiyeAdimi == 0;
    final rect = Rect.fromCenter(
      center: _seriYeri,
      width: 54 + (odul ? 6 : 0),
      height: 24 + (odul ? 3 : 0),
    );
    drawPanel(canvas, rect, fill: const Color(0xFF2E2A26));
    drawText(
      canvas,
      '×$seri',
      rect.center,
      size: 14,
      weight: 900,
      family: 'Rubik',
      center: true,
      middle: true,
      color: odul ? const Color(0xFFFFC24A) : const Color(0xFFF7EEDF),
    );
  }
}
