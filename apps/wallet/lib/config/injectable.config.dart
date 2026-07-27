// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:wallet/config/modules/storage_module.dart' as _i135;
import 'package:wallet/features/finance/application/budget/budget_cubit.dart'
    as _i1038;
import 'package:wallet/features/finance/application/dashboard/dashboard_cubit.dart'
    as _i990;
import 'package:wallet/features/finance/application/entry/entry_cubit.dart'
    as _i682;
import 'package:wallet/features/finance/application/history/history_bloc.dart'
    as _i773;
import 'package:wallet/features/finance/domain/repository/budget_repository.dart'
    as _i750;
import 'package:wallet/features/finance/domain/repository/category_repository.dart'
    as _i976;
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart'
    as _i442;
import 'package:wallet/infrastructure/repository/budget_repository_impl.dart'
    as _i864;
import 'package:wallet/infrastructure/repository/category_repository_impl.dart'
    as _i587;
import 'package:wallet/infrastructure/repository/transaction_repository_impl.dart'
    as _i389;
import 'package:wallet/infrastructure/storage/wallet_storage.dart' as _i255;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    await gh.singletonAsync<_i255.WalletStorage>(
      () => storageModule.storage,
      preResolve: true,
    );
    gh.lazySingleton<_i442.TransactionRepository>(
      () => _i389.TransactionRepositoryImpl(gh<_i255.WalletStorage>()),
    );
    gh.lazySingleton<_i976.CategoryRepository>(
      () => _i587.CategoryRepositoryImpl(gh<_i255.WalletStorage>()),
    );
    gh.lazySingleton<_i750.BudgetRepository>(
      () => _i864.BudgetRepositoryImpl(gh<_i255.WalletStorage>()),
    );
    gh.factory<_i1038.BudgetCubit>(
      () => _i1038.BudgetCubit(
        gh<_i750.BudgetRepository>(),
        gh<_i442.TransactionRepository>(),
        gh<_i976.CategoryRepository>(),
      ),
    );
    gh.factory<_i682.EntryCubit>(
      () => _i682.EntryCubit(
        gh<_i442.TransactionRepository>(),
        gh<_i976.CategoryRepository>(),
      ),
    );
    gh.factory<_i773.HistoryBloc>(
      () => _i773.HistoryBloc(
        gh<_i442.TransactionRepository>(),
        gh<_i976.CategoryRepository>(),
      ),
    );
    gh.factory<_i990.DashboardCubit>(
      () => _i990.DashboardCubit(
        gh<_i442.TransactionRepository>(),
        gh<_i976.CategoryRepository>(),
        gh<_i750.BudgetRepository>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i135.StorageModule {}
