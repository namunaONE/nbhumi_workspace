// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_queue_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QueueViewState {

/// Rows loaded so far, oldest submission first.
///
/// The queue's work order: a listing that has waited longest is first,
/// because that is what makes the 48h SLA meaningful rather than
/// decorative.
 List<AdminQueueEntry> get entries;/// Tab counts for every status the queue shows.
///
/// Authoritative from the server on every response, so they stay fresh
/// across pages without a second round trip.
 QueueCounts get counts;/// Cursor for the next page, or null once exhausted.
 QueueCursor? get cursor;/// Fraud-warning counts by listing id (HYA-303).
///
/// Fetched after each page via the batch counts RPC, keyed by the ids on
/// screen. Missing keys read as 0 through [QueueViewStateX.warningsFor]:
/// a listing actioned between the page load and the counts call simply
/// shows no flag rather than failing the page.
 Map<String, int> get warningCounts;/// Whether a further page is in flight.
///
/// Separate from the provider's loading state so a scroll can show a footer
/// spinner while existing rows stay on screen.
 bool get isLoadingMore;/// Failure from the most recent load, if any.
 AppException? get loadError;
/// Create a copy of QueueViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueViewStateCopyWith<QueueViewState> get copyWith => _$QueueViewStateCopyWithImpl<QueueViewState>(this as QueueViewState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QueueViewState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueViewState&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.counts, _this.counts) || other.counts == _this.counts)&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor)&&const DeepCollectionEquality().equals(other.warningCounts, _this.warningCounts)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.loadError, _this.loadError) || other.loadError == _this.loadError));
}


@override
int get hashCode {
  final _this = this as QueueViewState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.entries),_this.counts,_this.cursor,const DeepCollectionEquality().hash(_this.warningCounts),_this.isLoadingMore,_this.loadError);
}

@override
String toString() {
  final _this = this as QueueViewState;
  return 'QueueViewState(entries: ${_this.entries}, counts: ${_this.counts}, cursor: ${_this.cursor}, warningCounts: ${_this.warningCounts}, isLoadingMore: ${_this.isLoadingMore}, loadError: ${_this.loadError})';
}


}

/// @nodoc
abstract mixin class $QueueViewStateCopyWith<$Res>  {
  factory $QueueViewStateCopyWith(QueueViewState value, $Res Function(QueueViewState) _then) = _$QueueViewStateCopyWithImpl;
@useResult
$Res call({
 List<AdminQueueEntry> entries, QueueCounts counts, QueueCursor? cursor, Map<String, int> warningCounts, bool isLoadingMore, AppException? loadError
});


$QueueCountsCopyWith<$Res> get counts;

}
/// @nodoc
class _$QueueViewStateCopyWithImpl<$Res>
    implements $QueueViewStateCopyWith<$Res> {
  _$QueueViewStateCopyWithImpl(this._self, this._then);

  final QueueViewState _self;
  final $Res Function(QueueViewState) _then;

/// Create a copy of QueueViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? counts = null,Object? cursor = freezed,Object? warningCounts = null,Object? isLoadingMore = null,Object? loadError = freezed,}) {
  return _then(QueueViewState(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<AdminQueueEntry>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as QueueCounts,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as QueueCursor?,warningCounts: null == warningCounts ? _self.warningCounts : warningCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as AppException?,
  ));
}
/// Create a copy of QueueViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<$Res> get counts {
  
  return $QueueCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [QueueViewState].
extension QueueViewStatePatterns on QueueViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueViewState value)  $default,){
final _that = this;
switch (_that) {
case _QueueViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueViewState value)?  $default,){
final _that = this;
switch (_that) {
case _QueueViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AdminQueueEntry> entries,  QueueCounts counts,  QueueCursor? cursor,  Map<String, int> warningCounts,  bool isLoadingMore,  AppException? loadError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueViewState() when $default != null:
return $default(_that.entries,_that.counts,_that.cursor,_that.warningCounts,_that.isLoadingMore,_that.loadError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AdminQueueEntry> entries,  QueueCounts counts,  QueueCursor? cursor,  Map<String, int> warningCounts,  bool isLoadingMore,  AppException? loadError)  $default,) {final _that = this;
switch (_that) {
case _QueueViewState():
return $default(_that.entries,_that.counts,_that.cursor,_that.warningCounts,_that.isLoadingMore,_that.loadError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AdminQueueEntry> entries,  QueueCounts counts,  QueueCursor? cursor,  Map<String, int> warningCounts,  bool isLoadingMore,  AppException? loadError)?  $default,) {final _that = this;
switch (_that) {
case _QueueViewState() when $default != null:
return $default(_that.entries,_that.counts,_that.cursor,_that.warningCounts,_that.isLoadingMore,_that.loadError);case _:
  return null;

}
}

}

/// @nodoc


class _QueueViewState implements QueueViewState {
  const _QueueViewState({ List<AdminQueueEntry> entries = const <AdminQueueEntry>[], this.counts = const QueueCounts(), this.cursor,  Map<String, int> warningCounts = const <String, int>{}, this.isLoadingMore = false, this.loadError}): _entries = entries,_warningCounts = warningCounts;
  

/// Rows loaded so far, oldest submission first.
///
/// The queue's work order: a listing that has waited longest is first,
/// because that is what makes the 48h SLA meaningful rather than
/// decorative.
 final  List<AdminQueueEntry> _entries;
/// Rows loaded so far, oldest submission first.
///
/// The queue's work order: a listing that has waited longest is first,
/// because that is what makes the 48h SLA meaningful rather than
/// decorative.
@override@JsonKey() List<AdminQueueEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// Tab counts for every status the queue shows.
///
/// Authoritative from the server on every response, so they stay fresh
/// across pages without a second round trip.
@override@JsonKey() final  QueueCounts counts;
/// Cursor for the next page, or null once exhausted.
@override final  QueueCursor? cursor;
/// Fraud-warning counts by listing id (HYA-303).
///
/// Fetched after each page via the batch counts RPC, keyed by the ids on
/// screen. Missing keys read as 0 through [QueueViewStateX.warningsFor]:
/// a listing actioned between the page load and the counts call simply
/// shows no flag rather than failing the page.
 final  Map<String, int> _warningCounts;
/// Fraud-warning counts by listing id (HYA-303).
///
/// Fetched after each page via the batch counts RPC, keyed by the ids on
/// screen. Missing keys read as 0 through [QueueViewStateX.warningsFor]:
/// a listing actioned between the page load and the counts call simply
/// shows no flag rather than failing the page.
@override@JsonKey() Map<String, int> get warningCounts {
  if (_warningCounts is EqualUnmodifiableMapView) return _warningCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_warningCounts);
}

/// Whether a further page is in flight.
///
/// Separate from the provider's loading state so a scroll can show a footer
/// spinner while existing rows stay on screen.
@override@JsonKey() final  bool isLoadingMore;
/// Failure from the most recent load, if any.
@override final  AppException? loadError;

/// Create a copy of QueueViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueViewStateCopyWith<_QueueViewState> get copyWith => __$QueueViewStateCopyWithImpl<_QueueViewState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueViewState&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&const DeepCollectionEquality().equals(other.warningCounts, _warningCounts)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadError, loadError) || other.loadError == loadError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),counts,cursor,const DeepCollectionEquality().hash(_warningCounts),isLoadingMore,loadError);
}

@override
String toString() {
    return 'QueueViewState(entries: $entries, counts: $counts, cursor: $cursor, warningCounts: $warningCounts, isLoadingMore: $isLoadingMore, loadError: $loadError)';
}


}

/// @nodoc
abstract mixin class _$QueueViewStateCopyWith<$Res> implements $QueueViewStateCopyWith<$Res> {
  factory _$QueueViewStateCopyWith(_QueueViewState value, $Res Function(_QueueViewState) _then) = __$QueueViewStateCopyWithImpl;
@override @useResult
$Res call({
 List<AdminQueueEntry> entries, QueueCounts counts, QueueCursor? cursor, Map<String, int> warningCounts, bool isLoadingMore, AppException? loadError
});


@override $QueueCountsCopyWith<$Res> get counts;

}
/// @nodoc
class __$QueueViewStateCopyWithImpl<$Res>
    implements _$QueueViewStateCopyWith<$Res> {
  __$QueueViewStateCopyWithImpl(this._self, this._then);

  final _QueueViewState _self;
  final $Res Function(_QueueViewState) _then;

/// Create a copy of QueueViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? counts = null,Object? cursor = freezed,Object? warningCounts = null,Object? isLoadingMore = null,Object? loadError = freezed,}) {
  return _then(_QueueViewState(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<AdminQueueEntry>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as QueueCounts,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as QueueCursor?,warningCounts: null == warningCounts ? _self._warningCounts : warningCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as AppException?,
  ));
}

/// Create a copy of QueueViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<$Res> get counts {
  
  return $QueueCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}

// dart format on
