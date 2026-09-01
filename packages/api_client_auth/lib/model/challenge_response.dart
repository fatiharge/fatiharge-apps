//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChallengeResponse {
  /// Returns a new [ChallengeResponse] instance.
  ChallengeResponse({
    required this.challengeId,
    required this.expiresInSeconds,
  });

  String challengeId;

  int expiresInSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeResponse &&
          other.challengeId == challengeId &&
          other.expiresInSeconds == expiresInSeconds;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (challengeId.hashCode) + (expiresInSeconds.hashCode);

  @override
  String toString() =>
      'ChallengeResponse[challengeId=$challengeId, expiresInSeconds=$expiresInSeconds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'challengeId'] = this.challengeId;
    json[r'expiresInSeconds'] = this.expiresInSeconds;
    return json;
  }

  /// Returns a new [ChallengeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChallengeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'challengeId'),
            'Required key "ChallengeResponse[challengeId]" is missing from JSON.');
        assert(json[r'challengeId'] != null,
            'Required key "ChallengeResponse[challengeId]" has a null value in JSON.');
        assert(json.containsKey(r'expiresInSeconds'),
            'Required key "ChallengeResponse[expiresInSeconds]" is missing from JSON.');
        assert(json[r'expiresInSeconds'] != null,
            'Required key "ChallengeResponse[expiresInSeconds]" has a null value in JSON.');
        return true;
      }());

      return ChallengeResponse(
        challengeId: mapValueOfType<String>(json, r'challengeId')!,
        expiresInSeconds: mapValueOfType<int>(json, r'expiresInSeconds')!,
      );
    }
    return null;
  }

  static List<ChallengeResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ChallengeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChallengeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChallengeResponse> mapFromJson(dynamic json) {
    final map = <String, ChallengeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChallengeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChallengeResponse-objects as value to a dart map
  static Map<String, List<ChallengeResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ChallengeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChallengeResponse.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'challengeId',
    'expiresInSeconds',
  };
}
