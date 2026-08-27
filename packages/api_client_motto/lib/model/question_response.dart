//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QuestionResponse {
  /// Returns a new [QuestionResponse] instance.
  QuestionResponse({
    required this.likertPoints,
    this.questions = const [],
  });

  int likertPoints;

  List<Question> questions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionResponse &&
          other.likertPoints == likertPoints &&
          _deepEquality.equals(other.questions, questions);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (likertPoints.hashCode) + (questions.hashCode);

  @override
  String toString() =>
      'QuestionResponse[likertPoints=$likertPoints, questions=$questions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'likertPoints'] = this.likertPoints;
    json[r'questions'] = this.questions;
    return json;
  }

  /// Returns a new [QuestionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuestionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'likertPoints'),
            'Required key "QuestionResponse[likertPoints]" is missing from JSON.');
        assert(json[r'likertPoints'] != null,
            'Required key "QuestionResponse[likertPoints]" has a null value in JSON.');
        assert(json.containsKey(r'questions'),
            'Required key "QuestionResponse[questions]" is missing from JSON.');
        assert(json[r'questions'] != null,
            'Required key "QuestionResponse[questions]" has a null value in JSON.');
        return true;
      }());

      return QuestionResponse(
        likertPoints: mapValueOfType<int>(json, r'likertPoints')!,
        questions: Question.listFromJson(json[r'questions']),
      );
    }
    return null;
  }

  static List<QuestionResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <QuestionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuestionResponse> mapFromJson(dynamic json) {
    final map = <String, QuestionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuestionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuestionResponse-objects as value to a dart map
  static Map<String, List<QuestionResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<QuestionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuestionResponse.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'likertPoints',
    'questions',
  };
}
