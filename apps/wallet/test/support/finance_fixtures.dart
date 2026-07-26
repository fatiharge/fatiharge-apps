import 'package:wallet/app/features/finance/domain/models/budget.dart';
import 'package:wallet/app/features/finance/domain/models/category.dart';
import 'package:wallet/app/features/finance/domain/models/currency.dart';
import 'package:wallet/app/features/finance/domain/models/money.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';

/// Shorthand builders so tests read as data, not as constructor noise.
MoneyTransaction expenseOf(
  int amountMinor, {
  String category = 'food',
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
  String category = 'salary',
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
  String id = 'b1',
}) => Budget(
  id: id,
  limit: Money(limitMinor, currency),
  categoryId: category,
);

Category categoryOf(
  String id, {
  String? name,
  CategoryIcon icon = CategoryIcon.other,
  bool archived = false,
}) => Category(
  id: id,
  name: name ?? id,
  icon: icon,
  colorArgb: 0xFF607D8B,
  archived: archived,
);
