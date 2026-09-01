//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SecondFactorRequest {
  /// Returns a new [SecondFactorRequest] instance.
  SecondFactorRequest({
    required this.pendingToken,
    required this.code,
  });

  String pendingToken;

  String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecondFactorRequest &&
          other.pendingToken == pendingToken &&
          other.code == code;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (pendingToken.hashCode) + (code.hashCode);

  @override
  String toString() =>
      'SecondFactorRequest[pendingToken=$pendingToken, code=$code]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'pendingToken'] = this.pendingToken;
    json[r'code'] = this.code;
    return json;
  }

  /// Returns a new [SecondFactorRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SecondFactorRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'pendingToken'),
            'Required key "SecondFactorRequest[pendingToken]" is missing from JSON.');
        assert(json[r'pendingToken'] != null,
            'Required key "SecondFactorRequest[pendingToken]" has a null value in JSON.');
        assert(json.containsKey(r'code'),
            'Required key "SecondFactorRequest[code]" is missing from JSON.');
        assert(json[r'code'] != null,
            'Required key "SecondFactorRequest[code]" has a null value in JSON.');
        return true;
      }());

      return SecondFactorRequest(
        pendingToken: mapValueOfType<String>(json, r'pendingToken')!,
        code: mapValueOfType<String>(json, r'code')!,
      );
    }
    return null;
  }

  static List<SecondFactorRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <SecondFactorRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SecondFactorRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SecondFactorRequest> mapFromJson(dynamic json) {
    final map = <String, SecondFactorRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SecondFactorRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SecondFactorRequest-objects as value to a dart map
  static Map<String, List<SecondFactorRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<SecondFactorRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SecondFactorRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'pendingToken',
    'code',
  };
}
