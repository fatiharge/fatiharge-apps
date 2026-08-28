//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ScoreSubmission {
  /// Returns a new [ScoreSubmission] instance.
  ScoreSubmission({
    required this.points,
  });

  int points;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreSubmission && other.points == points;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (points.hashCode);

  @override
  String toString() => 'ScoreSubmission[points=$points]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'points'] = this.points;
    return json;
  }

  /// Returns a new [ScoreSubmission] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ScoreSubmission? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'points'),
            'Required key "ScoreSubmission[points]" is missing from JSON.');
        assert(json[r'points'] != null,
            'Required key "ScoreSubmission[points]" has a null value in JSON.');
        return true;
      }());

      return ScoreSubmission(
        points: mapValueOfType<int>(json, r'points')!,
      );
    }
    return null;
  }

  static List<ScoreSubmission> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ScoreSubmission>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ScoreSubmission.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ScoreSubmission> mapFromJson(dynamic json) {
    final map = <String, ScoreSubmission>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ScoreSubmission.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ScoreSubmission-objects as value to a dart map
  static Map<String, List<ScoreSubmission>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ScoreSubmission>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ScoreSubmission.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'points',
  };
}
