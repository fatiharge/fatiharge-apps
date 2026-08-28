//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SupportCopy {
  /// Returns a new [SupportCopy] instance.
  SupportCopy({
    required this.version,
    this.privacy = const [],
    required this.deletion,
    this.faq = const [],
    required this.privacyPolicyUrl,
  });

  String version;

  List<String> privacy;

  DeletionCopy deletion;

  List<FaqEntry> faq;

  String privacyPolicyUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportCopy &&
          other.version == version &&
          _deepEquality.equals(other.privacy, privacy) &&
          other.deletion == deletion &&
          _deepEquality.equals(other.faq, faq) &&
          other.privacyPolicyUrl == privacyPolicyUrl;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (version.hashCode) +
      (privacy.hashCode) +
      (deletion.hashCode) +
      (faq.hashCode) +
      (privacyPolicyUrl.hashCode);

  @override
  String toString() =>
      'SupportCopy[version=$version, privacy=$privacy, deletion=$deletion, faq=$faq, privacyPolicyUrl=$privacyPolicyUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'version'] = this.version;
    json[r'privacy'] = this.privacy;
    json[r'deletion'] = this.deletion;
    json[r'faq'] = this.faq;
    json[r'privacyPolicyUrl'] = this.privacyPolicyUrl;
    return json;
  }

  /// Returns a new [SupportCopy] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SupportCopy? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'version'),
            'Required key "SupportCopy[version]" is missing from JSON.');
        assert(json[r'version'] != null,
            'Required key "SupportCopy[version]" has a null value in JSON.');
        assert(json.containsKey(r'privacy'),
            'Required key "SupportCopy[privacy]" is missing from JSON.');
        assert(json[r'privacy'] != null,
            'Required key "SupportCopy[privacy]" has a null value in JSON.');
        assert(json.containsKey(r'deletion'),
            'Required key "SupportCopy[deletion]" is missing from JSON.');
        assert(json[r'deletion'] != null,
            'Required key "SupportCopy[deletion]" has a null value in JSON.');
        assert(json.containsKey(r'faq'),
            'Required key "SupportCopy[faq]" is missing from JSON.');
        assert(json[r'faq'] != null,
            'Required key "SupportCopy[faq]" has a null value in JSON.');
        assert(json.containsKey(r'privacyPolicyUrl'),
            'Required key "SupportCopy[privacyPolicyUrl]" is missing from JSON.');
        assert(json[r'privacyPolicyUrl'] != null,
            'Required key "SupportCopy[privacyPolicyUrl]" has a null value in JSON.');
        return true;
      }());

      return SupportCopy(
        version: mapValueOfType<String>(json, r'version')!,
        privacy: json[r'privacy'] is Iterable
            ? (json[r'privacy'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        deletion: DeletionCopy.fromJson(json[r'deletion'])!,
        faq: FaqEntry.listFromJson(json[r'faq']),
        privacyPolicyUrl: mapValueOfType<String>(json, r'privacyPolicyUrl')!,
      );
    }
    return null;
  }

  static List<SupportCopy> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <SupportCopy>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SupportCopy.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SupportCopy> mapFromJson(dynamic json) {
    final map = <String, SupportCopy>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SupportCopy.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SupportCopy-objects as value to a dart map
  static Map<String, List<SupportCopy>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<SupportCopy>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SupportCopy.listFromJson(
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
    'privacy',
    'deletion',
    'faq',
    'privacyPolicyUrl',
  };
}
