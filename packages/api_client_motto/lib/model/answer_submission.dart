//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AnswerSubmission {
  /// Returns a new [AnswerSubmission] instance.
  AnswerSubmission({
    this.answers = const {},
    required this.spendSkip,
  });

  Map<String, int> answers;

  bool spendSkip;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerSubmission &&
          _deepEquality.equals(other.answers, answers) &&
          other.spendSkip == spendSkip;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (answers.hashCode) + (spendSkip.hashCode);

  @override
  String toString() =>
      'AnswerSubmission[answers=$answers, spendSkip=$spendSkip]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'answers'] = this.answers;
    json[r'spendSkip'] = this.spendSkip;
    return json;
  }

  /// Returns a new [AnswerSubmission] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AnswerSubmission? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'answers'),
            'Required key "AnswerSubmission[answers]" is missing from JSON.');
        assert(json[r'answers'] != null,
            'Required key "AnswerSubmission[answers]" has a null value in JSON.');
        assert(json.containsKey(r'spendSkip'),
            'Required key "AnswerSubmission[spendSkip]" is missing from JSON.');
        assert(json[r'spendSkip'] != null,
            'Required key "AnswerSubmission[spendSkip]" has a null value in JSON.');
        return true;
      }());

      return AnswerSubmission(
        answers: mapCastOfType<String, int>(json, r'answers')!,
        spendSkip: mapValueOfType<bool>(json, r'spendSkip')!,
      );
    }
    return null;
  }

  static List<AnswerSubmission> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <AnswerSubmission>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AnswerSubmission.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AnswerSubmission> mapFromJson(dynamic json) {
    final map = <String, AnswerSubmission>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AnswerSubmission.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AnswerSubmission-objects as value to a dart map
  static Map<String, List<AnswerSubmission>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<AnswerSubmission>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AnswerSubmission.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'answers',
    'spendSkip',
  };
}
