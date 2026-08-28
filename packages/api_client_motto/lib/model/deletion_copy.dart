//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeletionCopy {
  /// Returns a new [DeletionCopy] instance.
  DeletionCopy({
    this.goes = const [],
    this.stays = const [],
    required this.counterReason,
    required this.answersNote,
  });

  List<String> goes;

  List<String> stays;

  String counterReason;

  String answersNote;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletionCopy &&
          _deepEquality.equals(other.goes, goes) &&
          _deepEquality.equals(other.stays, stays) &&
          other.counterReason == counterReason &&
          other.answersNote == answersNote;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (goes.hashCode) +
      (stays.hashCode) +
      (counterReason.hashCode) +
      (answersNote.hashCode);

  @override
  String toString() =>
      'DeletionCopy[goes=$goes, stays=$stays, counterReason=$counterReason, answersNote=$answersNote]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'goes'] = this.goes;
    json[r'stays'] = this.stays;
    json[r'counterReason'] = this.counterReason;
    json[r'answersNote'] = this.answersNote;
    return json;
  }

  /// Returns a new [DeletionCopy] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeletionCopy? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'goes'),
            'Required key "DeletionCopy[goes]" is missing from JSON.');
        assert(json[r'goes'] != null,
            'Required key "DeletionCopy[goes]" has a null value in JSON.');
        assert(json.containsKey(r'stays'),
            'Required key "DeletionCopy[stays]" is missing from JSON.');
        assert(json[r'stays'] != null,
            'Required key "DeletionCopy[stays]" has a null value in JSON.');
        assert(json.containsKey(r'counterReason'),
            'Required key "DeletionCopy[counterReason]" is missing from JSON.');
        assert(json[r'counterReason'] != null,
            'Required key "DeletionCopy[counterReason]" has a null value in JSON.');
        assert(json.containsKey(r'answersNote'),
            'Required key "DeletionCopy[answersNote]" is missing from JSON.');
        assert(json[r'answersNote'] != null,
            'Required key "DeletionCopy[answersNote]" has a null value in JSON.');
        return true;
      }());

      return DeletionCopy(
        goes: json[r'goes'] is Iterable
            ? (json[r'goes'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        stays: json[r'stays'] is Iterable
            ? (json[r'stays'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        counterReason: mapValueOfType<String>(json, r'counterReason')!,
        answersNote: mapValueOfType<String>(json, r'answersNote')!,
      );
    }
    return null;
  }

  static List<DeletionCopy> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DeletionCopy>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeletionCopy.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeletionCopy> mapFromJson(dynamic json) {
    final map = <String, DeletionCopy>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeletionCopy.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeletionCopy-objects as value to a dart map
  static Map<String, List<DeletionCopy>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DeletionCopy>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeletionCopy.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'goes',
    'stays',
    'counterReason',
    'answersNote',
  };
}
