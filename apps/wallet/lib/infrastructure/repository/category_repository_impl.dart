import 'package:injectable/injectable.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/infrastructure/repository/dto/category_dto.dart';
import 'package:wallet/infrastructure/storage/hive_collection.dart';
import 'package:wallet/infrastructure/storage/wallet_storage.dart';

/// Hive-backed [CategoryRepository].
@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(WalletStorage storage)
    : _collection = HiveCollection<Category>(
        box: storage.categories,
        decode: CategoryDto.decode,
        encode: CategoryDto.encode,
        idOf: (category) => category.id,
      );

  final HiveCollection<Category> _collection;

  @override
  Stream<List<Category>> watchAll() => _collection.watchAll();

  @override
  Future<List<Category>> fetchAll() async => _collection.readAll();

  @override
  Future<void> save(Category category) => _collection.put(category);

  @override
  Future<void> archive(String id) => _setArchived(id, archived: true);

  @override
  Future<void> restore(String id) => _setArchived(id, archived: false);

  /// A no-op for an unknown id: archiving something already gone is not an
  /// error worth crashing a screen over.
  Future<void> _setArchived(String id, {required bool archived}) async {
    final category = _collection.read(id);
    if (category == null) return;
    await _collection.put(category.copyWith(archived: archived));
  }
}
