import 'package:wallet/features/finance/domain/models/budget.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// The default categories are deliberately meaningless (`misc`): a test that
/// cares which category a transaction lands in has to say so, and the linter
/// will not strip an argument that differs from the default.
MoneyTransaction expenseOf(
  int amountMinor, {
  String category = 'misc',
  DateTime? on,
  Currency currency = Currency.turkishLira,
  String? id,
  String? note,
}) => MoneyTransaction(
  id: id ?? 'e-$amountMinor-$category-${on?.millisecondsSinceEpoch ?? 0}',
  type: TransactionType.expense,
  categoryId: category,
  amount: Money(amountMinor, currency),
  date: on ?? DateTime(2026, 7, 15),
  note: note,
);

MoneyTransaction incomeOf(
  int amountMinor, {
  String category = 'misc_income',
  DateTime? on,
  Currency currency = Currency.turkishLira,
  String? id,
  String? note,
}) => MoneyTransaction(
  id: id ?? 'i-$amountMinor-$category-${on?.millisecondsSinceEpoch ?? 0}',
  type: TransactionType.income,
  categoryId: category,
  amount: Money(amountMinor, currency),
  date: on ?? DateTime(2026, 7, 15),
  note: note,
);

Budget budgetOf(
  int limitMinor, {
  String? category,
  Currency currency = Currency.turkishLira,
  String id = 'budget',
}) => Budget(
  id: id,
  limit: Money(limitMinor, currency),
  categoryId: category,
);

/// Defaults to a user-given [name]; pass [nameKey] for the seeded kind, whose
/// displayed name follows the locale.
Category categoryOf(
  String id, {
  String? name,
  String? nameKey,
  CategoryIcon icon = CategoryIcon.other,
  bool archived = false,
}) => Category(
  id: id,
  name: nameKey == null ? name ?? id : name,
  nameKey: nameKey,
  icon: icon,
  colorArgb: 0xFF607D8B,
  archived: archived,
);
