import 'package:flutter/material.dart';

/// The frame around the game, kept to the scene's own colours: the ember of
/// the grill and the char of the hood. The kitchen itself supplies every
/// other colour on screen, so the chrome stays out of its way.
abstract final class KiymaPalette {
  static const kor = Color(0xFFE9A13B);
  static const yesil = Color(0xFF6FCF7C);
  static const kirmizi = Color(0xFFE0574A);
  static const zemin = Color(0xFF14100F);
  static const panel = Color(0xF21C1715);
  static const yazi = Color(0xFFF6EFE6);
  static const soluk = Color(0x99F6EFE6);

  // The brand screen's own palette. The game's chrome is dark because it sits
  // over a lit kitchen; startup has no kitchen behind it and is cream, from
  // the Stitch design.
  static const krema = Color(0xFFF5E9D7);
  static const komur = Color(0xFF2E2A26);
  static const ates = Color(0xFFE8641A);
  static const ahsap = Color(0xFF8B5E34);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: zemin,
    colorScheme: const ColorScheme.dark(
      primary: kor,
      onPrimary: Color(0xFF1B1210),
      surface: panel,
      onSurface: yazi,
    ),
    textTheme: const TextTheme().apply(bodyColor: yazi, displayColor: yazi),
  );
}
