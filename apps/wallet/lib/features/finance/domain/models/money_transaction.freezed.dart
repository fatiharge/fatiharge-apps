// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'money_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MoneyTransaction {

 String get id; TransactionType get type; String get categoryId; Money get amount; DateTime get date; String? get note;
/// Create a copy of MoneyTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoneyTransactionCopyWith<MoneyTransaction> get copyWith => _$MoneyTransactionCopyWithImpl<MoneyTransaction>(this as MoneyTransaction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoneyTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,categoryId,amount,date,note);

@override
String toString() {
  return 'MoneyTransaction(id: $id, type: $type, categoryId: $categoryId, amount: $amount, date: $date, note: $note)';
}


}

/// @nodoc
abstract mixin class $MoneyTransactionCopyWith<$Res>  {
  factory $MoneyTransactionCopyWith(MoneyTransaction value, $Res Function(MoneyTransaction) _then) = _$MoneyTransactionCopyWithImpl;
@useResult
$Res call({
 String id, TransactionType type, String categoryId, Money amount, DateTime date, String? note
});




}
/// @nodoc
class _$MoneyTransactionCopyWithImpl<$Res>
    implements $MoneyTransactionCopyWith<$Res> {
  _$MoneyTransactionCopyWithImpl(this._self, this._then);

  final MoneyTransaction _self;
  final $Res Function(MoneyTransaction) _then;

/// Create a copy of MoneyTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? categoryId = null,Object? amount = null,Object? date = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MoneyTransaction].
extension MoneyTransactionPatterns on MoneyTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoneyTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoneyTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoneyTransaction value)  $default,){
final _that = this;
switch (_that) {
case _MoneyTransaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoneyTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _MoneyTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TransactionType type,  String categoryId,  Money amount,  DateTime date,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoneyTransaction() when $default != null:
return $default(_that.id,_that.type,_that.categoryId,_that.amount,_that.date,_that.note);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TransactionType type,  String categoryId,  Money amount,  DateTime date,  String? note)  $default,) {final _that = this;
switch (_that) {
case _MoneyTransaction():
return $default(_that.id,_that.type,_that.categoryId,_that.amount,_that.date,_that.note);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TransactionType type,  String categoryId,  Money amount,  DateTime date,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _MoneyTransaction() when $default != null:
return $default(_that.id,_that.type,_that.categoryId,_that.amount,_that.date,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _MoneyTransaction extends MoneyTransaction {
  const _MoneyTransaction({required this.id, required this.type, required this.categoryId, required this.amount, required this.date, this.note}): super._();
  

@override final  String id;
@override final  TransactionType type;
@override final  String categoryId;
@override final  Money amount;
@override final  DateTime date;
@override final  String? note;

/// Create a copy of MoneyTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoneyTransactionCopyWith<_MoneyTransaction> get copyWith => __$MoneyTransactionCopyWithImpl<_MoneyTransaction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoneyTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,categoryId,amount,date,note);

@override
String toString() {
  return 'MoneyTransaction(id: $id, type: $type, categoryId: $categoryId, amount: $amount, date: $date, note: $note)';
}


}

/// @nodoc
abstract mixin class _$MoneyTransactionCopyWith<$Res> implements $MoneyTransactionCopyWith<$Res> {
  factory _$MoneyTransactionCopyWith(_MoneyTransaction value, $Res Function(_MoneyTransaction) _then) = __$MoneyTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, TransactionType type, String categoryId, Money amount, DateTime date, String? note
});




}
/// @nodoc
class __$MoneyTransactionCopyWithImpl<$Res>
    implements _$MoneyTransactionCopyWith<$Res> {
  __$MoneyTransactionCopyWithImpl(this._self, this._then);

  final _MoneyTransaction _self;
  final $Res Function(_MoneyTransaction) _then;

/// Create a copy of MoneyTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? categoryId = null,Object? amount = null,Object? date = null,Object? note = freezed,}) {
  return _then(_MoneyTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
