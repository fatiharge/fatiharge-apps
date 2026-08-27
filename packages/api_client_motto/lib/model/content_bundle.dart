//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ContentBundle {
  /// Returns a new [ContentBundle] instance.
  ContentBundle({
    required this.version,
    this.archetypes = const [],
    this.mottos = const [],
    this.skeletons = const [],
    this.fragments = const [],
    this.connectors = const [],
  });

  String version;

  List<ArchetypeContent> archetypes;

  List<MottoContent> mottos;

  List<DailySkeleton> skeletons;

  List<Fragment> fragments;

  List<Connector> connectors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBundle &&
          other.version == version &&
          _deepEquality.equals(other.archetypes, archetypes) &&
          _deepEquality.equals(other.mottos, mottos) &&
          _deepEquality.equals(other.skeletons, skeletons) &&
          _deepEquality.equals(other.fragments, fragments) &&
          _deepEquality.equals(other.connectors, connectors);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (version.hashCode) +
      (archetypes.hashCode) +
      (mottos.hashCode) +
      (skeletons.hashCode) +
      (fragments.hashCode) +
      (connectors.hashCode);

  @override
  String toString() =>
      'ContentBundle[version=$version, archetypes=$archetypes, mottos=$mottos, skeletons=$skeletons, fragments=$fragments, connectors=$connectors]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'version'] = this.version;
    json[r'archetypes'] = this.archetypes;
    json[r'mottos'] = this.mottos;
    json[r'skeletons'] = this.skeletons;
    json[r'fragments'] = this.fragments;
    json[r'connectors'] = this.connectors;
    return json;
  }

  /// Returns a new [ContentBundle] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ContentBundle? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'version'),
            'Required key "ContentBundle[version]" is missing from JSON.');
        assert(json[r'version'] != null,
            'Required key "ContentBundle[version]" has a null value in JSON.');
        assert(json.containsKey(r'archetypes'),
            'Required key "ContentBundle[archetypes]" is missing from JSON.');
        assert(json[r'archetypes'] != null,
            'Required key "ContentBundle[archetypes]" has a null value in JSON.');
        assert(json.containsKey(r'mottos'),
            'Required key "ContentBundle[mottos]" is missing from JSON.');
        assert(json[r'mottos'] != null,
            'Required key "ContentBundle[mottos]" has a null value in JSON.');
        assert(json.containsKey(r'skeletons'),
            'Required key "ContentBundle[skeletons]" is missing from JSON.');
        assert(json[r'skeletons'] != null,
            'Required key "ContentBundle[skeletons]" has a null value in JSON.');
        assert(json.containsKey(r'fragments'),
            'Required key "ContentBundle[fragments]" is missing from JSON.');
        assert(json[r'fragments'] != null,
            'Required key "ContentBundle[fragments]" has a null value in JSON.');
        assert(json.containsKey(r'connectors'),
            'Required key "ContentBundle[connectors]" is missing from JSON.');
        assert(json[r'connectors'] != null,
            'Required key "ContentBundle[connectors]" has a null value in JSON.');
        return true;
      }());

      return ContentBundle(
        version: mapValueOfType<String>(json, r'version')!,
        archetypes: ArchetypeContent.listFromJson(json[r'archetypes']),
        mottos: MottoContent.listFromJson(json[r'mottos']),
        skeletons: DailySkeleton.listFromJson(json[r'skeletons']),
        fragments: Fragment.listFromJson(json[r'fragments']),
        connectors: Connector.listFromJson(json[r'connectors']),
      );
    }
    return null;
  }

  static List<ContentBundle> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ContentBundle>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ContentBundle.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ContentBundle> mapFromJson(dynamic json) {
    final map = <String, ContentBundle>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ContentBundle.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ContentBundle-objects as value to a dart map
  static Map<String, List<ContentBundle>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ContentBundle>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ContentBundle.listFromJson(
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
    'archetypes',
    'mottos',
    'skeletons',
    'fragments',
    'connectors',
  };
}
