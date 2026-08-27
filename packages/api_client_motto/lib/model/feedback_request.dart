//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FeedbackRequest {
  /// Returns a new [FeedbackRequest] instance.
  FeedbackRequest({
    required this.kind,
    required this.message,
    this.email,
    this.context = const {},
  });

  FeedbackKind kind;

  String message;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? email;

  Map<String, String> context;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackRequest &&
          other.kind == kind &&
          other.message == message &&
          other.email == email &&
          _deepEquality.equals(other.context, context);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (kind.hashCode) +
      (message.hashCode) +
      (email == null ? 0 : email!.hashCode) +
      (context.hashCode);

  @override
  String toString() =>
      'FeedbackRequest[kind=$kind, message=$message, email=$email, context=$context]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'kind'] = this.kind;
    json[r'message'] = this.message;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    json[r'context'] = this.context;
    return json;
  }

  /// Returns a new [FeedbackRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FeedbackRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'),
            'Required key "FeedbackRequest[kind]" is missing from JSON.');
        assert(json[r'kind'] != null,
            'Required key "FeedbackRequest[kind]" has a null value in JSON.');
        assert(json.containsKey(r'message'),
            'Required key "FeedbackRequest[message]" is missing from JSON.');
        assert(json[r'message'] != null,
            'Required key "FeedbackRequest[message]" has a null value in JSON.');
        return true;
      }());

      return FeedbackRequest(
        kind: FeedbackKind.fromJson(json[r'kind'])!,
        message: mapValueOfType<String>(json, r'message')!,
        email: mapValueOfType<String>(json, r'email'),
        context: mapCastOfType<String, String>(json, r'context') ?? const {},
      );
    }
    return null;
  }

  static List<FeedbackRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <FeedbackRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FeedbackRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FeedbackRequest> mapFromJson(dynamic json) {
    final map = <String, FeedbackRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FeedbackRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FeedbackRequest-objects as value to a dart map
  static Map<String, List<FeedbackRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<FeedbackRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FeedbackRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'message',
  };
}
