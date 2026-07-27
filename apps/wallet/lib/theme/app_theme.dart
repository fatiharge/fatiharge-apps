import 'package:flutter/material.dart';

/// The app's Material 3 themes.
///
/// Lives in the app rather than a `ui_kit` package: with one consumer there is
/// nothing to share yet. It moves out the day a second app needs it.
abstract final class AppTheme {
  static const Color seed = Color(0xFF2E7D32);

  /// Green for income, red for expense — used by charts and amount labels.
  static const Color income = Color(0xFF2E7D32);
  static const Color expense = Color(0xFFC62828);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
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

  /// The colour an amount should be drawn in.
  static Color amountColor(BuildContext context, {required bool isExpense}) =>
      isExpense ? expense : income;
}
