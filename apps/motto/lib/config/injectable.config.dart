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
import 'package:motto/features/chain/application/chain_cubit.dart' as _i41;
import 'package:motto/features/chain/application/chain_repository.dart'
    as _i761;
import 'package:motto/features/chain/application/chain_store.dart' as _i625;
import 'package:motto/features/chain/application/reminder_scheduler.dart'
    as _i632;
import 'package:motto/features/content/application/content_repository.dart'
    as _i876;
import 'package:motto/features/content/application/content_store.dart' as _i432;
import 'package:motto/features/daily/application/daily_cubit.dart' as _i1068;
import 'package:motto/features/daily/application/daily_widget.dart' as _i113;
import 'package:motto/features/game/application/game_store.dart' as _i164;
import 'package:motto/features/mascot/application/mascot_store.dart' as _i756;
import 'package:motto/features/onboarding/application/onboarding_store.dart'
    as _i624;
import 'package:motto/features/profile/application/profile_cubit.dart' as _i315;
import 'package:motto/features/result/application/card_exporter.dart' as _i111;
import 'package:motto/features/support/application/data_deletion.dart' as _i729;
import 'package:motto/features/support/application/feedback_cubit.dart'
    as _i875;
import 'package:motto/features/support/application/last_archetype.dart'
    as _i1019;
import 'package:motto/features/support/application/support_context.dart'
    as _i922;
import 'package:motto/features/support/application/support_copy_cubit.dart'
    as _i708;
import 'package:motto/features/tasks/application/task_cubit.dart' as _i249;
import 'package:motto/features/test/application/test_cubit.dart' as _i89;
import 'package:motto/features/test/application/test_draft.dart' as _i547;
import 'package:motto/infrastructure/analytics/analytics.dart' as _i190;
import 'package:motto/infrastructure/analytics/event_queue.dart' as _i98;
import 'package:motto/infrastructure/api/api_clients.dart' as _i366;
import 'package:motto/infrastructure/identity/device_identity.dart' as _i37;
import 'package:motto/infrastructure/identity/device_identity_impl.dart'
    as _i917;
import 'package:motto/infrastructure/notifications/local_reminder_scheduler.dart'
    as _i573;
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
    gh.lazySingleton<_i113.DailyWidget>(() => const _i113.DailyWidget());
    gh.lazySingleton<_i111.CardExporter>(() => const _i111.CardExporter());
    gh.lazySingleton<_i759.TokenStore>(
      () => _i759.TokenStore(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i625.ChainStore>(
      () => _i625.ChainStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i432.ContentStore>(
      () => _i432.ContentStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i164.GameStore>(
      () => _i164.GameStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i756.MascotStore>(
      () => _i756.MascotStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i624.OnboardingStore>(
      () => _i624.OnboardingStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i1019.LastArchetype>(
      () => _i1019.LastArchetype(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i547.TestDraft>(
      () => _i547.TestDraft(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i98.EventQueue>(
      () => _i98.EventQueue(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i632.ReminderScheduler>(
      () => _i573.LocalReminderScheduler(),
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
    gh.lazySingleton<_i66.EventResourceApi>(
      () => apiClients.events(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.FeedbackResourceApi>(
      () => apiClients.feedback(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.ContentResourceApi>(
      () => apiClients.content(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.ChainResourceApi>(
      () => apiClients.chains(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.ResultResourceApi>(
      () => apiClients.results(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.TaskResourceApi>(
      () => apiClients.tasks(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.ReportResourceApi>(
      () => apiClients.reports(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.ScoreResourceApi>(
      () => apiClients.scores(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i66.SupportResourceApi>(
      () => apiClients.support(gh<_i66.ApiClient>()),
    );
    gh.lazySingleton<_i503.DeviceSession>(
      () => _i503.DeviceSession(
        gh<_i37.DeviceIdentity>(),
        gh<_i818.DeviceResourceApi>(),
        gh<_i759.TokenStore>(),
      ),
    );
    gh.factory<_i315.ProfileCubit>(
      () => _i315.ProfileCubit(
        gh<_i66.ResultResourceApi>(),
        gh<_i66.EntitlementResourceApi>(),
      ),
    );
    gh.factory<_i708.SupportCopyCubit>(
      () => _i708.SupportCopyCubit(gh<_i66.SupportResourceApi>()),
    );
    gh.lazySingleton<_i761.ChainRepository>(
      () => _i761.ChainRepository(
        gh<_i66.ChainResourceApi>(),
        gh<_i625.ChainStore>(),
      ),
    );
    gh.lazySingleton<_i190.Analytics>(
      () => _i190.Analytics(gh<_i98.EventQueue>(), gh<_i66.EventResourceApi>()),
    );
    gh.lazySingleton<_i922.SupportContext>(
      () => _i922.SupportContext(
        gh<_i37.DeviceIdentity>(),
        gh<_i1019.LastArchetype>(),
      ),
    );
    gh.factory<_i89.TestCubit>(
      () => _i89.TestCubit(
        gh<_i66.TestResourceApi>(),
        gh<_i66.MottoResourceApi>(),
        gh<_i547.TestDraft>(),
        gh<_i190.Analytics>(),
        gh<_i1019.LastArchetype>(),
      ),
    );
    gh.factory<_i249.TaskCubit>(
      () => _i249.TaskCubit(gh<_i66.TaskResourceApi>()),
    );
    gh.factory<_i41.ChainCubit>(
      () => _i41.ChainCubit(
        gh<_i761.ChainRepository>(),
        gh<_i625.ChainStore>(),
        gh<_i632.ReminderScheduler>(),
        gh<_i190.Analytics>(),
      ),
    );
    gh.lazySingleton<_i876.ContentRepository>(
      () => _i876.ContentRepository(
        gh<_i66.ContentResourceApi>(),
        gh<_i432.ContentStore>(),
      ),
    );
    gh.lazySingleton<_i729.DataDeletion>(
      () => _i729.DataDeletion(
        gh<_i66.EntitlementResourceApi>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i875.FeedbackCubit>(
      () => _i875.FeedbackCubit(
        gh<_i66.FeedbackResourceApi>(),
        gh<_i922.SupportContext>(),
        gh<_i190.Analytics>(),
      ),
    );
    gh.factory<_i1068.DailyCubit>(
      () => _i1068.DailyCubit(
        gh<_i876.ContentRepository>(),
        gh<_i1019.LastArchetype>(),
        gh<_i761.ChainRepository>(),
        gh<_i190.Analytics>(),
        gh<_i113.DailyWidget>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i909.StorageModule {}

class _$ApiClients extends _i366.ApiClients {}
