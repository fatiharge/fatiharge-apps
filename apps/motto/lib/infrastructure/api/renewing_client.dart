import 'dart:async';

import 'package:api_client_motto/api.dart' as motto;
import 'package:http/http.dart' show Response;

/// An API client that registers again when the server says it does not know
/// this device, and retries once.
///
/// The expiry check in `DeviceSession` handles the ordinary case. This handles
/// every other way a token stops working — a clock that disagrees, a signing
/// key rotated on the server, a device deleted — none of which the app can
/// predict and all of which used to end with every screen failing for ever.
class RenewingApiClient extends motto.ApiClient {
  RenewingApiClient({
    required super.basePath,
    required motto.Authentication super.authentication,
    required this.renew,
  });

  /// Registers the device again. Called at most once per failed request.
  final Future<void> Function() renew;

  /// Shared, so ten screens failing at once cause one registration and not
  /// ten. Whoever arrives while it is in flight waits for the same answer.
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
