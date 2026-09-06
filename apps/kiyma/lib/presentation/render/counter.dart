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
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/quad.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/effects.dart';
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
  static const _kasa = Rect.fromLTWH(122, 166, 160, 74);

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
  static const Map<TempoHali, Color> _tempoColours = {
    TempoHali.soguk: Color(0xFF6C8AA6),
    TempoHali.normal: Color(0xFFCBA23C),
    TempoHali.isiniyor: Color(0xFFE8862A),
    TempoHali.ates: Color(0xFFE0452A),
  };

  static const Map<TempoHali, IconData> _tempoGlyphs = {
    TempoHali.soguk: Icons.ac_unit_rounded,
    TempoHali.normal: Icons.thermostat_rounded,
    TempoHali.isiniyor: Icons.whatshot_rounded,
    TempoHali.ates: Icons.local_fire_department_rounded,
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

  /// Placeholder for art nobody has drawn: the customer's state as a flat
  /// colour. Green is patient, red is not, and the three leaving colours say
  /// how the visit went.
  static const Map<MusteriHali, Color> _mood = {
    MusteriHali.yuruyor: Color(0xFF7C8794),
    MusteriHali.bekliyorCokSakin: Color(0xFF3E8F52),
    MusteriHali.bekliyorSakin: Color(0xFF7FB86A),
    MusteriHali.bekliyorStabil: Color(0xFFE0B341),
    MusteriHali.bekliyorSupheli: Color(0xFFE07C2E),
    MusteriHali.bekliyorKizgin: Color(0xFFC93B2B),
    MusteriHali.gidiyorMutlu: Color(0xFF35C46E),
    MusteriHali.gidiyorStabil: Color(0xFF5E7FA8),
    MusteriHali.gidiyorKizgin: Color(0xFF7A1F16),
  };

  static const _want = Color(0xFF6FCF7C);
  static const _avoid = Color(0xFFE0574A);

  static const ({Color lit, Color dark, IconData icon}) _burnt = (
    lit: Color(0xFFD93B2B),
    dark: Color(0xFF2A1310),
    icon: Icons.priority_high_rounded,
  );

  /// Everything short-lived the counter draws.
  /// Seeded: a golden that renders a pool has to be the same picture twice.
  late final Effects fx = Effects(assets, random: math.Random(7));

  /// The seams effects need: a moment of slowed time on a hit, and a room
  /// that can be knocked. The instrument is drawn outside the shake, so it
  /// stays bolted to the screen.
  double _freeze = 0;
  double _shake = 0;
  double _shakeFor = 0;

  /// The till catching up with the money, so a sale rolls rather than jumps.
  double _till = 0;

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

    if (_shake > 0) _shake -= dt;
    fx.update(dt);
    _drain();
    _emit(dt);

    _till += (run.progress.para - _till) * (1 - math.exp(-14 * dt));
    if ((run.progress.para - _till).abs() < 1) {
      _till = run.progress.para.toDouble();
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
      fx.coins(from: cue.at, to: Offset(_kasa.center.dx, _kasa.top + 11));
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
      } else if (slot.durum == Pisme.pismis) {
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
    _renderTill(canvas);
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
    'cop_alani' => run.copCagiriyor,
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
            Pisme.cig => 'sis_cig',
            Pisme.pisiyor => 'sis_pisiyor',
            Pisme.pismis => 'sis_pismis',
            Pisme.yanmis => 'sis_yanmis',
          }];
      if (image != null) {
        drawInQuad(canvas, image, slots[i], AssetFit.orta);
      }
      // Filling while it cooks, draining while it is worth taking, and full
      // red once it is only taking up a slot.
      final (dial, value) = switch (durum) {
        Pisme.pismis => (_ready, 1 - slot.ilerleme(run.day)),
        Pisme.yanmis => (_burnt, 1.0),
        _ => (_cooking, slot.pismeOrani),
      };
      // Only the ready one breathes. On a grill of four badges the one that
      // moves should be the one there is something to do about.
      final radius = durum == Pisme.pismis
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
      _renderContents(canvas, region.quad, DurumUrun(station));
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
    for (final malzeme in Malzeme.values) {
      final tutam = station.tutam(malzeme);
      if (tutam == 0) continue;
      _layer(
        canvas,
        region.quad,
        composition.ingredient(malzeme.id),
        portion: tutam / Balance.tutamAdedi,
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
    for (final bilesen in Bilesen.values) {
      final tutam = station.tutam(bilesen);
      if (tutam == 0) continue;
      _layer(
        canvas,
        region.quad,
        composition.ingredient(bilesen.id),
        portion: tutam / Balance.tutamAdedi,
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
            DurumUrun() => 'doner_bekleme',
            PorsiyonUrun() => 'porsiyon_hazirlama',
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
  void _renderContents(Canvas canvas, Quad quad, Urun urun) {
    final ids = switch (urun) {
      DurumUrun(:final durum) => [
        for (final m in Malzeme.values)
          if (durum.malzemeler.contains(m)) m.id,
      ],
      PorsiyonUrun(:final porsiyon) => [
        for (final b in Bilesen.values)
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
      final late = run.kalanSure < 20;
      final face = late ? const Color(0xFFFF5A45) : const Color(0xFFE8641A);

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

  /// The money, as the box a counter keeps it in.
  ///
  /// It fills: the inset behind the number floods gold from the bottom as
  /// the day's take climbs toward the next level, so the box is a progress
  /// bar that nobody has to be told is a progress bar.
  void _renderTill(Canvas canvas) {
    const ink = Color(0xFF2E2A26);
    const brass = Color(0xFFC08A3E);
    final body = RRect.fromRectAndRadius(_kasa, const Radius.circular(11));
    final inset = Rect.fromLTWH(
      _kasa.left + 13,
      _kasa.top + 22,
      _kasa.width - 26,
      _kasa.height - 35,
    );
    final well = RRect.fromRectAndRadius(inset, const Radius.circular(6));

    canvas
      ..drawRRect(
        body.shift(const Offset(4, 7)),
        Paint()..color = const Color(0x3D000000),
      )
      ..drawRRect(body, Paint()..color = const Color(0xFF8A5A2B))
      ..drawRRect(
        body.deflate(1.5),
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    // Grain, so it reads as wood and not as a rounded rectangle.
    for (final dy in [0.3, 0.62, 0.86]) {
      canvas.drawLine(
        Offset(_kasa.left + 8, _kasa.top + _kasa.height * dy),
        Offset(_kasa.right - 8, _kasa.top + _kasa.height * dy),
        Paint()
          ..color = const Color(0x1A2E2A26)
          ..strokeWidth = 1.5,
      );
    }
    // The coin slot, and the brass the corners of a box like this have.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_kasa.center.dx - 34, _kasa.top + 7, 68, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF3A2A17),
    );
    for (final corner in [
      Offset(_kasa.left + 7, _kasa.bottom - 7),
      Offset(_kasa.right - 7, _kasa.bottom - 7),
    ]) {
      canvas.drawCircle(corner, 3.5, Paint()..color = brass);
    }

    canvas
      ..drawRRect(well, Paint()..color = const Color(0xFF241F1A))
      ..save()
      ..clipRRect(well);
    final filled = Balance.ratio(run.progress.xp, run.day);
    canvas
      ..drawRect(
        Rect.fromLTWH(
          inset.left,
          inset.bottom - inset.height * filled,
          inset.width,
          inset.height * filled,
        ),
        Paint()..color = const Color(0xFF6A4A12),
      )
      ..restore();

    final coins = assets['altin'];
    if (coins != null) {
      drawCentered(canvas, coins, Offset(inset.left + 20, inset.center.dy), 34);
    }
    drawText(
      canvas,
      '${_till.round()}',
      Offset(inset.right - 8, inset.center.dy),
      size: 30,
      weight: 900,
      family: 'Rubik',
      right: true,
      middle: true,
      color: const Color(0xFFF7EEDF),
    );

    // What a full meter paid out, floating off the box it went into.
    if (run.tempoIkramiyeKalan <= 0) return;
    final fade = (run.tempoIkramiyeKalan / 1.2).clamp(0.0, 1.0);
    drawText(
      canvas,
      '+${run.tempoIkramiye}',
      Offset(_kasa.right - 16, _kasa.top - 10 - (1 - fade) * 14),
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
      _renderBody(canvas, home.shift(Offset(from * left * left, 0)), customer);
    }

    for (final leaving in run.ayrilanlar) {
      final home = scene['musteri_slot_${leaving.slot + 1}'].quad;
      // Out the way they came in, picking up speed as they go.
      final gone = leaving.gidis * leaving.gidis;
      final door = scene.size.width - home.bounds.left + 40;
      _renderBody(
        canvas,
        home.shift(Offset(door * gone, 0)),
        null,
        hal: leaving.hal,
      );
    }
  }

  /// The ones standing at the counter, with everything they came with.
  void _renderSeated(Canvas canvas) {
    for (var i = 0; i < run.musteriler.length; i++) {
      final customer = run.musteriler[i];
      if (customer == null || !customer.yerinde) continue;
      final quad = scene['musteri_slot_${i + 1}'].quad;
      _renderBody(canvas, quad, customer);
      final head = Offset(quad.bounds.center.dx, quad.bounds.top + 26);
      _renderOrder(canvas, head, customer, i);
    }
  }

  /// A stand-in body in the colour of whatever the person is doing.
  ///
  /// The characters are the one part of the art that was never drawn — they
  /// are meant to be animated — so until they are, the nine states of a visit
  /// are nine colours. What the player actually has to read is the order and
  /// how long it has, and those are drawn beside the body rather than on it.
  void _renderBody(
    Canvas canvas,
    Quad quad,
    Customer? customer, {
    MusteriHali? hal,
  }) {
    final bounds = quad.bounds;
    final colour = _mood[hal ?? customer!.hal]!;
    canvas
      ..drawCircle(
        Offset(bounds.center.dx, bounds.top + 26),
        19,
        Paint()..color = Color.lerp(colour, const Color(0xFF2E2A26), 0.35)!,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bounds.left + 14,
            bounds.top + 46,
            bounds.width - 28,
            46,
          ),
          const Radius.circular(14),
        ),
        Paint()..color = colour,
      );
  }

  /// The order, as the paper a kebab shop writes it on.
  ///
  /// Three fixed bands in every ticket, always the same size and always in
  /// the same order, so three of them can be read at a glance under time
  /// pressure: what they want, the four ingredients as wanted / forbidden /
  /// unmentioned, and the two extras. The rail is iterated in enum order
  /// rather than set order — a shuffled row cannot be scanned.
  void _renderOrder(Canvas canvas, Offset head, Customer customer, int slot) {
    final rect = Rect.fromLTWH(
      math.max(306, head.dx - _ticket.width / 2),
      _ticketTop,
      _ticket.width,
      _wanted(customer.order).isEmpty ? _ticketBare : _ticket.height,
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
      ..save()
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
    final durum = order.tip == UrunTipi.durum;
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

    // Dessert always first and drink always second, printed as an empty ring
    // when there is none — so the eye learns one place to look rather than
    // reading a row whose length changes.
    for (final (i, entry) in [
      (order.tatli?.id, customer.tatliVerildi),
      (order.icecek?.id, customer.icecekVerildi),
    ].indexed) {
      final at = Offset(band.left + 40 + i * 22, band.center.dy);
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
    final base = order.tip == UrunTipi.durum
        ? Balance.durumBase
        : Balance.porsiyonBase;
    var worth = customer.anaUrunVerildi
        ? 0
        : Balance.income(base, run.day, ingredients: order.ister.length);
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

  /// Only what was actually asked for: wanted, then forbidden, in enum order.
  ///
  /// It printed all four wells always, so a customer who cared about one
  /// ingredient still handed over a card with three grey boxes on it. The
  /// bonus an unmentioned ingredient earns was printed in those boxes and it
  /// is not worth the clutter — three quarters of every card said nothing.
  static List<String> _wanted(Order order) => [
    for (final id
        in order.tip == UrunTipi.durum
            ? Malzeme.values.map((m) => m.id)
            : Bilesen.values.map((b) => b.id))
      if (order.ister.contains(id) || order.istemez.contains(id)) id,
  ];

  void _ticketRail(Canvas canvas, Rect rect, Customer customer) {
    final order = customer.order;
    final ids = _wanted(order);
    if (ids.isEmpty) return;

    // Centred rather than spread across the card: the row is one to four
    // wide now, and a stretched pair reads as a card with holes in it.
    const pitch = 34.0;
    final left = rect.center.dx - pitch * ids.length / 2;
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final at = Offset(left + pitch * (i + 0.5), rect.top + 50);
      final wanted = order.ister.contains(id);
      final banned = order.istemez.contains(id);
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

      drawGameGlyph(canvas, id, Offset(at.dx, at.dy - 3), 24);
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
    if (held is Kagit) {
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

  /// The run's momentum, as the gauge a grill would have.
  ///
  /// It hangs on the wall over the coals it reads, because that is what the
  /// number is about: everything the counter earns is multiplied by it, and
  /// what feeds it is working the grill. A needle sweeping a dial is also
  /// the one meter shape a player has seen a thousand times and needs no
  /// explaining — a bar would have to be learnt.
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
