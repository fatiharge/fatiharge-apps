import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:kiyma/domain/scene.dart';

/// Reads the scene off the asset bundle.
///
/// Split from [SceneData] so the model stays free of IO: the rules tests
/// drive it with a map read from disk and need no Flutter binding for it.
Future<SceneData> loadSceneAsset() async => SceneData.fromJson(
  jsonDecode(await rootBundle.loadString(SceneData.asset))
      as Map<String, dynamic>,
);
