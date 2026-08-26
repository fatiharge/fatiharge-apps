import 'package:wallet/features/finance/domain/models/category.dart';

abstract interface class CategoryRepository {
  /// Every category, archived ones included — history needs them to resolve
  /// the name and colour of past transactions.
  Stream<List<Category>> watchAll();

  Future<List<Category>> fetchAll();

  Future<void> save(Category category);

  /// Hides [id] from pickers without destroying it. There is no hard delete:
  /// transactions reference categories by id and must keep resolving.
  Future<void> archive(String id);

  Future<void> restore(String id);
}
