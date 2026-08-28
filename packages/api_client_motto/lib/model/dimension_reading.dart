//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DimensionReading {
  /// Returns a new [DimensionReading] instance.
  DimensionReading({
    required this.dimension,
    required this.band,
    required this.score,
    required this.text,
  });

  String dimension;

  String band;

  double score;

  String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DimensionReading &&
          other.dimension == dimension &&
          other.band == band &&
          other.score == score &&
          other.text == text;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (dimension.hashCode) +
      (band.hashCode) +
      (score.hashCode) +
      (text.hashCode);

  @override
  String toString() =>
      'DimensionReading[dimension=$dimension, band=$band, score=$score, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'dimension'] = this.dimension;
    json[r'band'] = this.band;
    json[r'score'] = this.score;
    json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [DimensionReading] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DimensionReading? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'dimension'),
            'Required key "DimensionReading[dimension]" is missing from JSON.');
        assert(json[r'dimension'] != null,
            'Required key "DimensionReading[dimension]" has a null value in JSON.');
        assert(json.containsKey(r'band'),
            'Required key "DimensionReading[band]" is missing from JSON.');
        assert(json[r'band'] != null,
            'Required key "DimensionReading[band]" has a null value in JSON.');
        assert(json.containsKey(r'score'),
            'Required key "DimensionReading[score]" is missing from JSON.');
        assert(json[r'score'] != null,
            'Required key "DimensionReading[score]" has a null value in JSON.');
        assert(json.containsKey(r'text'),
            'Required key "DimensionReading[text]" is missing from JSON.');
        assert(json[r'text'] != null,
            'Required key "DimensionReading[text]" has a null value in JSON.');
        return true;
      }());

      return DimensionReading(
        dimension: mapValueOfType<String>(json, r'dimension')!,
        band: mapValueOfType<String>(json, r'band')!,
        score: mapValueOfType<double>(json, r'score')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<DimensionReading> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DimensionReading>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DimensionReading.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DimensionReading> mapFromJson(dynamic json) {
    final map = <String, DimensionReading>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DimensionReading.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DimensionReading-objects as value to a dart map
  static Map<String, List<DimensionReading>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DimensionReading>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DimensionReading.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dimension',
    'band',
    'score',
    'text',
  };
}
