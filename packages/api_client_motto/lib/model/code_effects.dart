//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CodeEffects {
  /// Returns a new [CodeEffects] instance.
  CodeEffects({
    required this.code,
    required this.definition,
  });

  String code;

  String definition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeEffects &&
          other.code == code &&
          other.definition == definition;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (code.hashCode) + (definition.hashCode);

  @override
  String toString() => 'CodeEffects[code=$code, definition=$definition]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'code'] = this.code;
    json[r'definition'] = this.definition;
    return json;
  }

  /// Returns a new [CodeEffects] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CodeEffects? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'code'),
            'Required key "CodeEffects[code]" is missing from JSON.');
        assert(json[r'code'] != null,
            'Required key "CodeEffects[code]" has a null value in JSON.');
        assert(json.containsKey(r'definition'),
            'Required key "CodeEffects[definition]" is missing from JSON.');
        assert(json[r'definition'] != null,
            'Required key "CodeEffects[definition]" has a null value in JSON.');
        return true;
      }());

      return CodeEffects(
        code: mapValueOfType<String>(json, r'code')!,
        definition: mapValueOfType<String>(json, r'definition')!,
      );
    }
    return null;
  }

  static List<CodeEffects> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CodeEffects>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CodeEffects.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CodeEffects> mapFromJson(dynamic json) {
    final map = <String, CodeEffects>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CodeEffects.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CodeEffects-objects as value to a dart map
  static Map<String, List<CodeEffects>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CodeEffects>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CodeEffects.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'definition',
  };
}
