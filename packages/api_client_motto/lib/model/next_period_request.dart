//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NextPeriodRequest {
  /// Returns a new [NextPeriodRequest] instance.
  NextPeriodRequest({
    required this.day,
    this.mottoId,
  });

  DateTime day;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mottoId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NextPeriodRequest &&
          other.day == day &&
          other.mottoId == mottoId;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (day.hashCode) + (mottoId == null ? 0 : mottoId!.hashCode);

  @override
  String toString() => 'NextPeriodRequest[day=$day, mottoId=$mottoId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'day'] = _dateFormatter.format(this.day);
    if (this.mottoId != null) {
      json[r'mottoId'] = this.mottoId;
    } else {
      json[r'mottoId'] = null;
    }
    return json;
  }

  /// Returns a new [NextPeriodRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NextPeriodRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'day'),
            'Required key "NextPeriodRequest[day]" is missing from JSON.');
        assert(json[r'day'] != null,
            'Required key "NextPeriodRequest[day]" has a null value in JSON.');
        return true;
      }());

      return NextPeriodRequest(
        day: mapDateTime(json, r'day', r'')!,
        mottoId: mapValueOfType<String>(json, r'mottoId'),
      );
    }
    return null;
  }

  static List<NextPeriodRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <NextPeriodRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NextPeriodRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NextPeriodRequest> mapFromJson(dynamic json) {
    final map = <String, NextPeriodRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NextPeriodRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NextPeriodRequest-objects as value to a dart map
  static Map<String, List<NextPeriodRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<NextPeriodRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NextPeriodRequest.listFromJson(
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
  };
}
