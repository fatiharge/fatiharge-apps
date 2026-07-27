// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntryState {

 TransactionType get type; Currency get currency; DateTime get date;/// Set when editing an existing transaction; `null` when adding a new one.
 String? get editingId; String get amountText; String? get categoryId; String get note;/// Selectable categories (archived ones excluded).
 List<Category> get categories; bool get submitting; bool get saved;/// Errors stay hidden until the first submit attempt.
 bool get showErrors;
/// Create a copy of EntryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryStateCopyWith<EntryState> get copyWith => _$EntryStateCopyWithImpl<EntryState>(this as EntryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryState&&(identical(other.type, type) || other.type == type)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.date, date) || other.date == date)&&(identical(other.editingId, editingId) || other.editingId == editingId)&&(identical(other.amountText, amountText) || other.amountText == amountText)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors));
}


@override
int get hashCode => Object.hash(runtimeType,type,currency,date,editingId,amountText,categoryId,note,const DeepCollectionEquality().hash(categories),submitting,saved,showErrors);

@override
String toString() {
  return 'EntryState(type: $type, currency: $currency, date: $date, editingId: $editingId, amountText: $amountText, categoryId: $categoryId, note: $note, categories: $categories, submitting: $submitting, saved: $saved, showErrors: $showErrors)';
}


}

/// @nodoc
abstract mixin class $EntryStateCopyWith<$Res>  {
  factory $EntryStateCopyWith(EntryState value, $Res Function(EntryState) _then) = _$EntryStateCopyWithImpl;
@useResult
$Res call({
 TransactionType type, Currency currency, DateTime date, String? editingId, String amountText, String? categoryId, String note, List<Category> categories, bool submitting, bool saved, bool showErrors
});




}
/// @nodoc
class _$EntryStateCopyWithImpl<$Res>
    implements $EntryStateCopyWith<$Res> {
  _$EntryStateCopyWithImpl(this._self, this._then);

  final EntryState _self;
  final $Res Function(EntryState) _then;

/// Create a copy of EntryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? currency = null,Object? date = null,Object? editingId = freezed,Object? amountText = null,Object? categoryId = freezed,Object? note = null,Object? categories = null,Object? submitting = null,Object? saved = null,Object? showErrors = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,editingId: freezed == editingId ? _self.editingId : editingId // ignore: cast_nullable_to_non_nullable
as String?,amountText: null == amountText ? _self.amountText : amountText // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EntryState].
extension EntryStatePatterns on EntryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryState value)  $default,){
final _that = this;
switch (_that) {
case _EntryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryState value)?  $default,){
final _that = this;
switch (_that) {
case _EntryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransactionType type,  Currency currency,  DateTime date,  String? editingId,  String amountText,  String? categoryId,  String note,  List<Category> categories,  bool submitting,  bool saved,  bool showErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryState() when $default != null:
return $default(_that.type,_that.currency,_that.date,_that.editingId,_that.amountText,_that.categoryId,_that.note,_that.categories,_that.submitting,_that.saved,_that.showErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransactionType type,  Currency currency,  DateTime date,  String? editingId,  String amountText,  String? categoryId,  String note,  List<Category> categories,  bool submitting,  bool saved,  bool showErrors)  $default,) {final _that = this;
switch (_that) {
case _EntryState():
return $default(_that.type,_that.currency,_that.date,_that.editingId,_that.amountText,_that.categoryId,_that.note,_that.categories,_that.submitting,_that.saved,_that.showErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransactionType type,  Currency currency,  DateTime date,  String? editingId,  String amountText,  String? categoryId,  String note,  List<Category> categories,  bool submitting,  bool saved,  bool showErrors)?  $default,) {final _that = this;
switch (_that) {
case _EntryState() when $default != null:
return $default(_that.type,_that.currency,_that.date,_that.editingId,_that.amountText,_that.categoryId,_that.note,_that.categories,_that.submitting,_that.saved,_that.showErrors);case _:
  return null;

}
}

}

/// @nodoc


class _EntryState extends EntryState {
  const _EntryState({required this.type, required this.currency, required this.date, this.editingId, this.amountText = '', this.categoryId, this.note = '', final  List<Category> categories = const <Category>[], this.submitting = false, this.saved = false, this.showErrors = false}): _categories = categories,super._();
  

@override final  TransactionType type;
@override final  Currency currency;
@override final  DateTime date;
/// Set when editing an existing transaction; `null` when adding a new one.
@override final  String? editingId;
@override@JsonKey() final  String amountText;
@override final  String? categoryId;
@override@JsonKey() final  String note;
/// Selectable categories (archived ones excluded).
 final  List<Category> _categories;
/// Selectable categories (archived ones excluded).
@override@JsonKey() List<Category> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
/// Errors stay hidden until the first submit attempt.
@override@JsonKey() final  bool showErrors;

/// Create a copy of EntryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryStateCopyWith<_EntryState> get copyWith => __$EntryStateCopyWithImpl<_EntryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryState&&(identical(other.type, type) || other.type == type)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.date, date) || other.date == date)&&(identical(other.editingId, editingId) || other.editingId == editingId)&&(identical(other.amountText, amountText) || other.amountText == amountText)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors));
}


@override
int get hashCode => Object.hash(runtimeType,type,currency,date,editingId,amountText,categoryId,note,const DeepCollectionEquality().hash(_categories),submitting,saved,showErrors);

@override
String toString() {
  return 'EntryState(type: $type, currency: $currency, date: $date, editingId: $editingId, amountText: $amountText, categoryId: $categoryId, note: $note, categories: $categories, submitting: $submitting, saved: $saved, showErrors: $showErrors)';
}


}

/// @nodoc
abstract mixin class _$EntryStateCopyWith<$Res> implements $EntryStateCopyWith<$Res> {
  factory _$EntryStateCopyWith(_EntryState value, $Res Function(_EntryState) _then) = __$EntryStateCopyWithImpl;
@override @useResult
$Res call({
 TransactionType type, Currency currency, DateTime date, String? editingId, String amountText, String? categoryId, String note, List<Category> categories, bool submitting, bool saved, bool showErrors
});




}
/// @nodoc
class __$EntryStateCopyWithImpl<$Res>
    implements _$EntryStateCopyWith<$Res> {
  __$EntryStateCopyWithImpl(this._self, this._then);

  final _EntryState _self;
  final $Res Function(_EntryState) _then;

/// Create a copy of EntryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? currency = null,Object? date = null,Object? editingId = freezed,Object? amountText = null,Object? categoryId = freezed,Object? note = null,Object? categories = null,Object? submitting = null,Object? saved = null,Object? showErrors = null,}) {
  return _then(_EntryState(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,editingId: freezed == editingId ? _self.editingId : editingId // ignore: cast_nullable_to_non_nullable
as String?,amountText: null == amountText ? _self.amountText : amountText // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
