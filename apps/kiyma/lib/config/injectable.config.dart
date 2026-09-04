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
import 'package:kiyma/config/storage_module.dart' as _i57;
import 'package:kiyma/game/kiyma_cubit.dart' as _i645;
import 'package:kiyma/game/progress.dart' as _i636;
import 'package:kiyma/game/world.dart' as _i139;
import 'package:kiyma/infrastructure/language_choice.dart' as _i82;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.preferences,
      preResolve: true,
    );
    gh.lazySingleton<_i636.Progress>(() => _i636.Progress());
    gh.lazySingleton<_i139.GameWorld>(() => _i139.GameWorld());
    gh.lazySingleton<_i82.LanguageChoice>(
      () => _i82.LanguageChoice(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i645.KiymaCubit>(
      () => _i645.KiymaCubit(gh<_i139.GameWorld>(), gh<_i636.Progress>()),
    );
    return this;
  }
}

class _$StorageModule extends _i57.StorageModule {}
