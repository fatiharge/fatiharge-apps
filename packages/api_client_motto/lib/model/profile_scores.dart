//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProfileScores {
  /// Returns a new [ProfileScores] instance.
  ProfileScores({
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
  });

  double openness;

  double conscientiousness;

  double extraversion;

  double agreeableness;

  double neuroticism;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileScores &&
          other.openness == openness &&
          other.conscientiousness == conscientiousness &&
          other.extraversion == extraversion &&
          other.agreeableness == agreeableness &&
          other.neuroticism == neuroticism;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (openness.hashCode) +
      (conscientiousness.hashCode) +
      (extraversion.hashCode) +
      (agreeableness.hashCode) +
      (neuroticism.hashCode);

  @override
  String toString() =>
      'ProfileScores[openness=$openness, conscientiousness=$conscientiousness, extraversion=$extraversion, agreeableness=$agreeableness, neuroticism=$neuroticism]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'openness'] = this.openness;
    json[r'conscientiousness'] = this.conscientiousness;
    json[r'extraversion'] = this.extraversion;
    json[r'agreeableness'] = this.agreeableness;
    json[r'neuroticism'] = this.neuroticism;
    return json;
  }

  /// Returns a new [ProfileScores] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProfileScores? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'openness'),
            'Required key "ProfileScores[openness]" is missing from JSON.');
        assert(json[r'openness'] != null,
            'Required key "ProfileScores[openness]" has a null value in JSON.');
        assert(json.containsKey(r'conscientiousness'),
            'Required key "ProfileScores[conscientiousness]" is missing from JSON.');
        assert(json[r'conscientiousness'] != null,
            'Required key "ProfileScores[conscientiousness]" has a null value in JSON.');
        assert(json.containsKey(r'extraversion'),
            'Required key "ProfileScores[extraversion]" is missing from JSON.');
        assert(json[r'extraversion'] != null,
            'Required key "ProfileScores[extraversion]" has a null value in JSON.');
        assert(json.containsKey(r'agreeableness'),
            'Required key "ProfileScores[agreeableness]" is missing from JSON.');
        assert(json[r'agreeableness'] != null,
            'Required key "ProfileScores[agreeableness]" has a null value in JSON.');
        assert(json.containsKey(r'neuroticism'),
            'Required key "ProfileScores[neuroticism]" is missing from JSON.');
        assert(json[r'neuroticism'] != null,
            'Required key "ProfileScores[neuroticism]" has a null value in JSON.');
        return true;
      }());

      return ProfileScores(
        openness: mapValueOfType<double>(json, r'openness')!,
        conscientiousness: mapValueOfType<double>(json, r'conscientiousness')!,
        extraversion: mapValueOfType<double>(json, r'extraversion')!,
        agreeableness: mapValueOfType<double>(json, r'agreeableness')!,
        neuroticism: mapValueOfType<double>(json, r'neuroticism')!,
      );
    }
    return null;
  }

  static List<ProfileScores> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ProfileScores>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfileScores.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProfileScores> mapFromJson(dynamic json) {
    final map = <String, ProfileScores>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProfileScores.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProfileScores-objects as value to a dart map
  static Map<String, List<ProfileScores>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ProfileScores>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProfileScores.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'openness',
    'conscientiousness',
    'extraversion',
    'agreeableness',
    'neuroticism',
  };
}
