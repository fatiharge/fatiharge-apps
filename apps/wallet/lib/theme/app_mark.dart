import 'package:flutter/material.dart';

/// The Warizo mark — the launcher icon, shown inside the app.
///
/// Lives in `theme/` rather than in either feature that draws it: the about
/// page and the splash both need it, and features are not allowed to depend on
/// each other. It moves to `ui_kit` the day that package exists.
///
/// Carries its own navy tile, so it needs no light/dark variant and no tinting
/// — a brand mark that changes colour with the theme stops being one. The
/// rounded corners are baked into the asset, which is why there is no
/// [ClipRRect] here.
class AppMark extends StatelessWidget {
  const AppMark({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/branding/app_mark.png',
    // The asset is 256px, so any [size] above that upscales rather than draws.
    width: size,
    height: size,
  );
}
