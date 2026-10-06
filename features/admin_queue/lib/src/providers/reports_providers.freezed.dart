// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reports_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReportsViewState {

/// Rows loaded so far, oldest report first.
 List<AdminReportEntry> get entries;/// Tab counts for every status the queue shows.
///
/// Authoritative from the server on each response, so the badges stay fresh
/// across pages without a second round trip.
 ReportCounts get counts;/// Cursor for the next page, or null once exhausted.
 ReportCursor? get cursor;/// Whether a further page is in flight.
///
/// Separate from the provider's loading state so a scroll can show a footer
/// spinner while existing rows stay on screen.
 bool get isLoadingMore;/// Failure from the most recent load, if any.
 AppException? get loadError;
/// Create a copy of ReportsViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportsViewStateCopyWith<ReportsViewState> get copyWith => _$ReportsViewStateCopyWithImpl<ReportsViewState>(this as ReportsViewState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReportsViewState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportsViewState&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.counts, _this.counts) || other.counts == _this.counts)&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.loadError, _this.loadError) || other.loadError == _this.loadError));
}


@override
int get hashCode {
  final _this = this as ReportsViewState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.entries),_this.counts,_this.cursor,_this.isLoadingMore,_this.loadError);
}

@override
String toString() {
  final _this = this as ReportsViewState;
  return 'ReportsViewState(entries: ${_this.entries}, counts: ${_this.counts}, cursor: ${_this.cursor}, isLoadingMore: ${_this.isLoadingMore}, loadError: ${_this.loadError})';
}


}

/// @nodoc
abstract mixin class $ReportsViewStateCopyWith<$Res>  {
  factory $ReportsViewStateCopyWith(ReportsViewState value, $Res Function(ReportsViewState) _then) = _$ReportsViewStateCopyWithImpl;
@useResult
$Res call({
 List<AdminReportEntry> entries, ReportCounts counts, ReportCursor? cursor, bool isLoadingMore, AppException? loadError
});


$ReportCountsCopyWith<$Res> get counts;

}
/// @nodoc
class _$ReportsViewStateCopyWithImpl<$Res>
    implements $ReportsViewStateCopyWith<$Res> {
  _$ReportsViewStateCopyWithImpl(this._self, this._then);

  final ReportsViewState _self;
  final $Res Function(ReportsViewState) _then;

/// Create a copy of ReportsViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? counts = null,Object? cursor = freezed,Object? isLoadingMore = null,Object? loadError = freezed,}) {
  return _then(ReportsViewState(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<AdminReportEntry>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as ReportCounts,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as ReportCursor?,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as AppException?,
  ));
}
/// Create a copy of ReportsViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportCountsCopyWith<$Res> get counts {
  
  return $ReportCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportsViewState].
extension ReportsViewStatePatterns on ReportsViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportsViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportsViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportsViewState value)  $default,){
final _that = this;
switch (_that) {
case _ReportsViewState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportsViewState value)?  $default,){
final _that = this;
switch (_that) {
case _ReportsViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AdminReportEntry> entries,  ReportCounts counts,  ReportCursor? cursor,  bool isLoadingMore,  AppException? loadError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportsViewState() when $default != null:
return $default(_that.entries,_that.counts,_that.cursor,_that.isLoadingMore,_that.loadError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AdminReportEntry> entries,  ReportCounts counts,  ReportCursor? cursor,  bool isLoadingMore,  AppException? loadError)  $default,) {final _that = this;
switch (_that) {
case _ReportsViewState():
return $default(_that.entries,_that.counts,_that.cursor,_that.isLoadingMore,_that.loadError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AdminReportEntry> entries,  ReportCounts counts,  ReportCursor? cursor,  bool isLoadingMore,  AppException? loadError)?  $default,) {final _that = this;
switch (_that) {
case _ReportsViewState() when $default != null:
return $default(_that.entries,_that.counts,_that.cursor,_that.isLoadingMore,_that.loadError);case _:
  return null;

}
}

}

/// @nodoc


class _ReportsViewState implements ReportsViewState {
  const _ReportsViewState({ List<AdminReportEntry> entries = const <AdminReportEntry>[], this.counts = const ReportCounts(), this.cursor, this.isLoadingMore = false, this.loadError}): _entries = entries;
  

/// Rows loaded so far, oldest report first.
 final  List<AdminReportEntry> _entries;
/// Rows loaded so far, oldest report first.
@override@JsonKey() List<AdminReportEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// Tab counts for every status the queue shows.
///
/// Authoritative from the server on each response, so the badges stay fresh
/// across pages without a second round trip.
@override@JsonKey() final  ReportCounts counts;
/// Cursor for the next page, or null once exhausted.
@override final  ReportCursor? cursor;
/// Whether a further page is in flight.
///
/// Separate from the provider's loading state so a scroll can show a footer
/// spinner while existing rows stay on screen.
@override@JsonKey() final  bool isLoadingMore;
/// Failure from the most recent load, if any.
@override final  AppException? loadError;

/// Create a copy of ReportsViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportsViewStateCopyWith<_ReportsViewState> get copyWith => __$ReportsViewStateCopyWithImpl<_ReportsViewState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportsViewState&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadError, loadError) || other.loadError == loadError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),counts,cursor,isLoadingMore,loadError);
}

@override
String toString() {
    return 'ReportsViewState(entries: $entries, counts: $counts, cursor: $cursor, isLoadingMore: $isLoadingMore, loadError: $loadError)';
}


}

/// @nodoc
abstract mixin class _$ReportsViewStateCopyWith<$Res> implements $ReportsViewStateCopyWith<$Res> {
  factory _$ReportsViewStateCopyWith(_ReportsViewState value, $Res Function(_ReportsViewState) _then) = __$ReportsViewStateCopyWithImpl;
@override @useResult
$Res call({
 List<AdminReportEntry> entries, ReportCounts counts, ReportCursor? cursor, bool isLoadingMore, AppException? loadError
});


@override $ReportCountsCopyWith<$Res> get counts;

}
/// @nodoc
class __$ReportsViewStateCopyWithImpl<$Res>
    implements _$ReportsViewStateCopyWith<$Res> {
  __$ReportsViewStateCopyWithImpl(this._self, this._then);

  final _ReportsViewState _self;
  final $Res Function(_ReportsViewState) _then;

/// Create a copy of ReportsViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? counts = null,Object? cursor = freezed,Object? isLoadingMore = null,Object? loadError = freezed,}) {
  return _then(_ReportsViewState(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<AdminReportEntry>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as ReportCounts,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as ReportCursor?,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as AppException?,
  ));
}

/// Create a copy of ReportsViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportCountsCopyWith<$Res> get counts {
  
  return $ReportCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}

// dart format on
