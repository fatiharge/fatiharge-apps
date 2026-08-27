//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Fragment {
  /// Returns a new [Fragment] instance.
  Fragment({
    required this.archetypeId,
    required this.index,
    required this.text,
  });

  String archetypeId;

  int index;

  String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fragment &&
          other.archetypeId == archetypeId &&
          other.index == index &&
          other.text == text;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (archetypeId.hashCode) + (index.hashCode) + (text.hashCode);

  @override
  String toString() =>
      'Fragment[archetypeId=$archetypeId, index=$index, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'archetypeId'] = this.archetypeId;
    json[r'index'] = this.index;
    json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [Fragment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Fragment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'archetypeId'),
            'Required key "Fragment[archetypeId]" is missing from JSON.');
        assert(json[r'archetypeId'] != null,
            'Required key "Fragment[archetypeId]" has a null value in JSON.');
        assert(json.containsKey(r'index'),
            'Required key "Fragment[index]" is missing from JSON.');
        assert(json[r'index'] != null,
            'Required key "Fragment[index]" has a null value in JSON.');
        assert(json.containsKey(r'text'),
            'Required key "Fragment[text]" is missing from JSON.');
        assert(json[r'text'] != null,
            'Required key "Fragment[text]" has a null value in JSON.');
        return true;
      }());

      return Fragment(
        archetypeId: mapValueOfType<String>(json, r'archetypeId')!,
        index: mapValueOfType<int>(json, r'index')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<Fragment> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Fragment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Fragment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Fragment> mapFromJson(dynamic json) {
    final map = <String, Fragment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Fragment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Fragment-objects as value to a dart map
  static Map<String, List<Fragment>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Fragment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Fragment.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'archetypeId',
    'index',
    'text',
  };
}
