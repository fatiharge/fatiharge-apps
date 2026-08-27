// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:android_id/android_id.dart' as _i76;
import 'package:api_client_auth/api.dart' as _i818;
import 'package:api_client_motto/api.dart' as _i66;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:motto/config/storage_module.dart' as _i909;
import 'package:motto/features/result/application/card_exporter.dart' as _i111;
import 'package:motto/features/test/application/test_cubit.dart' as _i89;
import 'package:motto/features/test/application/test_draft.dart' as _i547;
import 'package:motto/infrastructure/api/api_clients.dart' as _i366;
import 'package:motto/infrastructure/identity/device_identity.dart' as _i37;
import 'package:motto/infrastructure/identity/device_identity_impl.dart'
    as _i917;
import 'package:motto/infrastructure/session/device_session.dart' as _i503;
import 'package:motto/infrastructure/session/token_store.dart' as _i759;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final apiClients = _$ApiClients();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.preferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i76.AndroidId>(() => storageModule.androidId);
    gh.lazySingleton<_i111.CardExporter>(() => const _i111.CardExporter());
    gh.lazySingleton<_i759.TokenStore>(
      () => _i759.TokenStore(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i547.TestDraft>(
      () => _i547.TestDraft(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i37.DeviceIdentity>(
      () => _i917.DeviceIdentityImpl(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i76.AndroidId>(),
      ),
    );
    gh.lazySingleton<_i818.ApiClient>(
      () => apiClients.authClient(gh<_i759.TokenStore>()),
    );
    gh.lazySingleton<_i66.ApiClient>(
      () => apiClients.mottoClient(gh<_i759.TokenStore>()),
    );
    gh.lazySingleton<_i818.DeviceResourceApi>(
      () => apiClients.devices(gh<_i818.ApiClient>()),
    );
    gh.lazySingleton<_i66.TestResourceApi>(
      () => apiClients.tests(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.MottoResourceApi>(
      () => apiClients.mottos(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.EntitlementResourceApi>(
      () => apiClients.entitlements(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i503.DeviceSession>(
      () => _i503.DeviceSession(
        gh<_i37.DeviceIdentity>(),
        gh<_i818.DeviceResourceApi>(),
        gh<_i759.TokenStore>(),
      ),
    );
    gh.factory<_i89.TestCubit>(
      () => _i89.TestCubit(
        gh<_i66.TestResourceApi>(),
        gh<_i66.MottoResourceApi>(),
        gh<_i547.TestDraft>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i909.StorageModule {}

class _$ApiClients extends _i366.ApiClients {}
