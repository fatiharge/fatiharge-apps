//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SessionResourceApi {
  SessionResourceApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Panel girişini kodla tamamlar
  ///
  /// Hangi doğrulamanın tamamlandığını geçici token söyler, çağıran değil. Böylece bir hesap için gönderilen kod başka bir hesabın girişini bitiremez.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [SecondFactorRequest] secondFactorRequest (required):
  Future<Response> completeSecondFactorWithHttpInfo(
    SecondFactorRequest secondFactorRequest, {
    Future<void>? abortTrigger,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/sessions/second-factor';

    // ignore: prefer_final_locals
    Object? postBody = secondFactorRequest;

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

  /// Panel girişini kodla tamamlar
  ///
  /// Hangi doğrulamanın tamamlandığını geçici token söyler, çağıran değil. Böylece bir hesap için gönderilen kod başka bir hesabın girişini bitiremez.
  ///
  /// Parameters:
  ///
  /// * [SecondFactorRequest] secondFactorRequest (required):
  Future<SessionResponse?> completeSecondFactor(
    SecondFactorRequest secondFactorRequest, {
    Future<void>? abortTrigger,
  }) async {
    final response = await completeSecondFactorWithHttpInfo(
      secondFactorRequest,
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
        'SessionResponse',
      ) as SessionResponse;
    }
    return null;
  }

  /// Yenileme token'ını yeni bir oturumla değiştirir
  ///
  /// Rol ve durum her seferinde veritabanından okunur, sunulan token'dan taşınmaz — yetkisi alınan birinin elindeki token yetkiyi sürdüremesin diye. Kişinin satırındaki sayaç arttıysa daha eski her token reddedilir; \"tüm cihazlardan çık\" budur.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RefreshRequest] refreshRequest (required):
  Future<Response> refreshSessionWithHttpInfo(
    RefreshRequest refreshRequest, {
    Future<void>? abortTrigger,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/sessions/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshRequest;

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

  /// Yenileme token'ını yeni bir oturumla değiştirir
  ///
  /// Rol ve durum her seferinde veritabanından okunur, sunulan token'dan taşınmaz — yetkisi alınan birinin elindeki token yetkiyi sürdüremesin diye. Kişinin satırındaki sayaç arttıysa daha eski her token reddedilir; \"tüm cihazlardan çık\" budur.
  ///
  /// Parameters:
  ///
  /// * [RefreshRequest] refreshRequest (required):
  Future<SessionResponse?> refreshSession(
    RefreshRequest refreshRequest, {
    Future<void>? abortTrigger,
  }) async {
    final response = await refreshSessionWithHttpInfo(
      refreshRequest,
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
        'SessionResponse',
      ) as SessionResponse;
    }
    return null;
  }

  /// Bir kimliğe tek kullanımlık kod gönderir
  ///
  /// Kodun kendisi cevapta dönmez — yalnızca kodun var olduğu ve ne kadar yaşayacağı döner. Kod şu an bir mesaj kuyruğu tablosuna yazılır, henüz onu taşıyan bir kanal yoktur. Aynı kimliğe saatlik ve günlük istek sınırı uygulanır; sınır kulüp başına sayılır, yani bir kulübün trafiği diğerinin taraftarını kilitleyemez. Telefon şemada vardır ama SMS sağlayıcısı olmadığı için reddedilir.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xClubId (required):
  ///
  /// * [RequestCodeRequest] requestCodeRequest (required):
  Future<Response> requestCodeWithHttpInfo(
    String xClubId,
    RequestCodeRequest requestCodeRequest, {
    Future<void>? abortTrigger,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/codes';

    // ignore: prefer_final_locals
    Object? postBody = requestCodeRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'X-Club-Id'] = parameterToString(xClubId);

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

  /// Bir kimliğe tek kullanımlık kod gönderir
  ///
  /// Kodun kendisi cevapta dönmez — yalnızca kodun var olduğu ve ne kadar yaşayacağı döner. Kod şu an bir mesaj kuyruğu tablosuna yazılır, henüz onu taşıyan bir kanal yoktur. Aynı kimliğe saatlik ve günlük istek sınırı uygulanır; sınır kulüp başına sayılır, yani bir kulübün trafiği diğerinin taraftarını kilitleyemez. Telefon şemada vardır ama SMS sağlayıcısı olmadığı için reddedilir.
  ///
  /// Parameters:
  ///
  /// * [String] xClubId (required):
  ///
  /// * [RequestCodeRequest] requestCodeRequest (required):
  Future<ChallengeResponse?> requestCode(
    String xClubId,
    RequestCodeRequest requestCodeRequest, {
    Future<void>? abortTrigger,
  }) async {
    final response = await requestCodeWithHttpInfo(
      xClubId,
      requestCodeRequest,
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
        'ChallengeResponse',
      ) as ChallengeResponse;
    }
    return null;
  }

  /// Tek kullanımlık kodu oturuma çevirir
  ///
  /// Hesap yoksa ilk girişte oluşturulur. Kulüp, isteğin gövdesinden değil kodun ait olduğu doğrulamadan okunur: bir kulüp için alınan kod başka bir kulübe giriş yapamaz. Panele erişen hesaplar bu yolu kullanamaz, parolayla girmek zorundadır.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CodeSignInRequest] codeSignInRequest (required):
  Future<Response> signInWithCodeWithHttpInfo(
    CodeSignInRequest codeSignInRequest, {
    Future<void>? abortTrigger,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/sessions/by-code';

    // ignore: prefer_final_locals
    Object? postBody = codeSignInRequest;

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

  /// Tek kullanımlık kodu oturuma çevirir
  ///
  /// Hesap yoksa ilk girişte oluşturulur. Kulüp, isteğin gövdesinden değil kodun ait olduğu doğrulamadan okunur: bir kulüp için alınan kod başka bir kulübe giriş yapamaz. Panele erişen hesaplar bu yolu kullanamaz, parolayla girmek zorundadır.
  ///
  /// Parameters:
  ///
  /// * [CodeSignInRequest] codeSignInRequest (required):
  Future<SessionResponse?> signInWithCode(
    CodeSignInRequest codeSignInRequest, {
    Future<void>? abortTrigger,
  }) async {
    final response = await signInWithCodeWithHttpInfo(
      codeSignInRequest,
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
        'SessionResponse',
      ) as SessionResponse;
    }
    return null;
  }

  /// Parolayla giriş yapar
  ///
  /// Taraftar için oturumu doğrudan açar. Panele erişen bir hesap için ikinci adım gerekir: cevap `SECOND_FACTOR_REQUIRED` döner, bir kod gönderilir ve parola adımının geçildiğini kanıtlayan geçici bir token verilir. Parola yanlışsa hiçbir kod gönderilmez.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xClubId (required):
  ///
  /// * [PasswordSignInRequest] passwordSignInRequest (required):
  Future<Response> signInWithPasswordWithHttpInfo(
    String xClubId,
    PasswordSignInRequest passwordSignInRequest, {
    Future<void>? abortTrigger,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/sessions/by-password';

    // ignore: prefer_final_locals
    Object? postBody = passwordSignInRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'X-Club-Id'] = parameterToString(xClubId);

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

  /// Parolayla giriş yapar
  ///
  /// Taraftar için oturumu doğrudan açar. Panele erişen bir hesap için ikinci adım gerekir: cevap `SECOND_FACTOR_REQUIRED` döner, bir kod gönderilir ve parola adımının geçildiğini kanıtlayan geçici bir token verilir. Parola yanlışsa hiçbir kod gönderilmez.
  ///
  /// Parameters:
  ///
  /// * [String] xClubId (required):
  ///
  /// * [PasswordSignInRequest] passwordSignInRequest (required):
  Future<PasswordSignInResponse?> signInWithPassword(
    String xClubId,
    PasswordSignInRequest passwordSignInRequest, {
    Future<void>? abortTrigger,
  }) async {
    final response = await signInWithPasswordWithHttpInfo(
      xClubId,
      passwordSignInRequest,
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
        'PasswordSignInResponse',
      ) as PasswordSignInResponse;
    }
    return null;
  }
}
