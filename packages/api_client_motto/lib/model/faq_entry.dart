//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FaqEntry {
  /// Returns a new [FaqEntry] instance.
  FaqEntry({
    required this.id,
    required this.question,
    required this.answer,
  });

  String id;

  String question;

  String answer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaqEntry &&
          other.id == id &&
          other.question == question &&
          other.answer == answer;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id.hashCode) + (question.hashCode) + (answer.hashCode);

  @override
  String toString() => 'FaqEntry[id=$id, question=$question, answer=$answer]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'id'] = this.id;
    json[r'question'] = this.question;
    json[r'answer'] = this.answer;
    return json;
  }

  /// Returns a new [FaqEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FaqEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'),
            'Required key "FaqEntry[id]" is missing from JSON.');
        assert(json[r'id'] != null,
            'Required key "FaqEntry[id]" has a null value in JSON.');
        assert(json.containsKey(r'question'),
            'Required key "FaqEntry[question]" is missing from JSON.');
        assert(json[r'question'] != null,
            'Required key "FaqEntry[question]" has a null value in JSON.');
        assert(json.containsKey(r'answer'),
            'Required key "FaqEntry[answer]" is missing from JSON.');
        assert(json[r'answer'] != null,
            'Required key "FaqEntry[answer]" has a null value in JSON.');
        return true;
      }());

      return FaqEntry(
        id: mapValueOfType<String>(json, r'id')!,
        question: mapValueOfType<String>(json, r'question')!,
        answer: mapValueOfType<String>(json, r'answer')!,
      );
    }
    return null;
  }

  static List<FaqEntry> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <FaqEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FaqEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FaqEntry> mapFromJson(dynamic json) {
    final map = <String, FaqEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FaqEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FaqEntry-objects as value to a dart map
  static Map<String, List<FaqEntry>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<FaqEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FaqEntry.listFromJson(
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
    'question',
    'answer',
  };
}
