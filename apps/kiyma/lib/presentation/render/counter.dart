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
import 'package:kiyma/presentation/render/customer_figure.dart';
import 'package:kiyma/presentation/render/effects.dart';
import 'package:kiyma/presentation/render/figure.dart';
import 'package:kiyma/presentation/render/glyphs.dart';
import 'package:kiyma/presentation/render/halo.dart';
import 'package:kiyma/presentation/render/painter.dart';

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
  static const _gauge = Offset(196, 84);
  static const _gaugeRadius = 62.0;

  /// Above the calendar, and small: it is a tally, not a headline. The wall
  /// already carries a gauge and a calendar, and a third large object on it
  /// was reading as a row of panels.
  static const _tahta = Rect.fromLTWH(24, 52, 102, 62);

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

  /// One colour and one glyph per band. Four states are learnable where a
  /// continuous multiplier is not, and a glyph is read faster than a word in
  /// any language.
  static const Map<TempoBand, Color> _tempoColours = {
    TempoBand.soguk: Color(0xFF6C8AA6),
    TempoBand.normal: Color(0xFFCBA23C),
    TempoBand.isiniyor: Color(0xFFE8862A),
    TempoBand.ates: Color(0xFFE0452A),
  };

  static const Map<TempoBand, IconData> _tempoGlyphs = {
    TempoBand.soguk: Icons.ac_unit_rounded,
    TempoBand.normal: Icons.thermostat_rounded,
    TempoBand.isiniyor: Icons.whatshot_rounded,
    TempoBand.ates: Icons.local_fire_department_rounded,
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

    final area = visible?.call();
    if (area != null) run.gorunurAlan = area;
    final wanted = run.copeAtilabilir ? 1.0 : 0.0;
    _cop += (wanted - _cop) * (1 - math.exp(-16 * dt));

    if (_shake > 0) _shake -= dt;
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

  /// Turns what the rules said happened into something to look at.
  void _drain() {
    for (final cue in run.cues) {
      switch (cue.kind) {
        case DayEvent.kabul:
          _serve(cue);
        case DayEvent.yandi:
          _knock(3.4, 0.12);
          fx
            ..burst(
              at: cue.at,
              colour: const Color(0xFF3A302A),
              count: 10,
              speed: 150,
            )
            ..floater(
              at: cue.at,
              text: '${cue.amount}',
              colour: const Color(0xFFC4321F),
            );
        case DayEvent.musteriKizgin:
          _knock(6, 0.3);
          fx.floater(
            at: cue.at,
            text: '!',
            colour: const Color(0xFFC4321F),
            size: 26,
          );
        case DayEvent.altinSupuruldu:
          fx
            ..burst(
              at: cue.at,
              colour: const Color(0xFF8E8578),
              count: 8,
              speed: 90,
              up: math.pi / 2,
              gravity: 120,
            )
            ..floater(
              at: cue.at,
              text: '${cue.amount}',
              colour: const Color(0xFFC4321F),
              rise: -20,
            );
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
      fx.coins(from: cue.at, to: _tahta.center);
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
    // Room objects, so they are inside the knock: a gauge bolted to a wall
    // that jumps is an impact, where a HUD that jumps is a broken screen.
    _renderTempo(canvas);
    _renderTahta(canvas);
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

    // A corner, chosen for what it hides least.
    //
    // It was a full-width band that flipped top to bottom with the target,
    // so "hand it over" — a target at the customers — laid the bubble across
    // the prep area, over the wrap the player was being told to pick up.
    // Everything the player has to be able to see while the usta talks. The
    // gauge and the slate are on the list because they are drawn here rather
    // than in the scene, so nothing else knows they are in the way; the wall
    // pair is on it because a step with nothing to touch has no target to
    // avoid. The prep areas count only while they hold something — an empty
    // board is not work, and treating it as work leaves the bubble nowhere.
    final dolu = <Rect>[
      if (hedef != null) hedef.quad.bounds,
      Rect.fromCircle(center: _gauge, radius: _gaugeRadius),
      _tahta,
      // The one control on the counter. A bubble over it is a run that
      // cannot be paused until the usta has finished talking.
      _pause,
      for (final ad in const ['duvar_saati', 'duvar_takvimi'])
        if (scene.maybe(ad) case final bolge?) bolge.quad.bounds,
      if (run.durumIstasyonu != null)
        if (scene.maybe('durum_hazirlama') case final bolge?) bolge.quad.bounds,
      if (run.tabakIstasyonu != null)
        if (scene.maybe('tabak_hazirlama') case final bolge?) bolge.quad.bounds,
      if (run.bekleme.any((urun) => urun != null))
        if (scene.maybe('bekleme_alani') case final bolge?) bolge.quad.bounds,
      for (var i = 0; i < run.musteriler.length; i++)
        if (run.musteriler[i] != null)
          if (scene.maybe('musteri_slot_${i + 1}') case final bolge?)
            bolge.quad.bounds,
    ];
    const genislik = 500.0;
    const yukseklik = 92.0;
    var rect = Rect.zero;
    var enAz = double.infinity;
    for (final aday in [
      for (final x in [20.0, size.x - genislik - 20])
        // The portrait leans past the panel top and bottom, so the lower
        // row sits high enough to keep the usta's feet on the picture.
        for (final y in [18.0, size.y - yukseklik - 30])
          Rect.fromLTWH(x, y, genislik, yukseklik),
    ]) {
      var ortusme = 0.0;
      for (final bolge in dolu) {
        final kesisim = aday.intersect(bolge);
        if (!kesisim.isEmpty) ortusme += kesisim.width * kesisim.height;
      }
      if (ortusme < enAz) {
        enAz = ortusme;
        rect = aday;
      }
    }
    drawPanel(canvas, rect, fill: const Color(0xFFF7EEDF));

    final usta = assets['usta'];
    if (usta != null) {
      drawCentered(
        canvas,
        usta,
        Offset(rect.left + 2, rect.center.dy + 4),
        88,
      );
    }

    // Wrapped, and clear of both the portrait and the skip button: a
    // sentence long enough to say something ran off the end of the panel.
    drawText(
      canvas,
      ceviri(adim.metin ?? 'ders.${ogretmen.ders.id}.${adim.id}'),
      Offset(rect.left + 68, rect.center.dy - 6),
      size: 17,
      weight: 800,
      family: 'Rubik',
      middle: true,
      maxWidth: genislik - 68 - 96,
      color: const Color(0xFF2E2A26),
    );
    drawText(
      canvas,
      '${ogretmen.sira + 1}/${ogretmen.toplam}',
      Offset(rect.left + 68, rect.bottom - 22),
      size: 12,
      weight: 700,
      family: 'Rubik',
      color: const Color(0x992E2A26),
    );

    _atlaKutusu = Rect.fromLTWH(rect.right - 92, rect.center.dy - 18, 76, 36);
    drawKey(canvas, _atlaKutusu, const Color(0xFF6E6155));
    drawText(
      canvas,
      ceviri('tanitim.atla'),
      _atlaKutusu.center,
      size: 16,
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
      Offset(rect.right - 132, rect.center.dy),
      26,
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
      if (layer.name == 'mangal_katman') _renderSef(canvas);
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

      final image =
          assets[switch (durum) {
            Doneness.cig => 'sis_cig',
            Doneness.pisiyor => 'sis_pisiyor',
            Doneness.pismis => 'sis_pismis',
            Doneness.yanmis => 'sis_yanmis',
          }];
      if (image != null) {
        drawInQuad(canvas, image, slots[i], AssetFit.orta);
      }
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

  /// Whoever is actually cooking.
  ///
  /// A placeholder, like the customers: the characters are the one part of
  /// the art meant to be animated, so until they are, this is a jacket and a
  /// hat filling the chef's place. He is drawn from inside the scene pass,
  /// between the back wall and the grill, so the mangal is painted over his
  /// waist — which is what puts him behind it instead of standing in it.
  void _renderSef(Canvas canvas) {
    final region = scene.maybe('sef');
    if (region == null) return;
    final bounds = region.quad.bounds;
    // Breathing, so a still figure is not a cardboard cut-out.
    final sway = math.sin(_elapsed * 1.7) * 2.0;
    final x = bounds.center.dx + sway;
    const skin = Color(0xFF7A6350);
    const jacket = Color(0xFFF3EADA);

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 252), width: 58, height: 36),
          const Radius.circular(17),
        ),
        Paint()..color = jacket,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 272), width: 64, height: 14),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFFDCCFB8),
      )
      ..drawCircle(Offset(x, 296), 26, Paint()..color = skin)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x - 62, 320, x + 62, bounds.bottom),
          const Radius.circular(26),
        ),
        Paint()..color = jacket,
      )
      // A collar, which is the one line that says jacket rather than sack.
      ..drawPath(
        Path()
          ..moveTo(x - 17, 320)
          ..lineTo(x, 346)
          ..lineTo(x + 17, 320)
          ..close(),
        Paint()..color = const Color(0xFFDCCFB8),
      );
  }

  /// The money, chalked on a slate the way a shop actually keeps a tally.
  ///
  /// It was a wooden cash box with an inset panel, and it read as a sign —
  /// the most interface-shaped thing left on a wall that already has a
  /// calendar and a gauge on it. A slate is the same information as an
  /// object anybody has seen in a kebab shop, and it is drawn rather than
  /// painted, so it costs no art and never disagrees with the light.
  void _renderTahta(Canvas canvas) {
    const ink = Color(0xFF2E2A26);
    const chalk = Color(0xFFF2EFE6);
    final frame = RRect.fromRectAndRadius(_tahta, const Radius.circular(7));
    final face = RRect.fromRectAndRadius(
      _tahta.deflate(9),
      const Radius.circular(3),
    );

    canvas
      // Hung on a nail, like everything else on this wall.
      ..drawLine(
        Offset(_tahta.center.dx, _tahta.top - 13),
        Offset(_tahta.center.dx, _tahta.top + 3),
        Paint()
          ..color = ink
          ..strokeWidth = 3,
      )
      ..drawCircle(
        Offset(_tahta.center.dx, _tahta.top - 14),
        4,
        Paint()..color = const Color(0xFF6E6155),
      )
      ..drawRRect(
        frame.shift(const Offset(3, 6)),
        Paint()..color = const Color(0x3D000000),
      )
      ..drawRRect(frame, Paint()..color = const Color(0xFF6E4A24))
      ..drawRRect(
        frame.deflate(1.5),
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      )
      ..drawRRect(face, Paint()..color = const Color(0xFF262B26));

    // Old chalk that never quite comes off. Fixed smears, not random ones:
    // a slate that reshuffles its own grime every frame is a screensaver.
    for (final smear in const [
      Rect.fromLTWH(0.12, 0.18, 0.5, 0.1),
      Rect.fromLTWH(0.45, 0.66, 0.42, 0.09),
      Rect.fromLTWH(0.08, 0.78, 0.3, 0.07),
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(
          _tahta.left + 9 + smear.left * (_tahta.width - 18),
          _tahta.top + 9 + smear.top * (_tahta.height - 18),
          smear.width * (_tahta.width - 18),
          smear.height * (_tahta.height - 18),
        ),
        Paint()..color = chalk.withValues(alpha: 0.06),
      );
    }

    // Chalk is rewritten, not rolled: the number snaps and the dust puffs.
    final pop = _yazma <= 0
        ? 0.0
        : Curves.easeOutBack.transform(
            (1 - _yazma / _yazmaSuresi).clamp(0.0, 1.0),
          );
    final scale = _yazma <= 0 ? 1.0 : 1.22 - 0.22 * pop;
    final centre = Offset(_tahta.center.dx, _tahta.center.dy - 5);
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..scale(scale)
      ..translate(-centre.dx, -centre.dy);
    // Drawn twice, the under-pass wide and faint: chalk has a dusty edge and
    // a clean glyph on a blackboard reads as a printed label.
    for (final (alpha, offset) in const [
      (0.22, Offset(1.4, 1.2)),
      (1.0, Offset.zero),
    ]) {
      drawText(
        canvas,
        goldText(run.progress.para),
        centre + offset,
        size: 26,
        weight: 800,
        family: 'Rubik',
        center: true,
        middle: true,
        color: chalk.withValues(alpha: alpha),
      );
    }
    canvas.restore();

    // A chalk line under it, filled as far as the day has come. The box used
    // to flood with gold to say the same thing.
    final line = Rect.fromLTWH(
      _tahta.left + 17,
      _tahta.bottom - 16,
      _tahta.width - 34,
      2.5,
    );
    canvas
      ..drawRect(line, Paint()..color = chalk.withValues(alpha: 0.18))
      ..drawRect(
        Rect.fromLTWH(
          line.left,
          line.top,
          line.width * Balance.ratio(run.progress.xp, run.day),
          line.height,
        ),
        Paint()..color = chalk.withValues(alpha: 0.8),
      );

    // What a full meter paid out, floating off the slate it went onto.
    if (run.tempoIkramiyeKalan <= 0) return;
    final fade = (run.tempoIkramiyeKalan / 1.2).clamp(0.0, 1.0);
    drawText(
      canvas,
      '+${run.tempoIkramiye}',
      Offset(_tahta.right - 12, _tahta.top - 10 - (1 - fade) * 14),
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
    canvas
      ..save()
      ..clipRect(
        Rect.fromLTRB(bounds.left, bounds.top, bounds.right, _tezgahCizgisi),
      );
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

  /// Which of the seven silhouettes this person is. Keyed off the walk speed,
  /// which is already a stable random number the domain hands out per
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

  /// Tongues licking round the bezel once the meter is pinned.
  ///
  /// Behind the case, so they come out from under it rather than sitting on
  /// top of it, and each one on its own phase — five copies of one sine is a
  /// throbbing ring, not a fire.
  void _renderGaugeFlames(
    Canvas canvas,
    Offset at,
    double r,
    double strength,
  ) {
    final image = assets['alev'];
    if (image == null) return;
    for (var i = 0; i < 7; i++) {
      // Only the top half: flames go up, and a tongue under the case would
      // have to be coming out of the wall.
      final a = -math.pi * (0.12 + 0.76 * i / 6);
      final phase = _elapsed * 7 + i * 1.9;
      final lick = 0.55 + 0.45 * math.sin(phase);
      final size = (20 + 16 * lick) * (0.7 + 0.3 * strength);
      canvas
        ..save()
        ..translate(
          at.dx + math.cos(a) * (r - 4),
          at.dy + math.sin(a) * (r - 4),
        )
        ..rotate(a + math.pi / 2)
        ..scale(1, 1 + 0.25 * lick);
      drawCentered(
        canvas,
        image,
        Offset(0, -size * 0.35),
        size,
        paint: Paint()
          ..color = const Color(
            0xFFFFFFFF,
          ).withValues(alpha: (0.5 + 0.5 * lick) * (0.4 + 0.6 * strength))
          ..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    }
  }

  /// Rime creeping in from the bezel once the counter has gone cold.
  ///
  /// Drawn over the face rather than under the case: it is frost on the
  /// glass, so it has to be in front of the needle it is obscuring. It never
  /// reaches the middle — a gauge you cannot read is a bug, not a mood.
  void _renderGaugeFrost(Canvas canvas, Offset at, double r, double strength) {
    const ice = Color(0xFFDDF2FB);
    // Fixed spokes rather than random: the same frost every frame, growing.
    for (var i = 0; i < 14; i++) {
      final a = i * math.pi * 2 / 14;
      final dir = Offset(math.cos(a), math.sin(a));
      // Uneven, from the index rather than a die: rime is not a starburst.
      final reach = (0.34 + 0.3 * (((i * 7) % 5) / 4)) * strength;
      final root = at + dir * (r - 9);
      final tip = at + dir * (r - 9 - r * reach);
      final side = Offset(-dir.dy, dir.dx) * (r * 0.09);
      canvas.drawPath(
        Path()
          ..moveTo(root.dx + side.dx, root.dy + side.dy)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(root.dx - side.dx, root.dy - side.dy)
          ..close(),
        Paint()..color = ice.withValues(alpha: 0.5 * strength),
      );
    }
    canvas
      ..drawCircle(
        at,
        r - 9,
        Paint()
          ..color = ice.withValues(alpha: 0.3 * strength)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.16,
      )
      // A breath of fog over the whole face, so the glass reads as cold
      // rather than as a decorated bezel.
      ..drawCircle(
        at,
        r - 11,
        Paint()..color = ice.withValues(alpha: 0.16 * strength),
      );
  }

  /// The run's momentum, as the gauge a grill would have.
  ///
  /// It hangs on the wall over the coals it reads, because that is what the
  /// number is about: everything the counter earns is multiplied by it, and
  /// what feeds it is working the grill. A needle sweeping a dial is also
  /// the one meter shape a player has seen a thousand times and needs no
  /// explaining — a bar would have to be learnt.
  /// How many in a row, under the gauge.
  ///
  /// The streak already pays — a tip every fifth — and already feeds the
  /// needle, but neither of those says what the number is. Three is where it
  /// starts showing: below that it is not a run, it is two customers.
  static const _seriEsigi = 3;

  void _renderSeri(Canvas canvas, Offset at, double r) {
    final seri = run.tempo.seri;
    if (seri < _seriEsigi) return;
    // Swells on the step that pays, so the tip is seen rather than banked.
    final odul = seri % Balance.seriIkramiyeAdimi == 0;
    final rect = Rect.fromCenter(
      center: Offset(at.dx, at.dy + r + 13),
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

  void _renderTempo(Canvas canvas) {
    final tempo = run.tempo;
    final colour = _tempoColours[tempo.hal]!;
    const at = _gauge;
    const r = _gaugeRadius;
    // Three quarters of a turn, opening downward: the gap at the bottom is
    // what tells the eye where empty is and where full is.
    const from = math.pi * 0.75;
    const sweep = math.pi * 1.5;

    // Above sixty the case starts to glow, and at ninety it is on fire.
    // The multiplier is the one number the whole counter is worth, and it
    // was being read off a needle angle; heat is what a player feels without
    // reading anything.
    final heat = ((tempo.deger - 60) / 30).clamp(0.0, 1.0);
    if (heat > 0) {
      canvas.drawCircle(
        at,
        r + 6 + heat * 16,
        Paint()
          ..color = colour.withValues(alpha: (0.16 + 0.26 * heat) * _pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }
    if (tempo.deger >= 90) {
      _renderGaugeFlames(canvas, at, r, (tempo.deger - 90) / 10);
    }
    // And the other end of the same meter. A cold counter pays half, which
    // was a number nobody read; ice on the glass is not a number.
    final chill = ((25 - tempo.deger) / 25).clamp(0.0, 1.0);
    if (chill > 0) {
      canvas.drawCircle(
        at,
        r + 4 + chill * 12,
        Paint()
          ..color = const Color(0xFF9FD8F0).withValues(alpha: 0.3 * chill)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    canvas
      ..drawLine(
        Offset(at.dx, at.dy - r - 16),
        Offset(at.dx, at.dy - r + 4),
        Paint()
          ..color = const Color(0xFF2E2A26)
          ..strokeWidth = 3,
      )
      ..drawCircle(
        Offset(at.dx, at.dy - r - 17),
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
      ..drawArc(
        Rect.fromCircle(center: at, radius: r - 20),
        from,
        sweep,
        false,
        Paint()
          ..color = const Color(0x1F2E2A26)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      )
      ..drawArc(
        Rect.fromCircle(center: at, radius: r - 20),
        from,
        math.max(0.02, sweep * tempo.oran),
        false,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      );

    // Ticks, so the needle is read against something.
    for (var i = 0; i <= 10; i++) {
      final a = from + sweep * i / 10;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        at + dir * (r - 30),
        at + dir * (r - (i % 5 == 0 ? 36 : 33)),
        Paint()
          ..color = const Color(0x552E2A26)
          ..strokeWidth = i % 5 == 0 ? 2.6 : 1.5,
      );
    }

    // The needle, trembling at the top of the scale rather than sitting
    // still: pinned is a state, not a stop.
    final pinned = tempo.oran > 0.98;
    final angle =
        from +
        sweep * tempo.oran +
        (pinned ? math.sin(_elapsed * 24) * 0.02 : 0);
    final tip = at + Offset(math.cos(angle), math.sin(angle)) * (r - 26);
    final back = at - Offset(math.cos(angle), math.sin(angle)) * 9;
    canvas
      ..drawLine(
        back,
        tip,
        Paint()
          ..color = const Color(0xFF2E2A26)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(at, 8, Paint()..color = const Color(0xFF2E2A26))
      ..drawCircle(at, 5, Paint()..color = colour);
    // Every move the counter took or refused, however small, lands here. The
    // needle answers too, but a single handful moves it about a degree.
    if (tempo.dokunusKalan > 0) {
      final left = (tempo.dokunusKalan / 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(
        at,
        5 + (1 - left) * 13,
        Paint()
          ..color =
              (tempo.sonDokunusIyi
                      ? const Color(0xFF5FD070)
                      : const Color(0xFFE0574A))
                  .withValues(alpha: left * 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    _renderSeri(canvas, at, r);

    if (chill > 0) _renderGaugeFrost(canvas, at, r, chill);

    // The band, as a glyph on the face. A word here would need translating
    // and would not be read at a glance anyway.
    drawGlyph(
      canvas,
      _tempoGlyphs[tempo.hal]!,
      Offset(at.dx, at.dy + r * 0.42),
      20,
      colour,
    );

    // The change, floating off the case. Without it the multiplier is
    // invisible and the player never learns what feeds it.
    if (tempo.degisimKalan <= 0) return;
    final delta = tempo.sonDegisim;
    final fade = (tempo.degisimKalan / 1.1).clamp(0.0, 1.0);
    drawText(
      canvas,
      '${delta > 0 ? '+' : ''}${delta.round()}',
      Offset(at.dx + r + 6, at.dy - 10 - (1 - fade) * 14),
      size: 21,
      weight: 900,
      family: 'Rubik',
      center: true,
      outline: const Color(0xCCFFF6E8),
      color: (delta > 0 ? const Color(0xFF2F8F3A) : const Color(0xFFC4321F))
          .withValues(alpha: fade),
    );
  }
}
