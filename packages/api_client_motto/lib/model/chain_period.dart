//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChainPeriod {
  /// Returns a new [ChainPeriod] instance.
  ChainPeriod({
    required this.period,
    required this.current,
    this.days = const [],
  });

  int period;

  bool current;

  List<MarkedDay> days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainPeriod &&
          other.period == period &&
          other.current == current &&
          _deepEquality.equals(other.days, days);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (period.hashCode) + (current.hashCode) + (days.hashCode);

  @override
  String toString() =>
      'ChainPeriod[period=$period, current=$current, days=$days]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'period'] = this.period;
    json[r'current'] = this.current;
    json[r'days'] = this.days;
    return json;
  }

  /// Returns a new [ChainPeriod] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChainPeriod? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'period'),
            'Required key "ChainPeriod[period]" is missing from JSON.');
        assert(json[r'period'] != null,
            'Required key "ChainPeriod[period]" has a null value in JSON.');
        assert(json.containsKey(r'current'),
            'Required key "ChainPeriod[current]" is missing from JSON.');
        assert(json[r'current'] != null,
            'Required key "ChainPeriod[current]" has a null value in JSON.');
        assert(json.containsKey(r'days'),
            'Required key "ChainPeriod[days]" is missing from JSON.');
        assert(json[r'days'] != null,
            'Required key "ChainPeriod[days]" has a null value in JSON.');
        return true;
      }());

      return ChainPeriod(
        period: mapValueOfType<int>(json, r'period')!,
        current: mapValueOfType<bool>(json, r'current')!,
        days: MarkedDay.listFromJson(json[r'days']),
      );
    }
    return null;
  }

  static List<ChainPeriod> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ChainPeriod>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChainPeriod.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChainPeriod> mapFromJson(dynamic json) {
    final map = <String, ChainPeriod>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChainPeriod.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChainPeriod-objects as value to a dart map
  static Map<String, List<ChainPeriod>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ChainPeriod>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChainPeriod.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'period',
    'current',
    'days',
  };
}
