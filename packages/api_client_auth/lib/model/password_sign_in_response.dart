//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PasswordSignInResponse {
  /// Returns a new [PasswordSignInResponse] instance.
  PasswordSignInResponse({
    required this.status,
    this.session,
    this.pendingToken,
    this.challengeId,
    this.codeExpiresInSeconds,
  });

  String status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  SessionResponse? session;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? pendingToken;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? challengeId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? codeExpiresInSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordSignInResponse &&
          other.status == status &&
          other.session == session &&
          other.pendingToken == pendingToken &&
          other.challengeId == challengeId &&
          other.codeExpiresInSeconds == codeExpiresInSeconds;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (status.hashCode) +
      (session == null ? 0 : session!.hashCode) +
      (pendingToken == null ? 0 : pendingToken!.hashCode) +
      (challengeId == null ? 0 : challengeId!.hashCode) +
      (codeExpiresInSeconds == null ? 0 : codeExpiresInSeconds!.hashCode);

  @override
  String toString() =>
      'PasswordSignInResponse[status=$status, session=$session, pendingToken=$pendingToken, challengeId=$challengeId, codeExpiresInSeconds=$codeExpiresInSeconds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'status'] = this.status;
    if (this.session != null) {
      json[r'session'] = this.session;
    } else {
      json[r'session'] = null;
    }
    if (this.pendingToken != null) {
      json[r'pendingToken'] = this.pendingToken;
    } else {
      json[r'pendingToken'] = null;
    }
    if (this.challengeId != null) {
      json[r'challengeId'] = this.challengeId;
    } else {
      json[r'challengeId'] = null;
    }
    if (this.codeExpiresInSeconds != null) {
      json[r'codeExpiresInSeconds'] = this.codeExpiresInSeconds;
    } else {
      json[r'codeExpiresInSeconds'] = null;
    }
    return json;
  }

  /// Returns a new [PasswordSignInResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PasswordSignInResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'status'),
            'Required key "PasswordSignInResponse[status]" is missing from JSON.');
        assert(json[r'status'] != null,
            'Required key "PasswordSignInResponse[status]" has a null value in JSON.');
        return true;
      }());

      return PasswordSignInResponse(
        status: mapValueOfType<String>(json, r'status')!,
        session: SessionResponse.fromJson(json[r'session']),
        pendingToken: mapValueOfType<String>(json, r'pendingToken'),
        challengeId: mapValueOfType<String>(json, r'challengeId'),
        codeExpiresInSeconds:
            mapValueOfType<int>(json, r'codeExpiresInSeconds'),
      );
    }
    return null;
  }

  static List<PasswordSignInResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PasswordSignInResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PasswordSignInResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PasswordSignInResponse> mapFromJson(dynamic json) {
    final map = <String, PasswordSignInResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PasswordSignInResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PasswordSignInResponse-objects as value to a dart map
  static Map<String, List<PasswordSignInResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PasswordSignInResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PasswordSignInResponse.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
  };
}
