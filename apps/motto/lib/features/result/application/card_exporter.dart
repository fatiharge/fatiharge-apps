import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Turns the card on screen into a file the share sheet can carry.
@lazySingleton
class CardExporter {
  const CardExporter();

  /// Captures whatever the boundary is painting, at [targetWidth] regardless of
  /// the phone's own resolution.
  ///
  /// Scaled from the rendered size rather than a fixed pixel ratio: the card is
  /// laid out to fit the screen, so a phone with a small display would
  /// otherwise export a small image, and a feed re-compressing a small image is
  /// how a card ends up looking cheap.
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

  /// Writes the image out and opens the system share sheet.
  Future<void> share(Uint8List png, {required String archetypeName}) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/motto-karti.png');
    await file.writeAsBytes(png, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        // No link and no hashtags: the picture is the message, and a caption
        // someone did not write is the first thing they delete.
        text: archetypeName,
      ),
    );
  }
}
