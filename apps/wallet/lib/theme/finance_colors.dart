import 'package:flutter/material.dart';

/// Not [ColorScheme] slots: none of them means "expense", and lending `error`
/// to it would tie a failed validation and a spent lira to one colour.
@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({required this.income, required this.expense});

  /// Split per brightness because no single mid-tone clears 4.5:1 on both a
  /// near-white and a near-black surface. Ratios are against that surface.
  static const light = FinanceColors(
    income: Color(0xFF0F7A5F), // 5.2:1 — the mark's teal, legible on white
    expense: Color(0xFFC62828), // 5.5:1
  );

  static const dark = FinanceColors(
    income: Color(0xFF4FE0B8), // 11.2:1
    expense: Color(0xFFFF8A80), // 8.1:1
  );

  final Color income;
  final Color expense;

  static FinanceColors of(BuildContext context) =>
      Theme.of(context).extension<FinanceColors>()!;

  Color amountColor({required bool isExpense}) => isExpense ? expense : income;

  @override
  FinanceColors copyWith({Color? income, Color? expense}) => FinanceColors(
    income: income ?? this.income,
    expense: expense ?? this.expense,
  );

  @override
  FinanceColors lerp(FinanceColors? other, double t) {
    if (other == null) return this;
    return FinanceColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
    );
  }

  /// [ThemeExtension] brings no equality, so without this two identical
  /// palettes compare unequal and every rebuild looks like a theme change.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceColors &&
          other.income == income &&
          other.expense == expense;

  @override
  int get hashCode => Object.hash(income, expense);
}
