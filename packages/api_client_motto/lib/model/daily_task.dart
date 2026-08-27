//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailyTask {
  /// Returns a new [DailyTask] instance.
  DailyTask({
    required this.id,
    required this.ordinal,
    required this.title,
    required this.detail,
    required this.done,
  });

  int id;

  int ordinal;

  String title;

  String detail;

  bool done;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTask &&
          other.id == id &&
          other.ordinal == ordinal &&
          other.title == title &&
          other.detail == detail &&
          other.done == done;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id.hashCode) +
      (ordinal.hashCode) +
      (title.hashCode) +
      (detail.hashCode) +
      (done.hashCode);

  @override
  String toString() =>
      'DailyTask[id=$id, ordinal=$ordinal, title=$title, detail=$detail, done=$done]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'id'] = this.id;
    json[r'ordinal'] = this.ordinal;
    json[r'title'] = this.title;
    json[r'detail'] = this.detail;
    json[r'done'] = this.done;
    return json;
  }

  /// Returns a new [DailyTask] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailyTask? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'),
            'Required key "DailyTask[id]" is missing from JSON.');
        assert(json[r'id'] != null,
            'Required key "DailyTask[id]" has a null value in JSON.');
        assert(json.containsKey(r'ordinal'),
            'Required key "DailyTask[ordinal]" is missing from JSON.');
        assert(json[r'ordinal'] != null,
            'Required key "DailyTask[ordinal]" has a null value in JSON.');
        assert(json.containsKey(r'title'),
            'Required key "DailyTask[title]" is missing from JSON.');
        assert(json[r'title'] != null,
            'Required key "DailyTask[title]" has a null value in JSON.');
        assert(json.containsKey(r'detail'),
            'Required key "DailyTask[detail]" is missing from JSON.');
        assert(json[r'detail'] != null,
            'Required key "DailyTask[detail]" has a null value in JSON.');
        assert(json.containsKey(r'done'),
            'Required key "DailyTask[done]" is missing from JSON.');
        assert(json[r'done'] != null,
            'Required key "DailyTask[done]" has a null value in JSON.');
        return true;
      }());

      return DailyTask(
        id: mapValueOfType<int>(json, r'id')!,
        ordinal: mapValueOfType<int>(json, r'ordinal')!,
        title: mapValueOfType<String>(json, r'title')!,
        detail: mapValueOfType<String>(json, r'detail')!,
        done: mapValueOfType<bool>(json, r'done')!,
      );
    }
    return null;
  }

  static List<DailyTask> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DailyTask>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailyTask.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailyTask> mapFromJson(dynamic json) {
    final map = <String, DailyTask>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailyTask.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailyTask-objects as value to a dart map
  static Map<String, List<DailyTask>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DailyTask>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailyTask.listFromJson(
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
    'ordinal',
    'title',
    'detail',
    'done',
  };
}
