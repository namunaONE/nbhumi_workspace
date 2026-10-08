// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityPage {

 List<ListingSummary> get listings; List<MyReveal> get reveals; List<ListingRevealStat> get revealStats; List<KycDocument> get documents; List<AppNotification> get updates;
/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityPageCopyWith<ActivityPage> get copyWith => _$ActivityPageCopyWithImpl<ActivityPage>(this as ActivityPage, _$identity);

  /// Serializes this ActivityPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ActivityPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityPage&&const DeepCollectionEquality().equals(other.listings, _this.listings)&&const DeepCollectionEquality().equals(other.reveals, _this.reveals)&&const DeepCollectionEquality().equals(other.revealStats, _this.revealStats)&&const DeepCollectionEquality().equals(other.documents, _this.documents)&&const DeepCollectionEquality().equals(other.updates, _this.updates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ActivityPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listings),const DeepCollectionEquality().hash(_this.reveals),const DeepCollectionEquality().hash(_this.revealStats),const DeepCollectionEquality().hash(_this.documents),const DeepCollectionEquality().hash(_this.updates));
}

@override
String toString() {
  final _this = this as ActivityPage;
  return 'ActivityPage(listings: ${_this.listings}, reveals: ${_this.reveals}, revealStats: ${_this.revealStats}, documents: ${_this.documents}, updates: ${_this.updates})';
}


}

/// @nodoc
abstract mixin class $ActivityPageCopyWith<$Res>  {
  factory $ActivityPageCopyWith(ActivityPage value, $Res Function(ActivityPage) _then) = _$ActivityPageCopyWithImpl;
@useResult
$Res call({
 List<ListingSummary> listings, List<MyReveal> reveals, List<ListingRevealStat> revealStats, List<KycDocument> documents, List<AppNotification> updates
});




}
/// @nodoc
class _$ActivityPageCopyWithImpl<$Res>
    implements $ActivityPageCopyWith<$Res> {
  _$ActivityPageCopyWithImpl(this._self, this._then);

  final ActivityPage _self;
  final $Res Function(ActivityPage) _then;

/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listings = null,Object? reveals = null,Object? revealStats = null,Object? documents = null,Object? updates = null,}) {
  return _then(ActivityPage(
listings: null == listings ? _self.listings : listings // ignore: cast_nullable_to_non_nullable
as List<ListingSummary>,reveals: null == reveals ? _self.reveals : reveals // ignore: cast_nullable_to_non_nullable
as List<MyReveal>,revealStats: null == revealStats ? _self.revealStats : revealStats // ignore: cast_nullable_to_non_nullable
as List<ListingRevealStat>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<KycDocument>,updates: null == updates ? _self.updates : updates // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityPage].
extension ActivityPagePatterns on ActivityPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityPage value)  $default,){
final _that = this;
switch (_that) {
case _ActivityPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityPage value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ListingSummary> listings,  List<MyReveal> reveals,  List<ListingRevealStat> revealStats,  List<KycDocument> documents,  List<AppNotification> updates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
return $default(_that.listings,_that.reveals,_that.revealStats,_that.documents,_that.updates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ListingSummary> listings,  List<MyReveal> reveals,  List<ListingRevealStat> revealStats,  List<KycDocument> documents,  List<AppNotification> updates)  $default,) {final _that = this;
switch (_that) {
case _ActivityPage():
return $default(_that.listings,_that.reveals,_that.revealStats,_that.documents,_that.updates);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ListingSummary> listings,  List<MyReveal> reveals,  List<ListingRevealStat> revealStats,  List<KycDocument> documents,  List<AppNotification> updates)?  $default,) {final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
return $default(_that.listings,_that.reveals,_that.revealStats,_that.documents,_that.updates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityPage implements ActivityPage {
  const _ActivityPage({ List<ListingSummary> listings = const <ListingSummary>[],  List<MyReveal> reveals = const <MyReveal>[],  List<ListingRevealStat> revealStats = const <ListingRevealStat>[],  List<KycDocument> documents = const <KycDocument>[],  List<AppNotification> updates = const <AppNotification>[]}): _listings = listings,_reveals = reveals,_revealStats = revealStats,_documents = documents,_updates = updates;
  factory _ActivityPage.fromJson(Map<String, dynamic> json) => _$ActivityPageFromJson(json);

 final  List<ListingSummary> _listings;
@override@JsonKey() List<ListingSummary> get listings {
  if (_listings is EqualUnmodifiableListView) return _listings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listings);
}

 final  List<MyReveal> _reveals;
@override@JsonKey() List<MyReveal> get reveals {
  if (_reveals is EqualUnmodifiableListView) return _reveals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reveals);
}

 final  List<ListingRevealStat> _revealStats;
@override@JsonKey() List<ListingRevealStat> get revealStats {
  if (_revealStats is EqualUnmodifiableListView) return _revealStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revealStats);
}

 final  List<KycDocument> _documents;
@override@JsonKey() List<KycDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

 final  List<AppNotification> _updates;
@override@JsonKey() List<AppNotification> get updates {
  if (_updates is EqualUnmodifiableListView) return _updates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_updates);
}


/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityPageCopyWith<_ActivityPage> get copyWith => __$ActivityPageCopyWithImpl<_ActivityPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityPage&&const DeepCollectionEquality().equals(other.listings, _listings)&&const DeepCollectionEquality().equals(other.reveals, _reveals)&&const DeepCollectionEquality().equals(other.revealStats, _revealStats)&&const DeepCollectionEquality().equals(other.documents, _documents)&&const DeepCollectionEquality().equals(other.updates, _updates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listings),const DeepCollectionEquality().hash(_reveals),const DeepCollectionEquality().hash(_revealStats),const DeepCollectionEquality().hash(_documents),const DeepCollectionEquality().hash(_updates));
}

@override
String toString() {
    return 'ActivityPage(listings: $listings, reveals: $reveals, revealStats: $revealStats, documents: $documents, updates: $updates)';
}


}

/// @nodoc
abstract mixin class _$ActivityPageCopyWith<$Res> implements $ActivityPageCopyWith<$Res> {
  factory _$ActivityPageCopyWith(_ActivityPage value, $Res Function(_ActivityPage) _then) = __$ActivityPageCopyWithImpl;
@override @useResult
$Res call({
 List<ListingSummary> listings, List<MyReveal> reveals, List<ListingRevealStat> revealStats, List<KycDocument> documents, List<AppNotification> updates
});




}
/// @nodoc
class __$ActivityPageCopyWithImpl<$Res>
    implements _$ActivityPageCopyWith<$Res> {
  __$ActivityPageCopyWithImpl(this._self, this._then);

  final _ActivityPage _self;
  final $Res Function(_ActivityPage) _then;

/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listings = null,Object? reveals = null,Object? revealStats = null,Object? documents = null,Object? updates = null,}) {
  return _then(_ActivityPage(
listings: null == listings ? _self._listings : listings // ignore: cast_nullable_to_non_nullable
as List<ListingSummary>,reveals: null == reveals ? _self._reveals : reveals // ignore: cast_nullable_to_non_nullable
as List<MyReveal>,revealStats: null == revealStats ? _self._revealStats : revealStats // ignore: cast_nullable_to_non_nullable
as List<ListingRevealStat>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<KycDocument>,updates: null == updates ? _self._updates : updates // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,
  ));
}


}

// dart format on
