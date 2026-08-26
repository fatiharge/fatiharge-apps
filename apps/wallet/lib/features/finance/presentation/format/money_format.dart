import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// The domain stores minor units and knows nothing about locales; every
/// human-readable string is produced here.
extension MoneyFormatting on Money {
  String format(BuildContext context) => NumberFormat.currency(
    locale: context.locale.toString(),
    symbol: currency.symbol,
    decimalDigits: currency.decimalDigits,
  ).format(amountMajor);

  String formatSigned(BuildContext context, {required bool isExpense}) {
    final prefix = isZero ? '' : (isExpense ? '-' : '+');
    return '$prefix${abs().format(context)}';
  }

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
  String formatDay(BuildContext context) =>
      DateFormat.yMMMd(context.locale.toString()).format(this);

  String formatMonth(BuildContext context) =>
      DateFormat.yMMMM(context.locale.toString()).format(this);
}
