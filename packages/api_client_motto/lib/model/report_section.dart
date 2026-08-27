//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReportSection {
  /// Returns a new [ReportSection] instance.
  ReportSection({
    required this.section,
    required this.opening,
    required this.reading,
    required this.fragment,
  });

  int section;

  String opening;

  String reading;

  String fragment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSection &&
          other.section == section &&
          other.opening == opening &&
          other.reading == reading &&
          other.fragment == fragment;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (section.hashCode) +
      (opening.hashCode) +
      (reading.hashCode) +
      (fragment.hashCode);

  @override
  String toString() =>
      'ReportSection[section=$section, opening=$opening, reading=$reading, fragment=$fragment]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'section'] = this.section;
    json[r'opening'] = this.opening;
    json[r'reading'] = this.reading;
    json[r'fragment'] = this.fragment;
    return json;
  }

  /// Returns a new [ReportSection] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReportSection? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'section'),
            'Required key "ReportSection[section]" is missing from JSON.');
        assert(json[r'section'] != null,
            'Required key "ReportSection[section]" has a null value in JSON.');
        assert(json.containsKey(r'opening'),
            'Required key "ReportSection[opening]" is missing from JSON.');
        assert(json[r'opening'] != null,
            'Required key "ReportSection[opening]" has a null value in JSON.');
        assert(json.containsKey(r'reading'),
            'Required key "ReportSection[reading]" is missing from JSON.');
        assert(json[r'reading'] != null,
            'Required key "ReportSection[reading]" has a null value in JSON.');
        assert(json.containsKey(r'fragment'),
            'Required key "ReportSection[fragment]" is missing from JSON.');
        assert(json[r'fragment'] != null,
            'Required key "ReportSection[fragment]" has a null value in JSON.');
        return true;
      }());

      return ReportSection(
        section: mapValueOfType<int>(json, r'section')!,
        opening: mapValueOfType<String>(json, r'opening')!,
        reading: mapValueOfType<String>(json, r'reading')!,
        fragment: mapValueOfType<String>(json, r'fragment')!,
      );
    }
    return null;
  }

  static List<ReportSection> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ReportSection>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReportSection.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReportSection> mapFromJson(dynamic json) {
    final map = <String, ReportSection>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReportSection.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReportSection-objects as value to a dart map
  static Map<String, List<ReportSection>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ReportSection>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReportSection.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'section',
    'opening',
    'reading',
    'fragment',
  };
}
