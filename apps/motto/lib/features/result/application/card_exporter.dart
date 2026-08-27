import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@lazySingleton
class CardExporter {
  const CardExporter();

  /// Scaled from the rendered size rather than a fixed pixel ratio, so a small
  /// display does not export a small image.
  Future<Uint8List?> capture(
    GlobalKey boundaryKey, {
    required double targetWidth,
  }) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(
      pixelRatio: targetWidth / boundary.size.width,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  /// Android usually answers [ShareResultStatus.unavailable] — it cannot see
  /// which app was picked — so the caller treats that as probably shared.
  Future<ShareResultStatus> share(
    Uint8List png, {
    required String archetypeName,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/motto-karti.png');
    await file.writeAsBytes(png, flush: true);

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        // No link and no hashtags: the picture is the message, and a caption
        // someone did not write is the first thing they delete.
        text: archetypeName,
      ),
    );

    return result.status;
  }
}
