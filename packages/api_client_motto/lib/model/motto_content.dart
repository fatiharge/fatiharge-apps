//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MottoContent {
  /// Returns a new [MottoContent] instance.
  MottoContent({
    required this.id,
    required this.archetypeId,
    required this.motto,
    required this.detail,
    required this.reminder,
  });

  String id;

  String archetypeId;

  String motto;

  String detail;

  String reminder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MottoContent &&
          other.id == id &&
          other.archetypeId == archetypeId &&
          other.motto == motto &&
          other.detail == detail &&
          other.reminder == reminder;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id.hashCode) +
      (archetypeId.hashCode) +
      (motto.hashCode) +
      (detail.hashCode) +
      (reminder.hashCode);

  @override
  String toString() =>
      'MottoContent[id=$id, archetypeId=$archetypeId, motto=$motto, detail=$detail, reminder=$reminder]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'id'] = this.id;
    json[r'archetypeId'] = this.archetypeId;
    json[r'motto'] = this.motto;
    json[r'detail'] = this.detail;
    json[r'reminder'] = this.reminder;
    return json;
  }

  /// Returns a new [MottoContent] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MottoContent? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'),
            'Required key "MottoContent[id]" is missing from JSON.');
        assert(json[r'id'] != null,
            'Required key "MottoContent[id]" has a null value in JSON.');
        assert(json.containsKey(r'archetypeId'),
            'Required key "MottoContent[archetypeId]" is missing from JSON.');
        assert(json[r'archetypeId'] != null,
            'Required key "MottoContent[archetypeId]" has a null value in JSON.');
        assert(json.containsKey(r'motto'),
            'Required key "MottoContent[motto]" is missing from JSON.');
        assert(json[r'motto'] != null,
            'Required key "MottoContent[motto]" has a null value in JSON.');
        assert(json.containsKey(r'detail'),
            'Required key "MottoContent[detail]" is missing from JSON.');
        assert(json[r'detail'] != null,
            'Required key "MottoContent[detail]" has a null value in JSON.');
        assert(json.containsKey(r'reminder'),
            'Required key "MottoContent[reminder]" is missing from JSON.');
        assert(json[r'reminder'] != null,
            'Required key "MottoContent[reminder]" has a null value in JSON.');
        return true;
      }());

      return MottoContent(
        id: mapValueOfType<String>(json, r'id')!,
        archetypeId: mapValueOfType<String>(json, r'archetypeId')!,
        motto: mapValueOfType<String>(json, r'motto')!,
        detail: mapValueOfType<String>(json, r'detail')!,
        reminder: mapValueOfType<String>(json, r'reminder')!,
      );
    }
    return null;
  }

  static List<MottoContent> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <MottoContent>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MottoContent.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MottoContent> mapFromJson(dynamic json) {
    final map = <String, MottoContent>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MottoContent.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MottoContent-objects as value to a dart map
  static Map<String, List<MottoContent>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<MottoContent>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MottoContent.listFromJson(
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
    'archetypeId',
    'motto',
    'detail',
    'reminder',
  };
}
