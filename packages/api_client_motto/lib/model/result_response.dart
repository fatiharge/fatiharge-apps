//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ResultResponse {
  /// Returns a new [ResultResponse] instance.
  ResultResponse({
    this.archetype,
    this.entitlement,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ArchetypeResponse? archetype;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  EntitlementResponse? entitlement;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultResponse &&
          other.archetype == archetype &&
          other.entitlement == entitlement;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (archetype == null ? 0 : archetype!.hashCode) +
      (entitlement == null ? 0 : entitlement!.hashCode);

  @override
  String toString() =>
      'ResultResponse[archetype=$archetype, entitlement=$entitlement]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.archetype != null) {
      json[r'archetype'] = this.archetype;
    } else {
      json[r'archetype'] = null;
    }
    if (this.entitlement != null) {
      json[r'entitlement'] = this.entitlement;
    } else {
      json[r'entitlement'] = null;
    }
    return json;
  }

  /// Returns a new [ResultResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ResultResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return ResultResponse(
        archetype: ArchetypeResponse.fromJson(json[r'archetype']),
        entitlement: EntitlementResponse.fromJson(json[r'entitlement']),
      );
    }
    return null;
  }

  static List<ResultResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ResultResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ResultResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ResultResponse> mapFromJson(dynamic json) {
    final map = <String, ResultResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ResultResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ResultResponse-objects as value to a dart map
  static Map<String, List<ResultResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ResultResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ResultResponse.listFromJson(
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
