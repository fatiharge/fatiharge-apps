//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeviceResourceApi {
  DeviceResourceApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Token'ı taşıyanın kim olduğunu söyler
  ///
  /// İstemcinin, elindeki token'ın hâlâ geçerli olup olmadığını bir sonraki çağrının hatasından tahmin etmek yerine doğrudan sorabilmesi için.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> currentDeviceWithHttpInfo({
    Future<void>? abortTrigger,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/devices/me';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];

    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Token'ı taşıyanın kim olduğunu söyler
  ///
  /// İstemcinin, elindeki token'ın hâlâ geçerli olup olmadığını bir sonraki çağrının hatasından tahmin etmek yerine doğrudan sorabilmesi için.
  Future<CurrentDeviceResponse?> currentDevice({
    Future<void>? abortTrigger,
  }) async {
    final response = await currentDeviceWithHttpInfo(
      abortTrigger: abortTrigger,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'CurrentDeviceResponse',
      ) as CurrentDeviceResponse;
    }
    return null;
  }

  /// Cihazı kaydeder ve token verir
  ///
  /// İkinci kez kaydolmak hata değil olağan durumdur: uygulama token'ı dolduğunda yeniden kaydolur ve silinip kurulan bir uygulama aynı özetle gelir. İkisi de zaten sahip oldukları kimliği alır.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegisterDeviceRequest] registerDeviceRequest (required):
  Future<Response> registerDeviceWithHttpInfo(
    RegisterDeviceRequest registerDeviceRequest, {
    Future<void>? abortTrigger,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/devices/register';

    // ignore: prefer_final_locals
    Object? postBody = registerDeviceRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Cihazı kaydeder ve token verir
  ///
  /// İkinci kez kaydolmak hata değil olağan durumdur: uygulama token'ı dolduğunda yeniden kaydolur ve silinip kurulan bir uygulama aynı özetle gelir. İkisi de zaten sahip oldukları kimliği alır.
  ///
  /// Parameters:
  ///
  /// * [RegisterDeviceRequest] registerDeviceRequest (required):
  Future<DeviceTokenResponse?> registerDevice(
    RegisterDeviceRequest registerDeviceRequest, {
    Future<void>? abortTrigger,
  }) async {
    final response = await registerDeviceWithHttpInfo(
      registerDeviceRequest,
      abortTrigger: abortTrigger,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'DeviceTokenResponse',
      ) as DeviceTokenResponse;
    }
    return null;
  }
}
