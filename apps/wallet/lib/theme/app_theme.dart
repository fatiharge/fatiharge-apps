import 'package:flutter/material.dart';
import 'package:wallet/theme/finance_colors.dart';

/// The app's Material 3 themes.
///
/// Lives in the app rather than a `ui_kit` package: with one consumer there is
/// nothing to share yet. It moves out the day a second app needs it.
abstract final class AppTheme {
  /// The launcher tile and native launch screen, so the app opens in the
  /// colour it launched in. Material derives a lighter primary from it.
  static const Color navy = Color(0xFF262C54);

  /// The W in the mark. Never a text colour — 1.96:1 on a light surface.
  static const Color teal = Color(0xFF1CCFA3);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      extensions: [
        if (brightness == Brightness.dark)
          FinanceColors.dark
        else
          FinanceColors.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
