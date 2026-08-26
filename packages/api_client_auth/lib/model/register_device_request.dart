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
    this.deviceHash,
    this.platform,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? deviceHash;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? platform;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterDeviceRequest &&
          other.deviceHash == deviceHash &&
          other.platform == platform;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (deviceHash == null ? 0 : deviceHash!.hashCode) +
      (platform == null ? 0 : platform!.hashCode);

  @override
  String toString() =>
      'RegisterDeviceRequest[deviceHash=$deviceHash, platform=$platform]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.deviceHash != null) {
      json[r'deviceHash'] = this.deviceHash;
    } else {
      json[r'deviceHash'] = null;
    }
    if (this.platform != null) {
      json[r'platform'] = this.platform;
    } else {
      json[r'platform'] = null;
    }
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
        return true;
      }());

      return RegisterDeviceRequest(
        deviceHash: mapValueOfType<String>(json, r'deviceHash'),
        platform: mapValueOfType<String>(json, r'platform'),
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
  static const requiredKeys = <String>{};
}
