import 'package:wallet/features/finance/domain/models/budget.dart';

abstract interface class BudgetRepository {
  Stream<List<Budget>> watchAll();

  Future<List<Budget>> fetchAll();

  Future<void> save(Budget budget);

  Future<void> delete(String id);
}
