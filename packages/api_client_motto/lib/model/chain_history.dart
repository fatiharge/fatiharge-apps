//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChainHistory {
  /// Returns a new [ChainHistory] instance.
  ChainHistory({
    this.periods = const [],
  });

  List<ChainPeriod> periods;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainHistory && _deepEquality.equals(other.periods, periods);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (periods.hashCode);

  @override
  String toString() => 'ChainHistory[periods=$periods]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'periods'] = this.periods;
    return json;
  }

  /// Returns a new [ChainHistory] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChainHistory? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'periods'),
            'Required key "ChainHistory[periods]" is missing from JSON.');
        assert(json[r'periods'] != null,
            'Required key "ChainHistory[periods]" has a null value in JSON.');
        return true;
      }());

      return ChainHistory(
        periods: ChainPeriod.listFromJson(json[r'periods']),
      );
    }
    return null;
  }

  static List<ChainHistory> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ChainHistory>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChainHistory.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChainHistory> mapFromJson(dynamic json) {
    final map = <String, ChainHistory>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChainHistory.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChainHistory-objects as value to a dart map
  static Map<String, List<ChainHistory>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ChainHistory>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChainHistory.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'periods',
  };
}
