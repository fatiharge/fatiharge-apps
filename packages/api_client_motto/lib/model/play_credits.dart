//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlayCredits {
  /// Returns a new [PlayCredits] instance.
  PlayCredits({
    this.remaining,
    this.earned,
    this.spent,
    this.dayMarked,
    this.tasksDone,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? remaining;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? earned;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? spent;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? dayMarked;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? tasksDone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayCredits &&
          other.remaining == remaining &&
          other.earned == earned &&
          other.spent == spent &&
          other.dayMarked == dayMarked &&
          other.tasksDone == tasksDone;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (remaining == null ? 0 : remaining!.hashCode) +
      (earned == null ? 0 : earned!.hashCode) +
      (spent == null ? 0 : spent!.hashCode) +
      (dayMarked == null ? 0 : dayMarked!.hashCode) +
      (tasksDone == null ? 0 : tasksDone!.hashCode);

  @override
  String toString() =>
      'PlayCredits[remaining=$remaining, earned=$earned, spent=$spent, dayMarked=$dayMarked, tasksDone=$tasksDone]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.remaining != null) {
      json[r'remaining'] = this.remaining;
    } else {
      json[r'remaining'] = null;
    }
    if (this.earned != null) {
      json[r'earned'] = this.earned;
    } else {
      json[r'earned'] = null;
    }
    if (this.spent != null) {
      json[r'spent'] = this.spent;
    } else {
      json[r'spent'] = null;
    }
    if (this.dayMarked != null) {
      json[r'dayMarked'] = this.dayMarked;
    } else {
      json[r'dayMarked'] = null;
    }
    if (this.tasksDone != null) {
      json[r'tasksDone'] = this.tasksDone;
    } else {
      json[r'tasksDone'] = null;
    }
    return json;
  }

  /// Returns a new [PlayCredits] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlayCredits? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return PlayCredits(
        remaining: mapValueOfType<int>(json, r'remaining'),
        earned: mapValueOfType<int>(json, r'earned'),
        spent: mapValueOfType<int>(json, r'spent'),
        dayMarked: mapValueOfType<bool>(json, r'dayMarked'),
        tasksDone: mapValueOfType<bool>(json, r'tasksDone'),
      );
    }
    return null;
  }

  static List<PlayCredits> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PlayCredits>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlayCredits.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlayCredits> mapFromJson(dynamic json) {
    final map = <String, PlayCredits>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlayCredits.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlayCredits-objects as value to a dart map
  static Map<String, List<PlayCredits>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PlayCredits>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlayCredits.listFromJson(
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
