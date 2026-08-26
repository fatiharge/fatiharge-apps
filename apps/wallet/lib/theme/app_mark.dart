import 'package:flutter/material.dart';

/// In `theme/` because two features draw it and features may not depend on
/// each other. The navy tile and rounded corners are baked into the asset —
/// hence no tinting and no [ClipRRect].
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
