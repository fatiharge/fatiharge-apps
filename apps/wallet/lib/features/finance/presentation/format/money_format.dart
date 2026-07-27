import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// Money and date formatting for the UI.
///
/// The domain stores minor units and knows nothing about locales; every
/// human-readable string is produced here.
extension MoneyFormatting on Money {
  /// e.g. `₺1.234,56` in `tr`, `$1,234.56` in `en`.
  String format(BuildContext context) => NumberFormat.currency(
    locale: context.locale.toString(),
    symbol: currency.symbol,
    decimalDigits: currency.decimalDigits,
  ).format(amountMajor);

  /// Same as [format] but with an explicit sign, for transaction rows.
  String formatSigned(BuildContext context, {required bool isExpense}) {
    final prefix = isZero ? '' : (isExpense ? '-' : '+');
    return '$prefix${abs().format(context)}';
  }

  /// Compact form for chart labels, e.g. `₺1,2 B`.
  String formatCompact(BuildContext context) => NumberFormat.compactCurrency(
    locale: context.locale.toString(),
    symbol: currency.symbol,
  ).format(amountMajor);
}

extension TransactionFormatting on MoneyTransaction {
  String formatAmount(BuildContext context) =>
      amount.formatSigned(context, isExpense: isExpense);
}

extension DateFormatting on DateTime {
  /// e.g. `15 Tem 2026`.
  String formatDay(BuildContext context) =>
      DateFormat.yMMMd(context.locale.toString()).format(this);

  /// e.g. `Temmuz 2026`.
  String formatMonth(BuildContext context) =>
      DateFormat.yMMMM(context.locale.toString()).format(this);
}
