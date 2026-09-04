import 'dart:ui';

// `Quad` collides with vector_math's, which Flame re-exports everywhere.
import 'package:flame/components.dart' hide Quad;
import 'package:flame/events.dart';
import 'package:kiyma/core/quad.dart';
import 'package:kiyma/data/scene.dart';
import 'package:kiyma/game/assets.dart';
import 'package:kiyma/game/day_run.dart';
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
    required this.run,
    required this.onPause,
  }) : super(size: Vector2(scene.size.width, scene.size.height));

  final SceneData scene;
  final GameAssets assets;
  final DayRun run;
  final VoidCallback onPause;

  // The HUD lives in the scene, not over it: one coordinate space, the same
  // art, and a clock that can tick every frame without rebuilding a widget.
  // Sized for a phone held at arm's length rather than for the 1024-wide
  // reference space it is measured in.
  static const _gold = Rect.fromLTWH(14, 10, 312, 92);
  static const _clock = Rect.fromLTWH(376, 10, 272, 92);
  static const _day = Rect.fromLTWH(764, 6, 124, 108);
  static const _pause = Rect.fromLTWH(902, 10, 108, 92);

  /// Areas whose contents change during play, so their idle art is never the
  /// whole story and is drawn by the passes further down.
  static const _dynamic = {
    'mangal_alani',
    'durum_bekleme',
    'bardak_bekletme',
    'tabak_hazirlama',
    'durum_hazirlama',
  };

  static const Map<Pisme, Color> _cookColors = {
    Pisme.cig: Color(0xFFE0574A),
    Pisme.pisiyor: Color(0xFFE9A13B),
    Pisme.pismis: Color(0xFF5FBF6A),
    Pisme.yanmis: Color(0xFF4A3430),
  };

  Offset _last = Offset.zero;
  Offset _start = Offset.zero;
  double _elapsed = 0;
  double _dragTime = 0;

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
    _dragTime = _elapsed;
    run.beginDrag(_start);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _last = _scene(event.canvasEndPosition);
    run.carriedAt = _last;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final travel = _last - _start;
    final duration = _elapsed - _dragTime;

    // A tap reaches here as a drag that never moved, so by now the source has
    // already been picked up. Put it back before treating it as a tap, or
    // every touch on a tray reads as a drop onto itself.
    if (travel.distance < 12 && duration < 0.35) {
      run.cancelDrag();
      if (_pause.contains(_start)) {
        onPause();
        return;
      }
      run.tap(_start);
      return;
    }
    if (run.carried != null) {
      run.endDrag(_last);
      return;
    }
    if (travel.dy < -30 && travel.dy.abs() > travel.dx.abs()) {
      run.flickUp(_start);
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (run.carried != null) run.endDrag(_last);
  }

  // --- Drawing ---

  @override
  void render(Canvas canvas) {
    _renderScene(canvas);
    _renderSources(canvas);
    _renderMangal(canvas);
    _renderDurum(canvas);
    _renderTabak(canvas);
    _renderShelves(canvas);
    _renderTrash(canvas);
    _renderCustomers(canvas);
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
          _dynamic.contains(region.name) ||
          !run.progress.unlocks.shows(region.name)) {
        continue;
      }
      final image = assets[asset];
      if (image != null) drawInQuad(canvas, image, region.quad, region.fit);
    }
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
      // Burnt is the end of the clock and the charred skewer says so on its
      // own; a full bar there just reads as another rod on the grill.
      if (durum == Pisme.yanmis) continue;
      drawBar(
        canvas,
        Rect.fromCenter(
          center: slots[i].center - const Offset(0, 15),
          width: slots[i].width * 0.5,
          height: 4,
        ),
        slot.ilerleme(run.day),
        color: _cookColors[durum]!,
        angle: slots[i].angle,
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

  /// Drawn rather than loaded: the bin is mandatory in the design and the art
  /// repository has no asset for it. Swap in `cop_kovasi.png` and this
  /// becomes one `drawInQuad`.
  void _renderTrash(Canvas canvas) {
    final quad = scene['cop_alani'].quad;
    final bounds = quad.bounds.deflate(6);
    final body = Rect.fromLTRB(
      bounds.left + 6,
      bounds.top + 14,
      bounds.right - 2,
      bounds.bottom,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndCorners(
          body,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF8E959C),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bounds.left, bounds.top + 4, bounds.width, 12),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFFB4BBC2),
      );
    for (var i = 1; i < 4; i++) {
      final x = body.left + body.width * i / 4;
      canvas.drawLine(
        Offset(x, body.top + 8),
        Offset(x, body.bottom - 6),
        Paint()
          ..color = const Color(0x33202428)
          ..strokeWidth = 2,
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
    final coins = assets['altin'];
    if (coins == null) return;

    for (var i = 0; i < slots.length; i++) {
      final amount = run.altin[i];
      if (amount == null) continue;
      drawInQuad(canvas, coins, slots[i], AssetFit.alt);
      // Above the pile on its own dark tag: gold on gold cannot be read.
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
        Paint()..color = const Color(0xE62E2A26),
      );
      drawText(
        canvas,
        '$amount',
        tag,
        size: 14,
        weight: 800,
        family: 'Rubik',
        center: true,
        color: const Color(0xFFFFE9B0),
      );
    }
  }

  /// The till, the clock, the day and the pause button, drawn as counter
  /// signage rather than as an overlay.
  void _renderHud(Canvas canvas) {
    drawPanel(canvas, _gold);
    final coins = assets['altin'];
    if (coins != null) {
      drawCentered(canvas, coins, Offset(_gold.left + 68, _gold.center.dy), 92);
    }
    drawText(
      canvas,
      '${run.progress.para}',
      Offset(_gold.left + 132, _gold.top + 22),
      size: 44,
      weight: 800,
      family: 'Rubik',
      color: const Color(0xFF2E2A26),
    );

    final left = run.kalanSure.ceil();
    drawPanel(canvas, _clock);
    drawText(
      canvas,
      '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}',
      Offset(_clock.center.dx, _clock.top + 16),
      size: 52,
      weight: 900,
      family: 'Rubik',
      center: true,
      color: run.kalanSure < 20
          ? const Color(0xFFC4321F)
          : const Color(0xFF2E2A26),
    );

    final calendar = assets['takvim'];
    if (calendar != null) {
      drawInQuad(canvas, calendar, Quad.fromRect(_day), AssetFit.orta);
      drawText(
        canvas,
        '${run.day}',
        Offset(_day.center.dx, _day.top + 44),
        size: 48,
        weight: 900,
        family: 'Rubik',
        center: true,
        color: const Color(0xFF2E2A26),
      );
    }

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

  void _renderCustomers(Canvas canvas) {
    for (var i = 0; i < 4; i++) {
      final quad = scene['musteri_slot_${i + 1}'].quad;
      if (i >= run.progress.unlocks.musteriSlots) continue;
      final customer = run.musteriler[i];
      if (customer == null) continue;
      _renderCustomer(canvas, quad, customer);
    }
  }

  /// A stand-in body and a real order card.
  ///
  /// The characters are the one part of the art that was never drawn — they
  /// are meant to be animated. What the player actually has to read is the
  /// card, so that is what gets the pixels.
  void _renderCustomer(Canvas canvas, Quad quad, Customer customer) {
    final bounds = quad.bounds;
    final skin = Paint()..color = const Color(0xFF6B5344);
    canvas
      ..drawCircle(
        Offset(bounds.center.dx, bounds.top + 26),
        19,
        skin,
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
        skin,
      );

    final card = Rect.fromLTWH(
      bounds.left - 13,
      bounds.top + 58,
      bounds.width + 26,
      76,
    );
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
    const wantColor = Color(0xFF6FCF7C);
    const avoidColor = Color(0xFFE0574A);

    _icon(
      canvas,
      order.tip == UrunTipi.durum ? 'doner_bekleme' : 'porsiyon_hazirlama',
      Offset(card.left + 20, card.top + 20),
      26,
      done: customer.anaUrunVerildi,
    );

    // Three constraints at most, so one row is always enough.
    var x = card.left + 44;

    for (final id in order.ister) {
      _icon(
        canvas,
        _iconAsset(order.tip, id),
        Offset(x, card.top + 20),
        17,
        ring: wantColor,
      );
      x += 19;
    }
    for (final id in order.istemez) {
      _icon(
        canvas,
        _iconAsset(order.tip, id),
        Offset(x, card.top + 20),
        17,
        ring: avoidColor,
        crossed: true,
      );
      x += 19;
    }

    var side = card.right - 18;
    final icecek = order.icecek;
    if (icecek != null) {
      _icon(
        canvas,
        icecek.servedAsset,
        Offset(side, card.top + 50),
        18,
        done: customer.icecekVerildi,
      );
      side -= 22;
    }
    final tatli = order.tatli;
    if (tatli != null) {
      _icon(
        canvas,
        tatli.asset,
        Offset(side, card.top + 50),
        20,
        done: customer.tatliVerildi,
      );
    }

    drawBar(
      canvas,
      Rect.fromLTWH(card.left + 9, card.bottom - 10, card.width - 18, 5),
      customer.sabirOrani,
      color: Color.lerp(avoidColor, wantColor, customer.sabirOrani)!,
    );
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
    canvas.saveLayer(
      Rect.fromCircle(center: center, radius: size),
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: done ? 0.3 : 1),
    );
    drawCentered(canvas, image, center, size);
    canvas.restore();
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
