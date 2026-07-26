import 'package:injectable/injectable.dart';
import 'package:wallet/app/features/finance/domain/models/money_transaction.dart';
import 'package:wallet/app/features/finance/domain/repository/transaction_repository.dart';
import 'package:wallet/app/infrastructure/repository/dto/transaction_dto.dart';
import 'package:wallet/app/infrastructure/storage/hive_collection.dart';
import 'package:wallet/app/infrastructure/storage/wallet_storage.dart';

/// Hive-backed [TransactionRepository].
///
/// The only class in the app that knows transactions live in Hive.
@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(WalletStorage storage)
    : _collection = HiveCollection<MoneyTransaction>(
        box: storage.transactions,
        decode: TransactionDto.decode,
        encode: TransactionDto.encode,
        idOf: (transaction) => transaction.id,
      );

  final HiveCollection<MoneyTransaction> _collection;

  @override
  Stream<List<MoneyTransaction>> watchAll() => _collection.watchAll();

  @override
  Future<List<MoneyTransaction>> fetchAll() async => _collection.readAll();

  @override
  Future<void> save(MoneyTransaction transaction) =>
      _collection.put(transaction);

  @override
  Future<void> delete(String id) => _collection.delete(id);
}
