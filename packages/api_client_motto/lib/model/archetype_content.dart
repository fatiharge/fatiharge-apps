//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ArchetypeContent {
  /// Returns a new [ArchetypeContent] instance.
  ArchetypeContent({
    required this.id,
    required this.name,
    required this.summary,
    required this.motto,
  });

  String id;

  String name;

  String summary;

  String motto;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchetypeContent &&
          other.id == id &&
          other.name == name &&
          other.summary == summary &&
          other.motto == motto;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id.hashCode) + (name.hashCode) + (summary.hashCode) + (motto.hashCode);

  @override
  String toString() =>
      'ArchetypeContent[id=$id, name=$name, summary=$summary, motto=$motto]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'id'] = this.id;
    json[r'name'] = this.name;
    json[r'summary'] = this.summary;
    json[r'motto'] = this.motto;
    return json;
  }

  /// Returns a new [ArchetypeContent] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ArchetypeContent? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'),
            'Required key "ArchetypeContent[id]" is missing from JSON.');
        assert(json[r'id'] != null,
            'Required key "ArchetypeContent[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'),
            'Required key "ArchetypeContent[name]" is missing from JSON.');
        assert(json[r'name'] != null,
            'Required key "ArchetypeContent[name]" has a null value in JSON.');
        assert(json.containsKey(r'summary'),
            'Required key "ArchetypeContent[summary]" is missing from JSON.');
        assert(json[r'summary'] != null,
            'Required key "ArchetypeContent[summary]" has a null value in JSON.');
        assert(json.containsKey(r'motto'),
            'Required key "ArchetypeContent[motto]" is missing from JSON.');
        assert(json[r'motto'] != null,
            'Required key "ArchetypeContent[motto]" has a null value in JSON.');
        return true;
      }());

      return ArchetypeContent(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        summary: mapValueOfType<String>(json, r'summary')!,
        motto: mapValueOfType<String>(json, r'motto')!,
      );
    }
    return null;
  }

  static List<ArchetypeContent> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ArchetypeContent>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ArchetypeContent.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ArchetypeContent> mapFromJson(dynamic json) {
    final map = <String, ArchetypeContent>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ArchetypeContent.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ArchetypeContent-objects as value to a dart map
  static Map<String, List<ArchetypeContent>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ArchetypeContent>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ArchetypeContent.listFromJson(
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
  };
}
