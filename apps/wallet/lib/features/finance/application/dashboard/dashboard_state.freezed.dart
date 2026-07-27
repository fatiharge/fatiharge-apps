// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState()';
}


}

/// @nodoc
class $DashboardStateCopyWith<$Res>  {
$DashboardStateCopyWith(DashboardState _, $Res Function(DashboardState) __);
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DashboardLoading value)?  loading,TResult Function( DashboardReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading(_that);case DashboardReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DashboardLoading value)  loading,required TResult Function( DashboardReady value)  ready,}){
final _that = this;
switch (_that) {
case DashboardLoading():
return loading(_that);case DashboardReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DashboardLoading value)?  loading,TResult? Function( DashboardReady value)?  ready,}){
final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading(_that);case DashboardReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( MonthPeriod period,  Currency currency,  List<Currency> availableCurrencies,  MonthlySummary summary,  List<BudgetStatus> budgetStatuses,  Map<String, Category> categories)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading();case DashboardReady() when ready != null:
return ready(_that.period,_that.currency,_that.availableCurrencies,_that.summary,_that.budgetStatuses,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( MonthPeriod period,  Currency currency,  List<Currency> availableCurrencies,  MonthlySummary summary,  List<BudgetStatus> budgetStatuses,  Map<String, Category> categories)  ready,}) {final _that = this;
switch (_that) {
case DashboardLoading():
return loading();case DashboardReady():
return ready(_that.period,_that.currency,_that.availableCurrencies,_that.summary,_that.budgetStatuses,_that.categories);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( MonthPeriod period,  Currency currency,  List<Currency> availableCurrencies,  MonthlySummary summary,  List<BudgetStatus> budgetStatuses,  Map<String, Category> categories)?  ready,}) {final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading();case DashboardReady() when ready != null:
return ready(_that.period,_that.currency,_that.availableCurrencies,_that.summary,_that.budgetStatuses,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class DashboardLoading extends DashboardState {
  const DashboardLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.loading()';
}


}




/// @nodoc


class DashboardReady extends DashboardState {
  const DashboardReady({required this.period, required this.currency, required final  List<Currency> availableCurrencies, required this.summary, required final  List<BudgetStatus> budgetStatuses, required final  Map<String, Category> categories}): _availableCurrencies = availableCurrencies,_budgetStatuses = budgetStatuses,_categories = categories,super._();
  

 final  MonthPeriod period;
/// The currency being displayed. Totals are never mixed across currencies.
 final  Currency currency;
/// Currencies the user has actually recorded something in.
 final  List<Currency> _availableCurrencies;
/// Currencies the user has actually recorded something in.
 List<Currency> get availableCurrencies {
  if (_availableCurrencies is EqualUnmodifiableListView) return _availableCurrencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableCurrencies);
}

 final  MonthlySummary summary;
/// Most-at-risk budget first.
 final  List<BudgetStatus> _budgetStatuses;
/// Most-at-risk budget first.
 List<BudgetStatus> get budgetStatuses {
  if (_budgetStatuses is EqualUnmodifiableListView) return _budgetStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgetStatuses);
}

/// Category lookup by id, archived ones included.
 final  Map<String, Category> _categories;
/// Category lookup by id, archived ones included.
 Map<String, Category> get categories {
  if (_categories is EqualUnmodifiableMapView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categories);
}


/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardReadyCopyWith<DashboardReady> get copyWith => _$DashboardReadyCopyWithImpl<DashboardReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardReady&&(identical(other.period, period) || other.period == period)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._availableCurrencies, _availableCurrencies)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._budgetStatuses, _budgetStatuses)&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,period,currency,const DeepCollectionEquality().hash(_availableCurrencies),summary,const DeepCollectionEquality().hash(_budgetStatuses),const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'DashboardState.ready(period: $period, currency: $currency, availableCurrencies: $availableCurrencies, summary: $summary, budgetStatuses: $budgetStatuses, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $DashboardReadyCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardReadyCopyWith(DashboardReady value, $Res Function(DashboardReady) _then) = _$DashboardReadyCopyWithImpl;
@useResult
$Res call({
 MonthPeriod period, Currency currency, List<Currency> availableCurrencies, MonthlySummary summary, List<BudgetStatus> budgetStatuses, Map<String, Category> categories
});




}
/// @nodoc
class _$DashboardReadyCopyWithImpl<$Res>
    implements $DashboardReadyCopyWith<$Res> {
  _$DashboardReadyCopyWithImpl(this._self, this._then);

  final DashboardReady _self;
  final $Res Function(DashboardReady) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? period = null,Object? currency = null,Object? availableCurrencies = null,Object? summary = null,Object? budgetStatuses = null,Object? categories = null,}) {
  return _then(DashboardReady(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as MonthPeriod,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,availableCurrencies: null == availableCurrencies ? _self._availableCurrencies : availableCurrencies // ignore: cast_nullable_to_non_nullable
as List<Currency>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as MonthlySummary,budgetStatuses: null == budgetStatuses ? _self._budgetStatuses : budgetStatuses // ignore: cast_nullable_to_non_nullable
as List<BudgetStatus>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as Map<String, Category>,
  ));
}


}

// dart format on
