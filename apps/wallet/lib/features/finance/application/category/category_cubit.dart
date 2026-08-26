import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/features/finance/application/category/category_state.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._categories) : super(const CategoryState());

  final CategoryRepository _categories;

  static const _uuid = Uuid();

  StreamSubscription<void>? _subscription;

  void start() {
    _subscription ??= _categories.watchAll().listen(
      (items) => emit(CategoryState(categories: items, loading: false)),
    );
  }

  /// The category is stored with a `name` and no `nameKey`: it is the user's
  /// own, so a language switch must leave it alone.
  Future<bool> add({
    required String name,
    required CategoryIcon icon,
    required int colorArgb,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    await _categories.save(
      Category(
        id: _uuid.v4(),
        name: trimmed,
        icon: icon,
        colorArgb: colorArgb,
      ),
    );
    return true;
  }

  Future<void> archive(String id) => _categories.archive(id);

  Future<void> restore(String id) => _categories.restore(id);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
