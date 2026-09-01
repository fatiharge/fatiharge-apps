//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RequestCodeRequest {
  /// Returns a new [RequestCodeRequest] instance.
  RequestCodeRequest({
    required this.identityType,
    required this.identity,
  });

  IdentityType identityType;

  String identity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestCodeRequest &&
          other.identityType == identityType &&
          other.identity == identity;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (identityType.hashCode) + (identity.hashCode);

  @override
  String toString() =>
      'RequestCodeRequest[identityType=$identityType, identity=$identity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'identityType'] = this.identityType;
    json[r'identity'] = this.identity;
    return json;
  }

  /// Returns a new [RequestCodeRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RequestCodeRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'identityType'),
            'Required key "RequestCodeRequest[identityType]" is missing from JSON.');
        assert(json[r'identityType'] != null,
            'Required key "RequestCodeRequest[identityType]" has a null value in JSON.');
        assert(json.containsKey(r'identity'),
            'Required key "RequestCodeRequest[identity]" is missing from JSON.');
        assert(json[r'identity'] != null,
            'Required key "RequestCodeRequest[identity]" has a null value in JSON.');
        return true;
      }());

      return RequestCodeRequest(
        identityType: IdentityType.fromJson(json[r'identityType'])!,
        identity: mapValueOfType<String>(json, r'identity')!,
      );
    }
    return null;
  }

  static List<RequestCodeRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <RequestCodeRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RequestCodeRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RequestCodeRequest> mapFromJson(dynamic json) {
    final map = <String, RequestCodeRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RequestCodeRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RequestCodeRequest-objects as value to a dart map
  static Map<String, List<RequestCodeRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<RequestCodeRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RequestCodeRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'identityType',
    'identity',
  };
}
