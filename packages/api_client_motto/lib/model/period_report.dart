//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PeriodReport {
  /// Returns a new [PeriodReport] instance.
  PeriodReport({
    required this.day,
    required this.daysMarked,
    required this.daysMadeUp,
    required this.tasksDone,
    required this.tasksOffered,
    required this.complete,
  });

  int day;

  int daysMarked;

  int daysMadeUp;

  int tasksDone;

  int tasksOffered;

  bool complete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodReport &&
          other.day == day &&
          other.daysMarked == daysMarked &&
          other.daysMadeUp == daysMadeUp &&
          other.tasksDone == tasksDone &&
          other.tasksOffered == tasksOffered &&
          other.complete == complete;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (day.hashCode) +
      (daysMarked.hashCode) +
      (daysMadeUp.hashCode) +
      (tasksDone.hashCode) +
      (tasksOffered.hashCode) +
      (complete.hashCode);

  @override
  String toString() =>
      'PeriodReport[day=$day, daysMarked=$daysMarked, daysMadeUp=$daysMadeUp, tasksDone=$tasksDone, tasksOffered=$tasksOffered, complete=$complete]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'day'] = this.day;
    json[r'daysMarked'] = this.daysMarked;
    json[r'daysMadeUp'] = this.daysMadeUp;
    json[r'tasksDone'] = this.tasksDone;
    json[r'tasksOffered'] = this.tasksOffered;
    json[r'complete'] = this.complete;
    return json;
  }

  /// Returns a new [PeriodReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PeriodReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'day'),
            'Required key "PeriodReport[day]" is missing from JSON.');
        assert(json[r'day'] != null,
            'Required key "PeriodReport[day]" has a null value in JSON.');
        assert(json.containsKey(r'daysMarked'),
            'Required key "PeriodReport[daysMarked]" is missing from JSON.');
        assert(json[r'daysMarked'] != null,
            'Required key "PeriodReport[daysMarked]" has a null value in JSON.');
        assert(json.containsKey(r'daysMadeUp'),
            'Required key "PeriodReport[daysMadeUp]" is missing from JSON.');
        assert(json[r'daysMadeUp'] != null,
            'Required key "PeriodReport[daysMadeUp]" has a null value in JSON.');
        assert(json.containsKey(r'tasksDone'),
            'Required key "PeriodReport[tasksDone]" is missing from JSON.');
        assert(json[r'tasksDone'] != null,
            'Required key "PeriodReport[tasksDone]" has a null value in JSON.');
        assert(json.containsKey(r'tasksOffered'),
            'Required key "PeriodReport[tasksOffered]" is missing from JSON.');
        assert(json[r'tasksOffered'] != null,
            'Required key "PeriodReport[tasksOffered]" has a null value in JSON.');
        assert(json.containsKey(r'complete'),
            'Required key "PeriodReport[complete]" is missing from JSON.');
        assert(json[r'complete'] != null,
            'Required key "PeriodReport[complete]" has a null value in JSON.');
        return true;
      }());

      return PeriodReport(
        day: mapValueOfType<int>(json, r'day')!,
        daysMarked: mapValueOfType<int>(json, r'daysMarked')!,
        daysMadeUp: mapValueOfType<int>(json, r'daysMadeUp')!,
        tasksDone: mapValueOfType<int>(json, r'tasksDone')!,
        tasksOffered: mapValueOfType<int>(json, r'tasksOffered')!,
        complete: mapValueOfType<bool>(json, r'complete')!,
      );
    }
    return null;
  }

  static List<PeriodReport> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PeriodReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PeriodReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PeriodReport> mapFromJson(dynamic json) {
    final map = <String, PeriodReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PeriodReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PeriodReport-objects as value to a dart map
  static Map<String, List<PeriodReport>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PeriodReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PeriodReport.listFromJson(
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
    'daysMarked',
    'daysMadeUp',
    'tasksDone',
    'tasksOffered',
    'complete',
  };
}
