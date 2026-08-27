//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ResultSummary {
  /// Returns a new [ResultSummary] instance.
  ResultSummary({
    required this.id,
    required this.archetype,
    required this.profile,
    required this.claimedAt,
  });

  int id;

  ArchetypeResponse archetype;

  ProfileScores profile;

  DateTime claimedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultSummary &&
          other.id == id &&
          other.archetype == archetype &&
          other.profile == profile &&
          other.claimedAt == claimedAt;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id.hashCode) +
      (archetype.hashCode) +
      (profile.hashCode) +
      (claimedAt.hashCode);

  @override
  String toString() =>
      'ResultSummary[id=$id, archetype=$archetype, profile=$profile, claimedAt=$claimedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'id'] = this.id;
    json[r'archetype'] = this.archetype;
    json[r'profile'] = this.profile;
    json[r'claimedAt'] = this.claimedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ResultSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ResultSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'),
            'Required key "ResultSummary[id]" is missing from JSON.');
        assert(json[r'id'] != null,
            'Required key "ResultSummary[id]" has a null value in JSON.');
        assert(json.containsKey(r'archetype'),
            'Required key "ResultSummary[archetype]" is missing from JSON.');
        assert(json[r'archetype'] != null,
            'Required key "ResultSummary[archetype]" has a null value in JSON.');
        assert(json.containsKey(r'profile'),
            'Required key "ResultSummary[profile]" is missing from JSON.');
        assert(json[r'profile'] != null,
            'Required key "ResultSummary[profile]" has a null value in JSON.');
        assert(json.containsKey(r'claimedAt'),
            'Required key "ResultSummary[claimedAt]" is missing from JSON.');
        assert(json[r'claimedAt'] != null,
            'Required key "ResultSummary[claimedAt]" has a null value in JSON.');
        return true;
      }());

      return ResultSummary(
        id: mapValueOfType<int>(json, r'id')!,
        archetype: ArchetypeResponse.fromJson(json[r'archetype'])!,
        profile: ProfileScores.fromJson(json[r'profile'])!,
        claimedAt: mapDateTime(json, r'claimedAt', r'')!,
      );
    }
    return null;
  }

  static List<ResultSummary> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ResultSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ResultSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ResultSummary> mapFromJson(dynamic json) {
    final map = <String, ResultSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ResultSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ResultSummary-objects as value to a dart map
  static Map<String, List<ResultSummary>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ResultSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ResultSummary.listFromJson(
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
    'archetype',
    'profile',
    'claimedAt',
  };
}
