//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeviceTokenResponse {
  /// Returns a new [DeviceTokenResponse] instance.
  DeviceTokenResponse({
    this.deviceId,
    this.token,
    this.expiresInSeconds,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? deviceId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? token;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? expiresInSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceTokenResponse &&
          other.deviceId == deviceId &&
          other.token == token &&
          other.expiresInSeconds == expiresInSeconds;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (deviceId == null ? 0 : deviceId!.hashCode) +
      (token == null ? 0 : token!.hashCode) +
      (expiresInSeconds == null ? 0 : expiresInSeconds!.hashCode);

  @override
  String toString() =>
      'DeviceTokenResponse[deviceId=$deviceId, token=$token, expiresInSeconds=$expiresInSeconds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.deviceId != null) {
      json[r'deviceId'] = this.deviceId;
    } else {
      json[r'deviceId'] = null;
    }
    if (this.token != null) {
      json[r'token'] = this.token;
    } else {
      json[r'token'] = null;
    }
    if (this.expiresInSeconds != null) {
      json[r'expiresInSeconds'] = this.expiresInSeconds;
    } else {
      json[r'expiresInSeconds'] = null;
    }
    return json;
  }

  /// Returns a new [DeviceTokenResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeviceTokenResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return DeviceTokenResponse(
        deviceId: mapValueOfType<String>(json, r'deviceId'),
        token: mapValueOfType<String>(json, r'token'),
        expiresInSeconds: mapValueOfType<int>(json, r'expiresInSeconds'),
      );
    }
    return null;
  }

  static List<DeviceTokenResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DeviceTokenResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeviceTokenResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeviceTokenResponse> mapFromJson(dynamic json) {
    final map = <String, DeviceTokenResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeviceTokenResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeviceTokenResponse-objects as value to a dart map
  static Map<String, List<DeviceTokenResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DeviceTokenResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeviceTokenResponse.listFromJson(
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
