//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EffectCatalogue {
  /// Returns a new [EffectCatalogue] instance.
  EffectCatalogue({
    required this.version,
    this.codes = const [],
  });

  String version;

  List<CodeEffects> codes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EffectCatalogue &&
          other.version == version &&
          _deepEquality.equals(other.codes, codes);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (version.hashCode) + (codes.hashCode);

  @override
  String toString() => 'EffectCatalogue[version=$version, codes=$codes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'version'] = this.version;
    json[r'codes'] = this.codes;
    return json;
  }

  /// Returns a new [EffectCatalogue] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EffectCatalogue? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'version'),
            'Required key "EffectCatalogue[version]" is missing from JSON.');
        assert(json[r'version'] != null,
            'Required key "EffectCatalogue[version]" has a null value in JSON.');
        assert(json.containsKey(r'codes'),
            'Required key "EffectCatalogue[codes]" is missing from JSON.');
        assert(json[r'codes'] != null,
            'Required key "EffectCatalogue[codes]" has a null value in JSON.');
        return true;
      }());

      return EffectCatalogue(
        version: mapValueOfType<String>(json, r'version')!,
        codes: CodeEffects.listFromJson(json[r'codes']),
      );
    }
    return null;
  }

  static List<EffectCatalogue> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <EffectCatalogue>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EffectCatalogue.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EffectCatalogue> mapFromJson(dynamic json) {
    final map = <String, EffectCatalogue>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EffectCatalogue.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EffectCatalogue-objects as value to a dart map
  static Map<String, List<EffectCatalogue>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<EffectCatalogue>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EffectCatalogue.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'version',
    'codes',
  };
}
