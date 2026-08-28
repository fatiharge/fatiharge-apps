//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Leaderboard {
  /// Returns a new [Leaderboard] instance.
  Leaderboard({
    required this.week,
    this.entries = const [],
    required this.yourBest,
    required this.rewardedRanks,
  });

  DateTime week;

  List<LeaderboardEntry> entries;

  int yourBest;

  int rewardedRanks;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Leaderboard &&
          other.week == week &&
          _deepEquality.equals(other.entries, entries) &&
          other.yourBest == yourBest &&
          other.rewardedRanks == rewardedRanks;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (week.hashCode) +
      (entries.hashCode) +
      (yourBest.hashCode) +
      (rewardedRanks.hashCode);

  @override
  String toString() =>
      'Leaderboard[week=$week, entries=$entries, yourBest=$yourBest, rewardedRanks=$rewardedRanks]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'week'] = _dateFormatter.format(this.week);
    json[r'entries'] = this.entries;
    json[r'yourBest'] = this.yourBest;
    json[r'rewardedRanks'] = this.rewardedRanks;
    return json;
  }

  /// Returns a new [Leaderboard] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Leaderboard? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'week'),
            'Required key "Leaderboard[week]" is missing from JSON.');
        assert(json[r'week'] != null,
            'Required key "Leaderboard[week]" has a null value in JSON.');
        assert(json.containsKey(r'entries'),
            'Required key "Leaderboard[entries]" is missing from JSON.');
        assert(json[r'entries'] != null,
            'Required key "Leaderboard[entries]" has a null value in JSON.');
        assert(json.containsKey(r'yourBest'),
            'Required key "Leaderboard[yourBest]" is missing from JSON.');
        assert(json[r'yourBest'] != null,
            'Required key "Leaderboard[yourBest]" has a null value in JSON.');
        assert(json.containsKey(r'rewardedRanks'),
            'Required key "Leaderboard[rewardedRanks]" is missing from JSON.');
        assert(json[r'rewardedRanks'] != null,
            'Required key "Leaderboard[rewardedRanks]" has a null value in JSON.');
        return true;
      }());

      return Leaderboard(
        week: mapDateTime(json, r'week', r'')!,
        entries: LeaderboardEntry.listFromJson(json[r'entries']),
        yourBest: mapValueOfType<int>(json, r'yourBest')!,
        rewardedRanks: mapValueOfType<int>(json, r'rewardedRanks')!,
      );
    }
    return null;
  }

  static List<Leaderboard> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Leaderboard>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Leaderboard.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Leaderboard> mapFromJson(dynamic json) {
    final map = <String, Leaderboard>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Leaderboard.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Leaderboard-objects as value to a dart map
  static Map<String, List<Leaderboard>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Leaderboard>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Leaderboard.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'week',
    'entries',
    'yourBest',
    'rewardedRanks',
  };
}
