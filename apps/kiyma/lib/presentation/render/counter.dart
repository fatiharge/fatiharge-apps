import 'dart:math' as math;
import 'dart:ui';

// `Quad` collides with vector_math's, which Flame re-exports everywhere.
import 'package:flame/components.dart' hide Quad;
import 'package:flame/events.dart';
// Only for the two glyphs the grill badges carry.
import 'package:flutter/material.dart' show Curves, IconData, Icons;
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/gesture.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/quad.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/infrastructure/assets.dart';
import 'package:kiyma/presentation/render/effects.dart';
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

  /// One plate, three sockets.
  ///
  /// The pause button, the till and the tempo meter were three separate
  /// panels and read as three unrelated things. They are one instrument —
  /// the tempo is what the till is multiplied by — so they share a housing.
  /// It stops short of x344, where the leftmost patience bar begins, and
  /// hangs low enough that the flames off its top edge have somewhere to go.
  static const _plate = Rect.fromLTWH(14, 22, 286, 116);
  static const _pause = Rect.fromLTWH(28, 34, 58, 58);
  static const _gold = Rect.fromLTWH(96, 34, 190, 58);
  static const _tempo = Rect.fromLTWH(72, 102, 214, 24);

  /// The band above the heads, which the hand never enters. The tickets used
  /// to sit beside each face, in the middle of every drag.
  static const _ticket = Size(148, 78);
  static const _ticketTop = 10.0;

  /// The badge on the left of the meter, sitting proud of the plate.
  static const _stage = Offset(48, 114);

  /// The clock as a hairline across the very top of the scene. The wall
  /// clock is there to be read; this is there to be noticed.
  static const _thread = 5.0;

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

  /// An order line already handed over.
  static final _faded = Paint()
    ..filterQuality = FilterQuality.medium
    ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.3);
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
    // keep breathing, which is what makes a serve land.
    if (_freeze > 0) {
      _freeze -= dt;
      run.tick(dt * 0.12);
    } else {
      run.tick(dt);
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
      fx.coins(
        from: cue.at,
        to: Offset(_gold.left + 32, _gold.center.dy),
      );
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
    _renderHud(canvas);
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
      if (station.malzemeler.contains(malzeme)) {
        _layer(canvas, region.quad, composition.ingredient(malzeme.id));
      }
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
      if (station.bilesenler.contains(bilesen)) {
        _layer(canvas, region.quad, composition.ingredient(bilesen.id));
      }
    }
  }

  void _layer(Canvas canvas, Quad quad, CompositionLayer? layer) {
    if (layer == null) return;
    final image = assets[layer.asset];
    if (image != null) drawCompositionLayer(canvas, image, quad, layer);
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
      final image = assets['duvar_saati'];
      if (image != null) drawInQuad(canvas, image, clock.quad, clock.fit);
      final bounds = clock.quad.bounds;
      final left = run.kalanSure.ceil();
      drawText(
        canvas,
        '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}',
        Offset(bounds.center.dx, bounds.top + bounds.height * 0.24),
        size: bounds.height * 0.44,
        weight: 900,
        family: 'Rubik',
        center: true,
        // Lit segments on dark glass, and red once the day is nearly out.
        color: run.kalanSure < 20
            ? const Color(0xFFFF5A45)
            : const Color(0xFFFFC24A),
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

  /// The instrument the counter is read off: the pause, the till and the
  /// tempo in one housing, with the run's clock threaded across the top of
  /// the screen above it.
  ///
  /// Cream on charcoal with a hard offset shadow, because that is what every
  /// other screen in the game is. A dark wooden plate was tried and it aged
  /// the whole counter: the HUD is the one thing on screen at all times, so
  /// it sets the tone for everything behind it.
  void _renderHud(Canvas canvas) {
    _renderThread(canvas);

    final tempo = run.tempo;
    final hot = tempo.hal == TempoHali.ates;

    drawPanel(canvas, _plate, fill: const Color(0xFFF7EEDF));
    drawGloss(canvas, _plate);
    if (hot) _renderShine(canvas);

    _renderPause(canvas);
    _renderTill(canvas);
    _renderTempo(canvas);
  }

  /// The run's clock, drained left to right. Five pixels at the very top of
  /// the scene, above everything, so it is seen without being looked at.
  void _renderThread(Canvas canvas) {
    canvas
      ..drawRect(
        Rect.fromLTWH(0, 0, size.x, _thread),
        Paint()..color = const Color(0x552E2A26),
      )
      ..drawRect(
        Rect.fromLTWH(0, 0, size.x * run.sureOrani, _thread),
        Paint()
          ..color = run.kalanSure < 20
              ? const Color(0xFFE0452A)
              : const Color(0xFFF3A431),
      );
  }

  /// A band of light sweeping the plate while the meter is pinned. Cheaper
  /// and far less dated than drawn flames, and it says the same thing.
  void _renderShine(Canvas canvas) {
    final phase = (_elapsed * 0.55) % 1;
    final x = _plate.left - 90 + phase * (_plate.width + 180);
    canvas
      ..save()
      ..clipRRect(
        RRect.fromRectAndRadius(_plate, const Radius.circular(18)),
      )
      ..drawPath(
        Path()
          ..moveTo(x, _plate.bottom)
          ..lineTo(x + 34, _plate.bottom)
          ..lineTo(x + 34 + 26, _plate.top)
          ..lineTo(x + 26, _plate.top)
          ..close(),
        Paint()..color = const Color(0x33FFFFFF),
      )
      ..restore();
  }

  void _renderPause(Canvas canvas) {
    drawKey(canvas, _pause, const Color(0xFFE8641A));
    for (final dx in [-8.0, 8.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: _pause.center + Offset(dx, 0),
            width: 9,
            height: 26,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFFFF6E8),
      );
    }
  }

  void _renderTill(Canvas canvas) {
    final coins = assets['altin'];
    if (coins != null) {
      drawCentered(canvas, coins, Offset(_gold.left + 32, _gold.center.dy), 56);
    }
    drawText(
      canvas,
      '${run.progress.para}',
      Offset(_gold.left + 66, _gold.top + 8),
      size: 38,
      weight: 900,
      family: 'Rubik',
      color: const Color(0xFF2E2A26),
    );

    // What a full meter paid out, floating off the till it went into.
    if (run.tempoIkramiyeKalan <= 0) return;
    final fade = (run.tempoIkramiyeKalan / 1.2).clamp(0.0, 1.0);
    drawText(
      canvas,
      '+${run.tempoIkramiye}',
      Offset(_gold.right - 16, _gold.top - 4 - (1 - fade) * 14),
      size: 20,
      weight: 900,
      family: 'Rubik',
      center: true,
      color: const Color(0xFF2F8F3A).withValues(alpha: fade),
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
      _ticket.height,
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
    _ticketExtras(canvas, rect, customer);

    // Patience, printed along the torn edge.
    drawBar(
      canvas,
      Rect.fromLTWH(rect.left + 8, rect.bottom - 12, rect.width - 16, 5),
      customer.sabirOrani,
      color: Color.lerp(_avoid, _want, customer.sabirOrani)!,
      background: const Color(0x332E2A26),
    );
    canvas.restore();
  }

  void _ticketHeader(Canvas canvas, Rect rect, Customer customer) {
    final order = customer.order;
    final durum = order.tip == UrunTipi.durum;
    final band = Rect.fromLTWH(
      rect.left + 5,
      rect.top + 5,
      rect.width - 10,
      24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(band, const Radius.circular(5)),
      Paint()
        ..color = durum ? const Color(0xFFE2A73C) : const Color(0xFF7C93A8),
    );
    _icon(
      canvas,
      durum ? 'doner_bekleme' : 'porsiyon_hazirlama',
      Offset(band.left + 18, band.center.dy),
      22,
      done: customer.anaUrunVerildi,
    );
    drawText(
      canvas,
      '${_ticketWorth(customer)}',
      Offset(band.right - 8, band.top + 4),
      size: 15,
      weight: 900,
      family: 'Rubik',
      right: true,
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

  /// Four wells, always, in enum order: wanted, forbidden, or neither.
  ///
  /// The empty ones carry the bonus an unmentioned ingredient is worth, which
  /// is the one economy rule a player had no way of discovering.
  void _ticketRail(Canvas canvas, Rect rect, Customer customer) {
    final order = customer.order;
    final durum = order.tip == UrunTipi.durum;
    final ids = durum
        ? Malzeme.values.map((m) => m.id).toList()
        : Bilesen.values.map((b) => b.id).toList();

    final pitch = (rect.width - 12) / ids.length;
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final at = Offset(
        rect.left + 6 + pitch * (i + 0.5),
        rect.top + 44,
      );
      final wanted = order.ister.contains(id);
      final banned = order.istemez.contains(id);
      final wrong = customer.hataKalan > 0 && customer.hatali.contains(id);
      final well = Rect.fromCenter(center: at, width: pitch - 3, height: 26);

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

      final image = assets[_iconAsset(order.tip, id)];
      if (image != null) {
        drawContained(canvas, image, at, 21);
      }
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
      } else if (!wanted) {
        drawText(
          canvas,
          '+${Balance.income(0, run.day, ingredients: 1)}',
          Offset(at.dx, well.bottom - 9),
          size: 8,
          weight: 800,
          family: 'Rubik',
          center: true,
          color: const Color(0x772E2A26),
        );
      }
    }
  }

  /// Two fixed sockets, dessert always left and drink always right, printed
  /// empty when there is none — so the eye learns one place to look.
  void _ticketExtras(Canvas canvas, Rect rect, Customer customer) {
    final order = customer.order;
    for (final (i, entry) in [
      (order.tatli?.asset, customer.tatliVerildi),
      (order.icecek?.servedAsset, customer.icecekVerildi),
    ].indexed) {
      final at = Offset(
        i == 0 ? rect.left + 22 : rect.right - 22,
        rect.top + 66,
      );
      final asset = entry.$1;
      if (asset == null) {
        canvas.drawCircle(
          at,
          9,
          Paint()
            ..color = const Color(0x1A2E2A26)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        continue;
      }
      _icon(canvas, asset, at, 19, done: entry.$2);
    }
  }

  String _iconAsset(UrunTipi tip, String id) => tip == UrunTipi.durum
      ? Malzeme.values.firstWhere((m) => m.id == id).portionAsset
      : Bilesen.values.firstWhere((b) => b.id == id).portionAsset;

  void _icon(
    Canvas canvas,
    String asset,
    Offset center,
    double size, {
    Color? ring,
    bool crossed = false,
    bool done = false,
  }) {
    final image = assets[asset];
    if (image == null) return;
    if (ring != null) {
      canvas.drawCircle(
        center,
        size * 0.62,
        Paint()
          ..color = ring.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    // No saveLayer: drawImageRect modulates by the paint's alpha on its own,
    // and for `done: false` — every constraint icon on every card — the layer
    // was a render-target switch applying alpha 1.
    drawCentered(
      canvas,
      image,
      center,
      size,
      paint: done ? _faded : null,
    );
    if (crossed) {
      final r = size * 0.5;
      canvas.drawLine(
        center + Offset(-r, r),
        center + Offset(r, -r),
        Paint()
          ..color = const Color(0xFFE0574A)
          ..strokeWidth = 2,
      );
    }
    if (done) {
      canvas.drawCircle(
        center,
        size * 0.62,
        Paint()..color = const Color(0x554CAF50),
      );
    }
  }

  void _renderCarried(Canvas canvas) {
    final held = run.carried;
    if (held == null) return;
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

  /// The run's momentum: a named band, a meter, and the last change still
  /// floating off it. Everything the counter is worth passes through this
  /// number, so it is drawn as large as the till it multiplies.
  void _renderTempo(Canvas canvas) {
    final tempo = run.tempo;
    final colour = _tempoColours[tempo.hal]!;

    // A track, not a socket: segmented like the grill dials, so the meter is
    // read as steps rather than as a smear.
    final track = RRect.fromRectAndRadius(
      _tempo,
      Radius.circular(_tempo.height / 2),
    );
    canvas
      ..drawRRect(
        track.shift(const Offset(0, 2)),
        Paint()..color = const Color(0x332E2A26),
      )
      ..drawRRect(track, Paint()..color = const Color(0xFF2E2A26))
      ..save()
      ..clipRRect(track)
      ..drawRect(
        Rect.fromLTWH(
          _tempo.left,
          _tempo.top,
          _tempo.width * tempo.oran,
          _tempo.height,
        ),
        Paint()..color = colour,
      )
      // A lit meter reads as filled; a bare rectangle of colour reads as a
      // loading bar.
      ..drawRect(
        Rect.fromLTWH(
          _tempo.left,
          _tempo.top + 2,
          _tempo.width * tempo.oran,
          _tempo.height * 0.36,
        ),
        Paint()..color = const Color(0x4DFFFFFF),
      );
    for (var i = 1; i < 10; i++) {
      final x = _tempo.left + _tempo.width * i / 10;
      canvas.drawLine(
        Offset(x, _tempo.top + 2),
        Offset(x, _tempo.bottom - 2),
        Paint()
          ..color = const Color(0x552E2A26)
          ..strokeWidth = 2,
      );
    }
    canvas.restore();

    // The stage is a glyph on a badge that sits proud of the plate, not a
    // word: read faster, and needs no translating.
    drawKey(
      canvas,
      Rect.fromCenter(center: _stage, width: 46, height: 40),
      colour,
    );
    drawGlyph(
      canvas,
      _tempoGlyphs[tempo.hal]!,
      _stage - const Offset(0, 1),
      24,
      const Color(0xFFFFF6E8),
    );

    // The change, floating off the meter. Without it the multiplier is
    // invisible and the player never learns what feeds it.
    if (tempo.degisimKalan <= 0) return;
    final delta = tempo.sonDegisim;
    final fade = (tempo.degisimKalan / 1.1).clamp(0.0, 1.0);
    drawText(
      canvas,
      '${delta > 0 ? '+' : ''}${delta.round()}',
      Offset(_tempo.right - 18, _tempo.top - 22 - (1 - fade) * 12),
      size: 17,
      weight: 900,
      family: 'Rubik',
      center: true,
      color: (delta > 0 ? const Color(0xFF2F8F3A) : const Color(0xFFC4321F))
          .withValues(alpha: fade),
    );
  }
}
