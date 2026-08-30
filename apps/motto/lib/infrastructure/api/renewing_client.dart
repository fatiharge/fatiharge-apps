import 'dart:async';

import 'package:api_client_motto/api.dart' as motto;
import 'package:http/http.dart' show Response;

/// Registers again on a 401 and retries once, and says which language it reads.
///
/// `DeviceSession` handles the ordinary expiry. The renewal here handles the
/// rest — a clock that disagrees, a rotated signing key, a deleted device —
/// none of which the app can predict.
///
/// The language goes on here rather than on each call. It is a property of the
/// app and not of any one request; declared per endpoint it would be an
/// argument at three hundred call sites, and the one somebody forgot would be
/// a screen in the wrong language nobody could explain.
class RenewingApiClient extends motto.ApiClient {
  RenewingApiClient({
    required super.basePath,
    required motto.Authentication super.authentication,
    required this.renew,
    required this.language,
  });

  /// Registers the device again. Called at most once per failed request.
  final Future<void> Function() renew;

  /// Read per request rather than captured: the language changes while the app
  /// runs, and a client holding the old one would keep asking for it.
  final String Function() language;

  /// Shared, so ten screens failing at once cause one registration.
  Future<void>? _renewing;

  @override
  Future<Response> invokeAPI(
    String path,
    String method,
    List<motto.QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType, {
    Future<void>? abortTrigger,
  }) async {
    headerParams['Accept-Language'] = language();

    final response = await super.invokeAPI(
      path,
      method,
      queryParams,
      body,
      headerParams,
      formParams,
      contentType,
      abortTrigger: abortTrigger,
    );
    if (response.statusCode != 401) return response;

    try {
      await (_renewing ??= renew().whenComplete(() => _renewing = null));
    } on Object {
      return response;
    }

    // The header carries the old token; the bearer is read again on the way
    // through, so it has to go.
    headerParams.remove('Authorization');
    return super.invokeAPI(
      path,
      method,
      queryParams,
      body,
      headerParams,
      formParams,
      contentType,
      abortTrigger: abortTrigger,
    );
  }
}
