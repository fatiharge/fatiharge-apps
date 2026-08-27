//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegisterDeviceRequest {
  /// Returns a new [RegisterDeviceRequest] instance.
  RegisterDeviceRequest({
    required this.deviceHash,
    required this.platform,
  });

  String deviceHash;

  String platform;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterDeviceRequest &&
          other.deviceHash == deviceHash &&
          other.platform == platform;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (deviceHash.hashCode) + (platform.hashCode);

  @override
  String toString() =>
      'RegisterDeviceRequest[deviceHash=$deviceHash, platform=$platform]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'deviceHash'] = this.deviceHash;
    json[r'platform'] = this.platform;
    return json;
  }

  /// Returns a new [RegisterDeviceRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterDeviceRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deviceHash'),
            'Required key "RegisterDeviceRequest[deviceHash]" is missing from JSON.');
        assert(json[r'deviceHash'] != null,
            'Required key "RegisterDeviceRequest[deviceHash]" has a null value in JSON.');
        assert(json.containsKey(r'platform'),
            'Required key "RegisterDeviceRequest[platform]" is missing from JSON.');
        assert(json[r'platform'] != null,
            'Required key "RegisterDeviceRequest[platform]" has a null value in JSON.');
        return true;
      }());

      return RegisterDeviceRequest(
        deviceHash: mapValueOfType<String>(json, r'deviceHash')!,
        platform: mapValueOfType<String>(json, r'platform')!,
      );
    }
    return null;
  }

  static List<RegisterDeviceRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <RegisterDeviceRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterDeviceRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterDeviceRequest> mapFromJson(dynamic json) {
    final map = <String, RegisterDeviceRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterDeviceRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterDeviceRequest-objects as value to a dart map
  static Map<String, List<RegisterDeviceRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<RegisterDeviceRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterDeviceRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceHash',
    'platform',
  };
}
