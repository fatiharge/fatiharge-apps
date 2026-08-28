//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ResultReport {
  /// Returns a new [ResultReport] instance.
  ResultReport({
    required this.resultId,
    required this.archetypeId,
    required this.overview,
    this.readings = const [],
    required this.strength,
    required this.cost,
  });

  int resultId;

  String archetypeId;

  String overview;

  List<DimensionReading> readings;

  String strength;

  String cost;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultReport &&
          other.resultId == resultId &&
          other.archetypeId == archetypeId &&
          other.overview == overview &&
          _deepEquality.equals(other.readings, readings) &&
          other.strength == strength &&
          other.cost == cost;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (resultId.hashCode) +
      (archetypeId.hashCode) +
      (overview.hashCode) +
      (readings.hashCode) +
      (strength.hashCode) +
      (cost.hashCode);

  @override
  String toString() =>
      'ResultReport[resultId=$resultId, archetypeId=$archetypeId, overview=$overview, readings=$readings, strength=$strength, cost=$cost]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'resultId'] = this.resultId;
    json[r'archetypeId'] = this.archetypeId;
    json[r'overview'] = this.overview;
    json[r'readings'] = this.readings;
    json[r'strength'] = this.strength;
    json[r'cost'] = this.cost;
    return json;
  }

  /// Returns a new [ResultReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ResultReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'resultId'),
            'Required key "ResultReport[resultId]" is missing from JSON.');
        assert(json[r'resultId'] != null,
            'Required key "ResultReport[resultId]" has a null value in JSON.');
        assert(json.containsKey(r'archetypeId'),
            'Required key "ResultReport[archetypeId]" is missing from JSON.');
        assert(json[r'archetypeId'] != null,
            'Required key "ResultReport[archetypeId]" has a null value in JSON.');
        assert(json.containsKey(r'overview'),
            'Required key "ResultReport[overview]" is missing from JSON.');
        assert(json[r'overview'] != null,
            'Required key "ResultReport[overview]" has a null value in JSON.');
        assert(json.containsKey(r'readings'),
            'Required key "ResultReport[readings]" is missing from JSON.');
        assert(json[r'readings'] != null,
            'Required key "ResultReport[readings]" has a null value in JSON.');
        assert(json.containsKey(r'strength'),
            'Required key "ResultReport[strength]" is missing from JSON.');
        assert(json[r'strength'] != null,
            'Required key "ResultReport[strength]" has a null value in JSON.');
        assert(json.containsKey(r'cost'),
            'Required key "ResultReport[cost]" is missing from JSON.');
        assert(json[r'cost'] != null,
            'Required key "ResultReport[cost]" has a null value in JSON.');
        return true;
      }());

      return ResultReport(
        resultId: mapValueOfType<int>(json, r'resultId')!,
        archetypeId: mapValueOfType<String>(json, r'archetypeId')!,
        overview: mapValueOfType<String>(json, r'overview')!,
        readings: DimensionReading.listFromJson(json[r'readings']),
        strength: mapValueOfType<String>(json, r'strength')!,
        cost: mapValueOfType<String>(json, r'cost')!,
      );
    }
    return null;
  }

  static List<ResultReport> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ResultReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ResultReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ResultReport> mapFromJson(dynamic json) {
    final map = <String, ResultReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ResultReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ResultReport-objects as value to a dart map
  static Map<String, List<ResultReport>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ResultReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ResultReport.listFromJson(
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
    'overview',
    'readings',
    'strength',
    'cost',
  };
}
