import 'package:wallet/app/features/finance/domain/models/budget.dart';

/// Storage contract for monthly budgets.
abstract interface class BudgetRepository {
  Stream<List<Budget>> watchAll();

  Future<List<Budget>> fetchAll();

  Future<void> save(Budget budget);

  Future<void> delete(String id);
}
