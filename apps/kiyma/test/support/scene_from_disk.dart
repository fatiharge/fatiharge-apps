import 'dart:convert';
import 'dart:io';

import 'package:kiyma/domain/scene.dart';

/// The shipped scene, read straight off disk.
///
/// The rules tests need real quads — the arithmetic they check is arithmetic
/// on measured corners — but they are pure Dart otherwise, and going through
/// the asset bundle would drag a Flutter binding into every one of them.
SceneData sceneFromDisk() => SceneData.fromJson(
  jsonDecode(File(SceneData.asset).readAsStringSync()) as Map<String, dynamic>,
);
