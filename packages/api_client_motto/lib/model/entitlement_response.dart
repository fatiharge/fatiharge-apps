//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EntitlementResponse {
  /// Returns a new [EntitlementResponse] instance.
  EntitlementResponse({
    this.remainingUses,
    this.cooldownUntil,
    this.skipsLeft,
    this.premium,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? remainingUses;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? cooldownUntil;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? skipsLeft;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? premium;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntitlementResponse &&
          other.remainingUses == remainingUses &&
          other.cooldownUntil == cooldownUntil &&
          other.skipsLeft == skipsLeft &&
          other.premium == premium;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (remainingUses == null ? 0 : remainingUses!.hashCode) +
      (cooldownUntil == null ? 0 : cooldownUntil!.hashCode) +
      (skipsLeft == null ? 0 : skipsLeft!.hashCode) +
      (premium == null ? 0 : premium!.hashCode);

  @override
  String toString() =>
      'EntitlementResponse[remainingUses=$remainingUses, cooldownUntil=$cooldownUntil, skipsLeft=$skipsLeft, premium=$premium]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.remainingUses != null) {
      json[r'remainingUses'] = this.remainingUses;
    } else {
      json[r'remainingUses'] = null;
    }
    if (this.cooldownUntil != null) {
      json[r'cooldownUntil'] = this.cooldownUntil!.toUtc().toIso8601String();
    } else {
      json[r'cooldownUntil'] = null;
    }
    if (this.skipsLeft != null) {
      json[r'skipsLeft'] = this.skipsLeft;
    } else {
      json[r'skipsLeft'] = null;
    }
    if (this.premium != null) {
      json[r'premium'] = this.premium;
    } else {
      json[r'premium'] = null;
    }
    return json;
  }

  /// Returns a new [EntitlementResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EntitlementResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return EntitlementResponse(
        remainingUses: mapValueOfType<int>(json, r'remainingUses'),
        cooldownUntil: mapDateTime(json, r'cooldownUntil', r''),
        skipsLeft: mapValueOfType<int>(json, r'skipsLeft'),
        premium: mapValueOfType<bool>(json, r'premium'),
      );
    }
    return null;
  }

  static List<EntitlementResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <EntitlementResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EntitlementResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EntitlementResponse> mapFromJson(dynamic json) {
    final map = <String, EntitlementResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EntitlementResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EntitlementResponse-objects as value to a dart map
  static Map<String, List<EntitlementResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<EntitlementResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EntitlementResponse.listFromJson(
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
