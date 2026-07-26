import 'package:injectable/injectable.dart';
import 'package:wallet/app/features/finance/domain/models/budget.dart';
import 'package:wallet/app/features/finance/domain/repository/budget_repository.dart';
import 'package:wallet/app/infrastructure/repository/dto/budget_dto.dart';
import 'package:wallet/app/infrastructure/storage/hive_collection.dart';
import 'package:wallet/app/infrastructure/storage/wallet_storage.dart';

/// Hive-backed [BudgetRepository].
@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(WalletStorage storage)
    : _collection = HiveCollection<Budget>(
        box: storage.budgets,
        decode: BudgetDto.decode,
        encode: BudgetDto.encode,
        idOf: (budget) => budget.id,
      );

  final HiveCollection<Budget> _collection;

  @override
  Stream<List<Budget>> watchAll() => _collection.watchAll();

  @override
  Future<List<Budget>> fetchAll() async => _collection.readAll();

  @override
  Future<void> save(Budget budget) => _collection.put(budget);

  @override
  Future<void> delete(String id) => _collection.delete(id);
}
