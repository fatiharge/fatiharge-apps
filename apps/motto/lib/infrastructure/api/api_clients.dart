import 'package:api_client_auth/api.dart' as auth;
import 'package:api_client_motto/api.dart' as motto;
import 'package:injectable/injectable.dart';
import 'package:motto/config/env.dart';
import 'package:motto/infrastructure/session/token_store.dart';

/// The generated clients, pointed at this build's servers and taught to carry
/// the token.
///
/// The bearer value is a function rather than a string: the token is replaced
/// whenever the device registers again, and a client holding a copy of the old
/// one would keep sending it until the app restarted.
@module
abstract class ApiClients {
  @lazySingleton
  auth.ApiClient authClient(TokenStore tokens) => auth.ApiClient(
    basePath: Env.authBaseUrl,
    authentication: auth.HttpBearerAuth()
      ..accessToken = (() => tokens.current ?? ''),
  );

  @lazySingleton
  motto.ApiClient mottoClient(TokenStore tokens) => motto.ApiClient(
    basePath: Env.mottoBaseUrl,
    authentication: motto.HttpBearerAuth()
      ..accessToken = (() => tokens.current ?? ''),
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
}
