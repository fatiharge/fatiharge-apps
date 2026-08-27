//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailySkeleton {
  /// Returns a new [DailySkeleton] instance.
  DailySkeleton({
    required this.day,
    required this.title,
    required this.body,
    required this.action,
  });

  int day;

  String title;

  String body;

  String action;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySkeleton &&
          other.day == day &&
          other.title == title &&
          other.body == body &&
          other.action == action;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (day.hashCode) + (title.hashCode) + (body.hashCode) + (action.hashCode);

  @override
  String toString() =>
      'DailySkeleton[day=$day, title=$title, body=$body, action=$action]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'day'] = this.day;
    json[r'title'] = this.title;
    json[r'body'] = this.body;
    json[r'action'] = this.action;
    return json;
  }

  /// Returns a new [DailySkeleton] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailySkeleton? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'day'),
            'Required key "DailySkeleton[day]" is missing from JSON.');
        assert(json[r'day'] != null,
            'Required key "DailySkeleton[day]" has a null value in JSON.');
        assert(json.containsKey(r'title'),
            'Required key "DailySkeleton[title]" is missing from JSON.');
        assert(json[r'title'] != null,
            'Required key "DailySkeleton[title]" has a null value in JSON.');
        assert(json.containsKey(r'body'),
            'Required key "DailySkeleton[body]" is missing from JSON.');
        assert(json[r'body'] != null,
            'Required key "DailySkeleton[body]" has a null value in JSON.');
        assert(json.containsKey(r'action'),
            'Required key "DailySkeleton[action]" is missing from JSON.');
        assert(json[r'action'] != null,
            'Required key "DailySkeleton[action]" has a null value in JSON.');
        return true;
      }());

      return DailySkeleton(
        day: mapValueOfType<int>(json, r'day')!,
        title: mapValueOfType<String>(json, r'title')!,
        body: mapValueOfType<String>(json, r'body')!,
        action: mapValueOfType<String>(json, r'action')!,
      );
    }
    return null;
  }

  static List<DailySkeleton> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DailySkeleton>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailySkeleton.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailySkeleton> mapFromJson(dynamic json) {
    final map = <String, DailySkeleton>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailySkeleton.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailySkeleton-objects as value to a dart map
  static Map<String, List<DailySkeleton>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DailySkeleton>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailySkeleton.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'day',
    'title',
    'body',
    'action',
  };
}
