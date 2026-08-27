//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EventEntry {
  /// Returns a new [EventEntry] instance.
  EventEntry({
    required this.clientId,
    required this.name,
    required this.occurredAt,
    this.properties = const {},
  });

  String clientId;

  String name;

  DateTime occurredAt;

  Map<String, String> properties;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntry &&
          other.clientId == clientId &&
          other.name == name &&
          other.occurredAt == occurredAt &&
          _deepEquality.equals(other.properties, properties);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (clientId.hashCode) +
      (name.hashCode) +
      (occurredAt.hashCode) +
      (properties.hashCode);

  @override
  String toString() =>
      'EventEntry[clientId=$clientId, name=$name, occurredAt=$occurredAt, properties=$properties]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'clientId'] = this.clientId;
    json[r'name'] = this.name;
    json[r'occurredAt'] = this.occurredAt.toUtc().toIso8601String();
    json[r'properties'] = this.properties;
    return json;
  }

  /// Returns a new [EventEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EventEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'clientId'),
            'Required key "EventEntry[clientId]" is missing from JSON.');
        assert(json[r'clientId'] != null,
            'Required key "EventEntry[clientId]" has a null value in JSON.');
        assert(json.containsKey(r'name'),
            'Required key "EventEntry[name]" is missing from JSON.');
        assert(json[r'name'] != null,
            'Required key "EventEntry[name]" has a null value in JSON.');
        assert(json.containsKey(r'occurredAt'),
            'Required key "EventEntry[occurredAt]" is missing from JSON.');
        assert(json[r'occurredAt'] != null,
            'Required key "EventEntry[occurredAt]" has a null value in JSON.');
        return true;
      }());

      return EventEntry(
        clientId: mapValueOfType<String>(json, r'clientId')!,
        name: mapValueOfType<String>(json, r'name')!,
        occurredAt: mapDateTime(json, r'occurredAt', r'')!,
        properties:
            mapCastOfType<String, String>(json, r'properties') ?? const {},
      );
    }
    return null;
  }

  static List<EventEntry> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <EventEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EventEntry> mapFromJson(dynamic json) {
    final map = <String, EventEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EventEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EventEntry-objects as value to a dart map
  static Map<String, List<EventEntry>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<EventEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EventEntry.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clientId',
    'name',
    'occurredAt',
  };
}
