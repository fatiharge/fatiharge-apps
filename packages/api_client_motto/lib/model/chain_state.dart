//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChainState {
  /// Returns a new [ChainState] instance.
  ChainState({
    required this.started,
    this.startedOn,
    this.markedDays = const [],
    this.freezeUsedOn,
    required this.streak,
    required this.markedToday,
    required this.broken,
    required this.canFreeze,
    required this.period,
    this.mottoId,
    required this.periodDone,
  });

  bool started;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? startedOn;

  List<MarkedDay> markedDays;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? freezeUsedOn;

  int streak;

  bool markedToday;

  bool broken;

  bool canFreeze;

  int period;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mottoId;

  bool periodDone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainState &&
          other.started == started &&
          other.startedOn == startedOn &&
          _deepEquality.equals(other.markedDays, markedDays) &&
          other.freezeUsedOn == freezeUsedOn &&
          other.streak == streak &&
          other.markedToday == markedToday &&
          other.broken == broken &&
          other.canFreeze == canFreeze &&
          other.period == period &&
          other.mottoId == mottoId &&
          other.periodDone == periodDone;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (started.hashCode) +
      (startedOn == null ? 0 : startedOn!.hashCode) +
      (markedDays.hashCode) +
      (freezeUsedOn == null ? 0 : freezeUsedOn!.hashCode) +
      (streak.hashCode) +
      (markedToday.hashCode) +
      (broken.hashCode) +
      (canFreeze.hashCode) +
      (period.hashCode) +
      (mottoId == null ? 0 : mottoId!.hashCode) +
      (periodDone.hashCode);

  @override
  String toString() =>
      'ChainState[started=$started, startedOn=$startedOn, markedDays=$markedDays, freezeUsedOn=$freezeUsedOn, streak=$streak, markedToday=$markedToday, broken=$broken, canFreeze=$canFreeze, period=$period, mottoId=$mottoId, periodDone=$periodDone]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'started'] = this.started;
    if (this.startedOn != null) {
      json[r'startedOn'] = _dateFormatter.format(this.startedOn!);
    } else {
      json[r'startedOn'] = null;
    }
    json[r'markedDays'] = this.markedDays;
    if (this.freezeUsedOn != null) {
      json[r'freezeUsedOn'] = _dateFormatter.format(this.freezeUsedOn!);
    } else {
      json[r'freezeUsedOn'] = null;
    }
    json[r'streak'] = this.streak;
    json[r'markedToday'] = this.markedToday;
    json[r'broken'] = this.broken;
    json[r'canFreeze'] = this.canFreeze;
    json[r'period'] = this.period;
    if (this.mottoId != null) {
      json[r'mottoId'] = this.mottoId;
    } else {
      json[r'mottoId'] = null;
    }
    json[r'periodDone'] = this.periodDone;
    return json;
  }

  /// Returns a new [ChainState] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChainState? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'started'),
            'Required key "ChainState[started]" is missing from JSON.');
        assert(json[r'started'] != null,
            'Required key "ChainState[started]" has a null value in JSON.');
        assert(json.containsKey(r'markedDays'),
            'Required key "ChainState[markedDays]" is missing from JSON.');
        assert(json[r'markedDays'] != null,
            'Required key "ChainState[markedDays]" has a null value in JSON.');
        assert(json.containsKey(r'streak'),
            'Required key "ChainState[streak]" is missing from JSON.');
        assert(json[r'streak'] != null,
            'Required key "ChainState[streak]" has a null value in JSON.');
        assert(json.containsKey(r'markedToday'),
            'Required key "ChainState[markedToday]" is missing from JSON.');
        assert(json[r'markedToday'] != null,
            'Required key "ChainState[markedToday]" has a null value in JSON.');
        assert(json.containsKey(r'broken'),
            'Required key "ChainState[broken]" is missing from JSON.');
        assert(json[r'broken'] != null,
            'Required key "ChainState[broken]" has a null value in JSON.');
        assert(json.containsKey(r'canFreeze'),
            'Required key "ChainState[canFreeze]" is missing from JSON.');
        assert(json[r'canFreeze'] != null,
            'Required key "ChainState[canFreeze]" has a null value in JSON.');
        assert(json.containsKey(r'period'),
            'Required key "ChainState[period]" is missing from JSON.');
        assert(json[r'period'] != null,
            'Required key "ChainState[period]" has a null value in JSON.');
        assert(json.containsKey(r'periodDone'),
            'Required key "ChainState[periodDone]" is missing from JSON.');
        assert(json[r'periodDone'] != null,
            'Required key "ChainState[periodDone]" has a null value in JSON.');
        return true;
      }());

      return ChainState(
        started: mapValueOfType<bool>(json, r'started')!,
        startedOn: mapDateTime(json, r'startedOn', r''),
        markedDays: MarkedDay.listFromJson(json[r'markedDays']),
        freezeUsedOn: mapDateTime(json, r'freezeUsedOn', r''),
        streak: mapValueOfType<int>(json, r'streak')!,
        markedToday: mapValueOfType<bool>(json, r'markedToday')!,
        broken: mapValueOfType<bool>(json, r'broken')!,
        canFreeze: mapValueOfType<bool>(json, r'canFreeze')!,
        period: mapValueOfType<int>(json, r'period')!,
        mottoId: mapValueOfType<String>(json, r'mottoId'),
        periodDone: mapValueOfType<bool>(json, r'periodDone')!,
      );
    }
    return null;
  }

  static List<ChainState> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ChainState>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChainState.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChainState> mapFromJson(dynamic json) {
    final map = <String, ChainState>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChainState.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChainState-objects as value to a dart map
  static Map<String, List<ChainState>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ChainState>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChainState.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'started',
    'markedDays',
    'streak',
    'markedToday',
    'broken',
    'canFreeze',
    'period',
    'periodDone',
  };
}
