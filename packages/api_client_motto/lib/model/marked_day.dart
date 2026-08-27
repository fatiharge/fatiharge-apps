//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MarkedDay {
  /// Returns a new [MarkedDay] instance.
  MarkedDay({
    required this.day,
    required this.madeUp,
  });

  DateTime day;

  bool madeUp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkedDay && other.day == day && other.madeUp == madeUp;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (day.hashCode) + (madeUp.hashCode);

  @override
  String toString() => 'MarkedDay[day=$day, madeUp=$madeUp]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'day'] = _dateFormatter.format(this.day);
    json[r'madeUp'] = this.madeUp;
    return json;
  }

  /// Returns a new [MarkedDay] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MarkedDay? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'day'),
            'Required key "MarkedDay[day]" is missing from JSON.');
        assert(json[r'day'] != null,
            'Required key "MarkedDay[day]" has a null value in JSON.');
        assert(json.containsKey(r'madeUp'),
            'Required key "MarkedDay[madeUp]" is missing from JSON.');
        assert(json[r'madeUp'] != null,
            'Required key "MarkedDay[madeUp]" has a null value in JSON.');
        return true;
      }());

      return MarkedDay(
        day: mapDateTime(json, r'day', r'')!,
        madeUp: mapValueOfType<bool>(json, r'madeUp')!,
      );
    }
    return null;
  }

  static List<MarkedDay> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <MarkedDay>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MarkedDay.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MarkedDay> mapFromJson(dynamic json) {
    final map = <String, MarkedDay>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MarkedDay.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MarkedDay-objects as value to a dart map
  static Map<String, List<MarkedDay>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<MarkedDay>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MarkedDay.listFromJson(
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
    'madeUp',
  };
}
