import 'package:flutter/material.dart';
import 'package:motto/theme/motto_palette.dart';

/// Both themes from one scheme. Following the system costs a second pass over
/// every screen, and is worth it: the screenshot people share is taken in
/// whichever mode their phone is in.
abstract final class MottoTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: MottoPalette.seed,
      brightness: brightness,
      surface: isDark ? MottoPalette.darkSurface : MottoPalette.lightSurface,
    );

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    final ink = isDark ? MottoPalette.darkInk : MottoPalette.lightInk;

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(base.textTheme, ink),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
    );
  }

  /// Tighter than the Material default. Archetype names are set large and want
  /// to read as a title rather than a heading in a form.
  static TextTheme _textTheme(TextTheme base, Color ink) => base
      .apply(bodyColor: ink, displayColor: ink)
      .copyWith(
        displaySmall: base.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      );
}
