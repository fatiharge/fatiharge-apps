import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/finance/domain/models/money.dart';
import 'package:wallet/features/finance/domain/models/money_transaction.dart';

/// This file is the schema. Changing a key here is a migration; the domain
/// model can be refactored freely without touching stored data.
abstract final class TransactionDto {
  static const _id = 'id';
  static const _type = 'type';
  static const _categoryId = 'categoryId';
  static const _amountMinor = 'amountMinor';
  static const _currency = 'currency';
  static const _date = 'date';
  static const _note = 'note';

  static Map<String, dynamic> encode(MoneyTransaction transaction) =>
      <String, dynamic>{
        _id: transaction.id,
        _type: transaction.type.name,
        _categoryId: transaction.categoryId,
        _amountMinor: transaction.amount.amountMinor,
        _currency: transaction.amount.currency.code,
        // Epoch millis, not an ISO string: unambiguous and cheap to sort.
        _date: transaction.date.millisecondsSinceEpoch,
        _note: transaction.note,
      };

  static MoneyTransaction decode(Map<String, dynamic> record) =>
      MoneyTransaction(
        id: record[_id] as String,
        type: TransactionType.values.byName(record[_type] as String),
        categoryId: record[_categoryId] as String,
        amount: Money(
          record[_amountMinor] as int,
          Currency.fromCode(record[_currency] as String),
        ),
        date: DateTime.fromMillisecondsSinceEpoch(record[_date] as int),
        note: record[_note] as String?,
      );
}
