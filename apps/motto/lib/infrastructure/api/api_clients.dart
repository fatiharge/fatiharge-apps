import 'package:api_client_auth/api.dart' as auth;
import 'package:api_client_motto/api.dart' as motto;
import 'package:injectable/injectable.dart';
import 'package:motto/config/env.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/infrastructure/api/renewing_client.dart';
import 'package:motto/infrastructure/effects/effect_catalogue.dart';
import 'package:motto/infrastructure/effects/effect_host.dart';
import 'package:motto/infrastructure/effects/effect_repository.dart';
import 'package:motto/infrastructure/effects/motto_effect_host.dart';
import 'package:motto/infrastructure/session/device_session.dart';
import 'package:motto/infrastructure/session/token_store.dart';

/// The generated clients, pointed at this build's servers and taught to carry
/// the token.
///
/// The bearer value is a function rather than a string: the token is replaced
/// whenever the device registers again, and a client holding a copy of the old
/// one would keep sending it until the app restarted.
@module
abstract class ApiClients {
  /// No bearer on this one. Registration is the call that exists to replace a
  /// dead token, and it is the only thing this client is used for — carrying
  /// the dead token to it is how a device with an expired token gets refused
  /// the one request that would fix it.
  @lazySingleton
  auth.ApiClient authClient() => auth.ApiClient(basePath: Env.authBaseUrl);

  @lazySingleton
  motto.ApiClient mottoClient(TokenStore tokens) => RenewingApiClient(
    basePath: Env.mottoBaseUrl,
    authentication: motto.HttpBearerAuth()
      ..accessToken = (() => tokens.current ?? ''),
    // Resolved when it is needed rather than now: the session is built from
    // the auth client, and asking for it here would be a circle.
    renew: () => getIt<DeviceSession>().register(),
  );

  @lazySingleton
  auth.DeviceResourceApi devices(auth.ApiClient client) =>
      auth.DeviceResourceApi(client);

  @lazySingleton
  motto.TestResourceApi tests(motto.ApiClient client) =>
      motto.TestResourceApi(client);

  @lazySingleton
  motto.MottoResourceApi mottos(motto.ApiClient client) =>
      motto.MottoResourceApi(client);

  @lazySingleton
  motto.EntitlementResourceApi entitlements(motto.ApiClient client) =>
      motto.EntitlementResourceApi(client);

  @lazySingleton
  motto.EventResourceApi events(motto.ApiClient client) =>
      motto.EventResourceApi(client);

  @lazySingleton
  motto.FeedbackResourceApi feedback(motto.ApiClient client) =>
      motto.FeedbackResourceApi(client);

  @lazySingleton
  motto.ContentResourceApi content(motto.ApiClient client) =>
      motto.ContentResourceApi(client);

  @lazySingleton
  motto.ChainResourceApi chains(motto.ApiClient client) =>
      motto.ChainResourceApi(client);

  @lazySingleton
  motto.ResultResourceApi results(motto.ApiClient client) =>
      motto.ResultResourceApi(client);

  @lazySingleton
  motto.TaskResourceApi tasks(motto.ApiClient client) =>
      motto.TaskResourceApi(client);

  @lazySingleton
  motto.ReportResourceApi reports(motto.ApiClient client) =>
      motto.ReportResourceApi(client);

  @lazySingleton
  motto.ScoreResourceApi scores(motto.ApiClient client) =>
      motto.ScoreResourceApi(client);

  @lazySingleton
  motto.PlayResourceApi turns(motto.ApiClient client) =>
      motto.PlayResourceApi(client);

  @lazySingleton
  motto.EffectResourceApi effects(motto.ApiClient client) =>
      motto.EffectResourceApi(client);

  /// What this app is willing to be asked for. Named here rather than inside
  /// the engine: the engine is the same everywhere, the permits never are.
  @lazySingleton
  EffectPermits permits() => MottoEffectHost.permits;

  /// The engine reads definitions through the interface; the bootstrap asks
  /// the same object to go and get them.
  @lazySingleton
  EffectCatalogue catalogue(EffectRepository definitions) => definitions;

  @lazySingleton
  motto.SupportResourceApi support(motto.ApiClient client) =>
      motto.SupportResourceApi(client);
}
