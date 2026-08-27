//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

enum FeedbackKind {
  BUG._(r'BUG'),
  SUGGESTION._(r'SUGGESTION'),
  CONTENT._(r'CONTENT'),
  ARCHETYPE_REJECTED._(r'ARCHETYPE_REJECTED'),
  OTHER._(r'OTHER'),
  ;

  /// Instantiate a new enum with the provided value.
  const FeedbackKind._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [FeedbackKind] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static FeedbackKind? fromJson(dynamic value) =>
      FeedbackKindTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [FeedbackKind]
  /// that were successfully decoded from the passed [JSON][json].
  static List<FeedbackKind> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <FeedbackKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FeedbackKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [FeedbackKind] to String,
/// and [decode] dynamic data back to [FeedbackKind].
class FeedbackKindTypeTransformer {
  factory FeedbackKindTypeTransformer() =>
      _instance ??= const FeedbackKindTypeTransformer._();

  const FeedbackKindTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(FeedbackKind data) => data._value;

  /// Returns the instance of [FeedbackKind] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  FeedbackKind? decode(dynamic data, {bool allowNull = true}) {
    if (data is FeedbackKind) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'BUG':
          return FeedbackKind.BUG;
        case r'SUGGESTION':
          return FeedbackKind.SUGGESTION;
        case r'CONTENT':
          return FeedbackKind.CONTENT;
        case r'ARCHETYPE_REJECTED':
          return FeedbackKind.ARCHETYPE_REJECTED;
        case r'OTHER':
          return FeedbackKind.OTHER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static FeedbackKindTypeTransformer? _instance;
}
