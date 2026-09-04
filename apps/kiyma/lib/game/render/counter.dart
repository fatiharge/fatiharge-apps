import 'dart:math' as math;
import 'dart:ui';

// `Quad` collides with vector_math's, which Flame re-exports everywhere.
import 'package:flame/components.dart' hide Quad;
import 'package:flame/events.dart';
// Only for the two glyphs the grill badges carry.
import 'package:flutter/material.dart' show IconData, Icons;
import 'package:kiyma/core/quad.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/day_run.dart';
import 'package:kiyma/game/gesture.dart';
import 'package:kiyma/game/halo.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/order.dart';
import 'package:kiyma/game/model/products.dart';
import 'package:kiyma/game/render/painter.dart';

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

  // What is left of the HUD after the clock and the calendar moved onto the
  // wall: the till and the pause button, both still chrome. They share the
  // top-left because the whole right-hand wall is now the clock's.
  static const _pause = Rect.fromLTWH(14, 10, 88, 88);
  static const _gold = Rect.fromLTWH(114, 10, 282, 88);

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

  Offset _last = Offset.zero;
  Offset _start = Offset.zero;
  double _elapsed = 0;

  /// How far this drag has ever got from where it started.
  double _travel = 0;

  @override
  void update(double dt) {
    _elapsed += dt;
    run.tick(dt);
  }

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
    _renderScene(canvas);
    _renderWall(canvas);
    // Somebody still crossing the shop passes behind what is standing on the
    // counter; by the time they are at their place nothing is in front of
    // them anyway, so the two passes never disagree about one customer.
    _renderMovers(canvas);
    _renderSources(canvas);
    _renderMangal(canvas);
    _renderDurum(canvas);
    _renderTabak(canvas);
    _renderShelves(canvas);
    _renderSeated(canvas);
    _renderGold(canvas);
    _renderCarried(canvas);
    _renderFlashes(canvas);
    _renderHud(canvas);
  }

  void _renderScene(Canvas canvas) {
    for (final layer in scene.layers) {
      final image = assets[layer.src];
      if (image != null) {
        drawInQuad(canvas, image, Quad.fromRect(layer.rect), AssetFit.doldur);
      }
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

  /// What is left over the scene: the till and the pause button.
  void _renderHud(Canvas canvas) {
    drawPanel(canvas, _gold);
    final coins = assets['altin'];
    if (coins != null) {
      drawCentered(canvas, coins, Offset(_gold.left + 66, _gold.center.dy), 88);
    }
    drawText(
      canvas,
      '${run.progress.para}',
      Offset(_gold.left + 128, _gold.top + 20),
      size: 44,
      weight: 800,
      family: 'Rubik',
      color: const Color(0xFF2E2A26),
    );

    drawPanel(canvas, _pause);
    for (final dx in [-12.0, 12.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: _pause.center + Offset(dx, 0),
            width: 14,
            height: 44,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF2E2A26),
      );
    }
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
      _renderPatience(canvas, head, customer);
      _renderOrder(canvas, head, customer);
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

  /// Upright, on the left of the head: a bar lying across the order card was
  /// one more thing to find inside it.
  void _renderPatience(Canvas canvas, Offset head, Customer customer) {
    drawBar(
      canvas,
      Rect.fromCenter(
        center: Offset(head.dx - 30, head.dy + 12),
        width: 62,
        height: 11,
      ),
      customer.sabirOrani,
      color: Color.lerp(_avoid, _want, customer.sabirOrani)!,
      background: const Color(0xCC141A20),
      angle: -math.pi / 2,
    );
  }

  void _renderOrder(Canvas canvas, Offset head, Customer customer) {
    final card = Rect.fromLTWH(head.dx + 22, head.dy - 26, 88, 74);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(card, const Radius.circular(8)),
        Paint()..color = const Color(0xF2141A20),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(card.deflate(0.5), const Radius.circular(8)),
        Paint()
          ..color = const Color(0x33FFFFFF)
          ..style = PaintingStyle.stroke,
      );

    final order = customer.order;
    _icon(
      canvas,
      order.tip == UrunTipi.durum ? 'doner_bekleme' : 'porsiyon_hazirlama',
      Offset(card.left + 17, card.top + 18),
      24,
      done: customer.anaUrunVerildi,
    );

    // Three constraints at most, so one row is always enough.
    var x = card.left + 38;
    for (final id in order.ister) {
      _icon(
        canvas,
        _iconAsset(order.tip, id),
        Offset(x, card.top + 18),
        15,
        ring: _want,
      );
      x += 17;
    }
    for (final id in order.istemez) {
      _icon(
        canvas,
        _iconAsset(order.tip, id),
        Offset(x, card.top + 18),
        15,
        ring: _avoid,
        crossed: true,
      );
      x += 17;
    }

    var side = card.right - 16;
    final icecek = order.icecek;
    if (icecek != null) {
      _icon(
        canvas,
        icecek.servedAsset,
        Offset(side, card.top + 50),
        17,
        done: customer.icecekVerildi,
      );
      side -= 21;
    }
    final tatli = order.tatli;
    if (tatli != null) {
      _icon(
        canvas,
        tatli.asset,
        Offset(side, card.top + 50),
        19,
        done: customer.tatliVerildi,
      );
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
}
