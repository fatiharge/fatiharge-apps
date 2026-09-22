import 'dart:ui';

import 'package:kiyma/domain/quad.dart';

/// How an asset is sized inside its region.
enum AssetFit {
  /// Keep the aspect ratio, sit on the region's floor. The default: most
  /// things in the scene rest on a surface.
  alt,

  /// Keep the aspect ratio, centre it.
  orta,

  /// Stretch to the region. Only for fills whose shape does not read.
  doldur;

  static AssetFit parse(String? name) => switch (name) {
    'orta' => AssetFit.orta,
    'doldur' => AssetFit.doldur,
    _ => AssetFit.alt,
  };
}

/// One painted layer of the static kitchen, drawn before anything else.
class SceneLayer {
  const SceneLayer({
    required this.name,
    required this.src,
    required this.rect,
    required this.z,
  });

  factory SceneLayer.fromJson(Map<String, dynamic> json) => SceneLayer(
    name: json['name'] as String,
    src: json['src'] as String,
    rect: Rect.fromLTWH(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['w'] as num).toDouble(),
      (json['h'] as num).toDouble(),
    ),
    z: json['z'] as int,
  );

  final String name;

  /// Either a file under `assets/scene/` or an item family name.
  final String src;
  final Rect rect;
  final int z;

  bool get isSceneFile => src.contains('.');
}

/// One layer of a build-up product: which asset, how wide relative to the
/// region, and where its centre sits relative to the region's centre.
class CompositionLayer {
  const CompositionLayer({
    required this.name,
    required this.asset,
    required this.widthRatio,
    required this.offsetX,
    required this.offsetY,
  });

  factory CompositionLayer.fromJson(Map<String, dynamic> json) =>
      CompositionLayer(
        name: json['ad'] as String,
        asset: json['asset'] as String,
        widthRatio: (json['genislik'] as num).toDouble(),
        offsetX: (json['ofset_x'] as num).toDouble(),
        offsetY: (json['ofset_y'] as num).toDouble(),
      );

  final String name;
  final String asset;

  /// Fraction of the region's width.
  final double widthRatio;

  /// Fractions of the region's width and height, from its centre.
  final double offsetX;
  final double offsetY;
}

/// The recipe for a station that is built up layer by layer.
///
/// Five optional ingredients make 32 combinations, so a prepared wrap cannot
/// be a single drawn frame — it is stacked at draw time, which is what the
/// separate `*_durum` and `*_porsiyon` art was cut for.
class Composition {
  const Composition({
    required this.base,
    required this.ingredients,
    this.finished,
  });

  factory Composition.fromJson(Map<String, dynamic> json) => Composition(
    base: [
      for (final e in json['taban'] as List<dynamic>)
        CompositionLayer.fromJson(e as Map<String, dynamic>),
    ],
    ingredients: [
      for (final e in json['malzemeler'] as List<dynamic>)
        CompositionLayer.fromJson(e as Map<String, dynamic>),
    ],
    finished: json['son'] == null
        ? null
        : CompositionLayer.fromJson(json['son'] as Map<String, dynamic>),
  );

  final List<CompositionLayer> base;
  final List<CompositionLayer> ingredients;

  /// Replaces every layer above once the product is closed — the wrapped
  /// wrap. Absent on the plate, which is never closed.
  final CompositionLayer? finished;

  CompositionLayer? ingredient(String name) {
    for (final layer in ingredients) {
      if (layer.name == name) return layer;
    }
    return null;
  }
}

/// A named area of the scene: a source to take from, a station to build on,
/// a shelf to park on, or a customer's place at the counter.
class SceneRegion {
  SceneRegion({
    required this.name,
    required this.quad,
    required this.category,
    required this.fit,
    this.capacity,
    this.asset,
    this.horizontalSlots,
    this.stackRatio,
    this.composition,
  });

  factory SceneRegion.fromJson(Map<String, dynamic> json) {
    final quad = json['quad'] == null
        ? Quad.fromRect(
            Rect.fromLTWH(
              (json['x'] as num).toDouble(),
              (json['y'] as num).toDouble(),
              (json['w'] as num).toDouble(),
              (json['h'] as num).toDouble(),
            ),
          )
        : Quad.fromJson(json['quad'] as List<dynamic>);

    return SceneRegion(
      name: json['name'] as String,
      quad: quad,
      category: json['category'] as String,
      fit: AssetFit.parse(json['asset_fit'] as String?),
      capacity: json['kapasite'] as int?,
      asset: json['asset'] as String?,
      stackRatio: (json['istif'] as num?)?.toDouble(),
      horizontalSlots: switch (json['slot_yon'] as String?) {
        'yatay' => true,
        'dikey' => false,
        _ => null,
      },
      composition: json['kompozisyon'] == null
          ? null
          : Composition.fromJson(json['kompozisyon'] as Map<String, dynamic>),
    );
  }

  final String name;
  final Quad quad;
  final String category;
  final AssetFit fit;

  /// How many items the area seats. `null` where it holds one thing or none.
  final int? capacity;

  /// The idle art drawn in the area, if any.
  final String? asset;

  /// Overrides the long-axis rule in [Quad.slots].
  final bool? horizontalSlots;

  /// Set where the slots overlap rather than divide: how tall each one is as
  /// a fraction of the region.
  final double? stackRatio;

  final Composition? composition;

  /// Worked out once. The renderer asks four regions for their slots on
  /// every frame and none of them ever move; rebuilding the list each time
  /// was a thousand small allocations a second for an answer that is fixed
  /// when `scene.json` is parsed.
  late final List<Quad> slots = stackRatio == null
      ? quad.slots(capacity ?? 1, horizontal: horizontalSlots)
      : quad.stack(capacity ?? 1, stackRatio!);
}

/// Everything `assets/data/scene.json` says: the painted layers and the
/// regions laid over them, all in one 1024x576 reference space.
class SceneData {
  SceneData({required this.size, required this.layers, required this.regions})
    : _byName = {for (final region in regions) region.name: region};

  /// Parses what the art pipeline emitted. Reading the file is somebody
  /// else's job: keeping IO out of here is what lets the rules tests run
  /// without a Flutter binding.
  factory SceneData.fromJson(Map<String, dynamic> json) {
    final space = json['coordinate_space'] as Map<String, dynamic>;

    return SceneData(
      size: Size(
        (space['w'] as num).toDouble(),
        (space['h'] as num).toDouble(),
      ),
      layers: [
        for (final e in json['layers'] as List<dynamic>)
          SceneLayer.fromJson(e as Map<String, dynamic>),
      ]..sort((a, b) => a.z.compareTo(b.z)),
      regions: [
        for (final e in json['regions'] as List<dynamic>)
          SceneRegion.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  /// Where the pipeline writes it.
  static const asset = 'assets/data/scene.json';

  final Size size;
  final List<SceneLayer> layers;
  final List<SceneRegion> regions;
  final Map<String, SceneRegion> _byName;

  SceneRegion operator [](String name) {
    final region = _byName[name];
    if (region == null) throw StateError('scene.json has no region "$name"');
    return region;
  }

  SceneRegion? maybe(String name) => _byName[name];

  /// Regions a gesture can land on.
  ///
  /// The chef's place is a drawing anchor that covers the grill, and the
  /// grill is smaller than it. Leaving it in would make every hit test depend
  /// on which of the two happens to have the smaller bounding box. `dekor` is
  /// out for the plainer reason that a wall clock is not a place to put food.
  late final List<SceneRegion> interactive = [
    for (final region in regions)
      if (region.category != 'sef' && region.category != 'dekor') region,
  ];

  /// The region under [point], smallest first.
  ///
  /// The counter's own surface is a region too and it covers half the scene,
  /// so a first-match search would swallow everything on it. Area order makes
  /// the specific area win without any z ordering to maintain.
  ///
  /// The arithmetic lives here rather than on the run because a run is not
  /// the only thing that points at the kitchen: the shop is the same room
  /// with different rules about what may be touched, which is exactly what
  /// [kabul] is for.
  SceneRegion? at(Offset point, {bool Function(SceneRegion)? kabul}) {
    SceneRegion? best;
    var bestArea = double.infinity;
    for (final region in interactive) {
      if (!region.quad.contains(point)) continue;
      if (kabul != null && !kabul(region)) continue;
      final bounds = region.quad.bounds;
      final area = bounds.width * bounds.height;
      if (area < bestArea) {
        best = region;
        bestArea = area;
      }
    }
    return best;
  }

  /// Every item asset the scene references, so they can be preloaded in one
  /// bootstrap job instead of popping in mid-game.
  Set<String> get itemAssets => {
    for (final layer in layers)
      if (!layer.isSceneFile) layer.src,
    for (final region in regions) ...[
      if (region.asset != null) region.asset!,
      ...?region.composition?.base.map((l) => l.asset),
      ...?region.composition?.ingredients.map((l) => l.asset),
      ?region.composition?.finished?.asset,
    ],
  };
}
