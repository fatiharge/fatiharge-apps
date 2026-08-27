//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ArchetypeResponse {
  /// Returns a new [ArchetypeResponse] instance.
  ArchetypeResponse({
    required this.id,
    required this.name,
    required this.summary,
    required this.motto,
    required this.confident,
  });

  String id;

  String name;

  String summary;

  String motto;

  bool confident;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchetypeResponse &&
          other.id == id &&
          other.name == name &&
          other.summary == summary &&
          other.motto == motto &&
          other.confident == confident;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id.hashCode) +
      (name.hashCode) +
      (summary.hashCode) +
      (motto.hashCode) +
      (confident.hashCode);

  @override
  String toString() =>
      'ArchetypeResponse[id=$id, name=$name, summary=$summary, motto=$motto, confident=$confident]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'id'] = this.id;
    json[r'name'] = this.name;
    json[r'summary'] = this.summary;
    json[r'motto'] = this.motto;
    json[r'confident'] = this.confident;
    return json;
  }

  /// Returns a new [ArchetypeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ArchetypeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'),
            'Required key "ArchetypeResponse[id]" is missing from JSON.');
        assert(json[r'id'] != null,
            'Required key "ArchetypeResponse[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'),
            'Required key "ArchetypeResponse[name]" is missing from JSON.');
        assert(json[r'name'] != null,
            'Required key "ArchetypeResponse[name]" has a null value in JSON.');
        assert(json.containsKey(r'summary'),
            'Required key "ArchetypeResponse[summary]" is missing from JSON.');
        assert(json[r'summary'] != null,
            'Required key "ArchetypeResponse[summary]" has a null value in JSON.');
        assert(json.containsKey(r'motto'),
            'Required key "ArchetypeResponse[motto]" is missing from JSON.');
        assert(json[r'motto'] != null,
            'Required key "ArchetypeResponse[motto]" has a null value in JSON.');
        assert(json.containsKey(r'confident'),
            'Required key "ArchetypeResponse[confident]" is missing from JSON.');
        assert(json[r'confident'] != null,
            'Required key "ArchetypeResponse[confident]" has a null value in JSON.');
        return true;
      }());

      return ArchetypeResponse(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        summary: mapValueOfType<String>(json, r'summary')!,
        motto: mapValueOfType<String>(json, r'motto')!,
        confident: mapValueOfType<bool>(json, r'confident')!,
      );
    }
    return null;
  }

  static List<ArchetypeResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ArchetypeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ArchetypeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ArchetypeResponse> mapFromJson(dynamic json) {
    final map = <String, ArchetypeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ArchetypeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ArchetypeResponse-objects as value to a dart map
  static Map<String, List<ArchetypeResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ArchetypeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ArchetypeResponse.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'summary',
    'motto',
    'confident',
  };
}
