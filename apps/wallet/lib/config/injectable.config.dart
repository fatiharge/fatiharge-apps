// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:wallet/config/modules/storage_module.dart' as _i253;
import 'package:wallet/features/about/domain/app_version_port.dart' as _i198;
import 'package:wallet/features/finance/application/budget/budget_cubit.dart'
    as _i203;
import 'package:wallet/features/finance/application/category/category_cubit.dart'
    as _i639;
import 'package:wallet/features/finance/application/dashboard/dashboard_cubit.dart'
    as _i444;
import 'package:wallet/features/finance/application/entry/entry_cubit.dart'
    as _i346;
import 'package:wallet/features/finance/application/history/history_bloc.dart'
    as _i186;
import 'package:wallet/features/finance/domain/repository/budget_repository.dart'
    as _i469;
import 'package:wallet/features/finance/domain/repository/category_repository.dart'
    as _i270;
import 'package:wallet/features/finance/domain/repository/transaction_repository.dart'
    as _i616;
import 'package:wallet/features/onboarding/application/onboarding_cubit.dart'
    as _i92;
import 'package:wallet/features/settings/application/summary_reminder_controller.dart'
    as _i337;
import 'package:wallet/features/settings/domain/repository/settings_repository.dart'
    as _i97;
import 'package:wallet/features/settings/domain/summary_notifier.dart' as _i839;
import 'package:wallet/infrastructure/adapter/notification/summary_notifier_adapter.dart'
    as _i131;
import 'package:wallet/infrastructure/adapter/version/package_info_version_adapter.dart'
    as _i333;
import 'package:wallet/infrastructure/repository/budget_repository_impl.dart'
    as _i137;
import 'package:wallet/infrastructure/repository/category_repository_impl.dart'
    as _i353;
import 'package:wallet/infrastructure/repository/transaction_repository_impl.dart'
    as _i1031;
import 'package:wallet/infrastructure/storage/wallet_storage.dart' as _i448;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    await gh.singletonAsync<_i448.WalletStorage>(
      () => storageModule.storage,
      preResolve: true,
    );
    gh.lazySingleton<_i616.TransactionRepository>(
      () => _i1031.TransactionRepositoryImpl(gh<_i448.WalletStorage>()),
    );
    gh.lazySingleton<_i198.AppVersionPort>(
      () => _i333.PackageInfoVersionAdapter(),
    );
    gh.lazySingleton<_i270.CategoryRepository>(
      () => _i353.CategoryRepositoryImpl(gh<_i448.WalletStorage>()),
    );
    gh.lazySingleton<_i469.BudgetRepository>(
      () => _i137.BudgetRepositoryImpl(gh<_i448.WalletStorage>()),
    );
    gh.factory<_i444.DashboardCubit>(
      () => _i444.DashboardCubit(
        gh<_i616.TransactionRepository>(),
        gh<_i270.CategoryRepository>(),
        gh<_i469.BudgetRepository>(),
        gh<_i97.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i839.SummaryNotifier>(
      () => _i131.SummaryNotifierAdapter(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.factory<_i346.EntryCubit>(
      () => _i346.EntryCubit(
        gh<_i616.TransactionRepository>(),
        gh<_i270.CategoryRepository>(),
        gh<_i97.SettingsRepository>(),
      ),
    );
    gh.factory<_i186.HistoryBloc>(
      () => _i186.HistoryBloc(
        gh<_i616.TransactionRepository>(),
        gh<_i270.CategoryRepository>(),
      ),
    );
    gh.factory<_i92.OnboardingCubit>(
      () => _i92.OnboardingCubit(
        gh<_i270.CategoryRepository>(),
        gh<_i97.SettingsRepository>(),
      ),
    );
    gh.factory<_i639.CategoryCubit>(
      () => _i639.CategoryCubit(gh<_i270.CategoryRepository>()),
    );
    gh.factory<_i203.BudgetCubit>(
      () => _i203.BudgetCubit(
        gh<_i469.BudgetRepository>(),
        gh<_i616.TransactionRepository>(),
        gh<_i270.CategoryRepository>(),
        gh<_i97.SettingsRepository>(),
      ),
    );
    gh.factory<_i337.SummaryReminderController>(
      () => _i337.SummaryReminderController(
        gh<_i97.SettingsRepository>(),
        gh<_i839.SummaryNotifier>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i253.StorageModule {}
