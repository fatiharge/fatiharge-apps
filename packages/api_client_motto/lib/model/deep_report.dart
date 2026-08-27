//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeepReport {
  /// Returns a new [DeepReport] instance.
  DeepReport({
    required this.resultId,
    required this.archetypeId,
    required this.locked,
    required this.preview,
    this.sections = const [],
    this.portrait,
    this.comparison,
    this.limitation,
  });

  int resultId;

  String archetypeId;

  bool locked;

  String preview;

  List<ReportSection> sections;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? portrait;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? comparison;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? limitation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeepReport &&
          other.resultId == resultId &&
          other.archetypeId == archetypeId &&
          other.locked == locked &&
          other.preview == preview &&
          _deepEquality.equals(other.sections, sections) &&
          other.portrait == portrait &&
          other.comparison == comparison &&
          other.limitation == limitation;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (resultId.hashCode) +
      (archetypeId.hashCode) +
      (locked.hashCode) +
      (preview.hashCode) +
      (sections.hashCode) +
      (portrait == null ? 0 : portrait!.hashCode) +
      (comparison == null ? 0 : comparison!.hashCode) +
      (limitation == null ? 0 : limitation!.hashCode);

  @override
  String toString() =>
      'DeepReport[resultId=$resultId, archetypeId=$archetypeId, locked=$locked, preview=$preview, sections=$sections, portrait=$portrait, comparison=$comparison, limitation=$limitation]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'resultId'] = this.resultId;
    json[r'archetypeId'] = this.archetypeId;
    json[r'locked'] = this.locked;
    json[r'preview'] = this.preview;
    json[r'sections'] = this.sections;
    if (this.portrait != null) {
      json[r'portrait'] = this.portrait;
    } else {
      json[r'portrait'] = null;
    }
    if (this.comparison != null) {
      json[r'comparison'] = this.comparison;
    } else {
      json[r'comparison'] = null;
    }
    if (this.limitation != null) {
      json[r'limitation'] = this.limitation;
    } else {
      json[r'limitation'] = null;
    }
    return json;
  }

  /// Returns a new [DeepReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeepReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'resultId'),
            'Required key "DeepReport[resultId]" is missing from JSON.');
        assert(json[r'resultId'] != null,
            'Required key "DeepReport[resultId]" has a null value in JSON.');
        assert(json.containsKey(r'archetypeId'),
            'Required key "DeepReport[archetypeId]" is missing from JSON.');
        assert(json[r'archetypeId'] != null,
            'Required key "DeepReport[archetypeId]" has a null value in JSON.');
        assert(json.containsKey(r'locked'),
            'Required key "DeepReport[locked]" is missing from JSON.');
        assert(json[r'locked'] != null,
            'Required key "DeepReport[locked]" has a null value in JSON.');
        assert(json.containsKey(r'preview'),
            'Required key "DeepReport[preview]" is missing from JSON.');
        assert(json[r'preview'] != null,
            'Required key "DeepReport[preview]" has a null value in JSON.');
        assert(json.containsKey(r'sections'),
            'Required key "DeepReport[sections]" is missing from JSON.');
        assert(json[r'sections'] != null,
            'Required key "DeepReport[sections]" has a null value in JSON.');
        return true;
      }());

      return DeepReport(
        resultId: mapValueOfType<int>(json, r'resultId')!,
        archetypeId: mapValueOfType<String>(json, r'archetypeId')!,
        locked: mapValueOfType<bool>(json, r'locked')!,
        preview: mapValueOfType<String>(json, r'preview')!,
        sections: ReportSection.listFromJson(json[r'sections']),
        portrait: mapValueOfType<String>(json, r'portrait'),
        comparison: mapValueOfType<String>(json, r'comparison'),
        limitation: mapValueOfType<String>(json, r'limitation'),
      );
    }
    return null;
  }

  static List<DeepReport> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DeepReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeepReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeepReport> mapFromJson(dynamic json) {
    final map = <String, DeepReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeepReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeepReport-objects as value to a dart map
  static Map<String, List<DeepReport>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DeepReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeepReport.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'resultId',
    'archetypeId',
    'locked',
    'preview',
    'sections',
  };
}
