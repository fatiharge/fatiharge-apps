//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

enum IdentityType {
  EMAIL._(r'EMAIL'),
  PHONE._(r'PHONE'),
  ;

  /// Instantiate a new enum with the provided value.
  const IdentityType._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [IdentityType] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static IdentityType? fromJson(dynamic value) =>
      IdentityTypeTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [IdentityType]
  /// that were successfully decoded from the passed [JSON][json].
  static List<IdentityType> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <IdentityType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IdentityType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [IdentityType] to String,
/// and [decode] dynamic data back to [IdentityType].
class IdentityTypeTypeTransformer {
  factory IdentityTypeTypeTransformer() =>
      _instance ??= const IdentityTypeTypeTransformer._();

  const IdentityTypeTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(IdentityType data) => data._value;

  /// Returns the instance of [IdentityType] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  IdentityType? decode(dynamic data, {bool allowNull = true}) {
    if (data is IdentityType) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EMAIL':
          return IdentityType.EMAIL;
        case r'PHONE':
          return IdentityType.PHONE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static IdentityTypeTypeTransformer? _instance;
}
