//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeletionResponse {
  /// Returns a new [DeletionResponse] instance.
  DeletionResponse({
    this.deleted = const [],
    this.kept = const [],
  });

  List<String> deleted;

  List<String> kept;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletionResponse &&
          _deepEquality.equals(other.deleted, deleted) &&
          _deepEquality.equals(other.kept, kept);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (deleted.hashCode) + (kept.hashCode);

  @override
  String toString() => 'DeletionResponse[deleted=$deleted, kept=$kept]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'deleted'] = this.deleted;
    json[r'kept'] = this.kept;
    return json;
  }

  /// Returns a new [DeletionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeletionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deleted'),
            'Required key "DeletionResponse[deleted]" is missing from JSON.');
        assert(json[r'deleted'] != null,
            'Required key "DeletionResponse[deleted]" has a null value in JSON.');
        assert(json.containsKey(r'kept'),
            'Required key "DeletionResponse[kept]" is missing from JSON.');
        assert(json[r'kept'] != null,
            'Required key "DeletionResponse[kept]" has a null value in JSON.');
        return true;
      }());

      return DeletionResponse(
        deleted: json[r'deleted'] is Iterable
            ? (json[r'deleted'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        kept: json[r'kept'] is Iterable
            ? (json[r'kept'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<DeletionResponse> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DeletionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeletionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeletionResponse> mapFromJson(dynamic json) {
    final map = <String, DeletionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeletionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeletionResponse-objects as value to a dart map
  static Map<String, List<DeletionResponse>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DeletionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeletionResponse.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deleted',
    'kept',
  };
}
