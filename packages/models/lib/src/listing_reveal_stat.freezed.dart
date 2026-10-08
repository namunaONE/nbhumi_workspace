// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_reveal_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingRevealStat {

 String get listingId; String get title; int get revealCount; DateTime? get lastRevealedAt;
/// Create a copy of ListingRevealStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingRevealStatCopyWith<ListingRevealStat> get copyWith => _$ListingRevealStatCopyWithImpl<ListingRevealStat>(this as ListingRevealStat, _$identity);

  /// Serializes this ListingRevealStat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingRevealStat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingRevealStat&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.revealCount, _this.revealCount) || other.revealCount == _this.revealCount)&&(identical(other.lastRevealedAt, _this.lastRevealedAt) || other.lastRevealedAt == _this.lastRevealedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingRevealStat;
  return Object.hash(runtimeType,_this.listingId,_this.title,_this.revealCount,_this.lastRevealedAt);
}

@override
String toString() {
  final _this = this as ListingRevealStat;
  return 'ListingRevealStat(listingId: ${_this.listingId}, title: ${_this.title}, revealCount: ${_this.revealCount}, lastRevealedAt: ${_this.lastRevealedAt})';
}


}

/// @nodoc
abstract mixin class $ListingRevealStatCopyWith<$Res>  {
  factory $ListingRevealStatCopyWith(ListingRevealStat value, $Res Function(ListingRevealStat) _then) = _$ListingRevealStatCopyWithImpl;
@useResult
$Res call({
 String listingId, String title, int revealCount, DateTime? lastRevealedAt
});




}
/// @nodoc
class _$ListingRevealStatCopyWithImpl<$Res>
    implements $ListingRevealStatCopyWith<$Res> {
  _$ListingRevealStatCopyWithImpl(this._self, this._then);

  final ListingRevealStat _self;
  final $Res Function(ListingRevealStat) _then;

/// Create a copy of ListingRevealStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? title = null,Object? revealCount = null,Object? lastRevealedAt = freezed,}) {
  return _then(ListingRevealStat(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,revealCount: null == revealCount ? _self.revealCount : revealCount // ignore: cast_nullable_to_non_nullable
as int,lastRevealedAt: freezed == lastRevealedAt ? _self.lastRevealedAt : lastRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingRevealStat].
extension ListingRevealStatPatterns on ListingRevealStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingRevealStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingRevealStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingRevealStat value)  $default,){
final _that = this;
switch (_that) {
case _ListingRevealStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingRevealStat value)?  $default,){
final _that = this;
switch (_that) {
case _ListingRevealStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listingId,  String title,  int revealCount,  DateTime? lastRevealedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingRevealStat() when $default != null:
return $default(_that.listingId,_that.title,_that.revealCount,_that.lastRevealedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listingId,  String title,  int revealCount,  DateTime? lastRevealedAt)  $default,) {final _that = this;
switch (_that) {
case _ListingRevealStat():
return $default(_that.listingId,_that.title,_that.revealCount,_that.lastRevealedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listingId,  String title,  int revealCount,  DateTime? lastRevealedAt)?  $default,) {final _that = this;
switch (_that) {
case _ListingRevealStat() when $default != null:
return $default(_that.listingId,_that.title,_that.revealCount,_that.lastRevealedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ListingRevealStat implements ListingRevealStat {
  const _ListingRevealStat({required this.listingId, required this.title, this.revealCount = 0, this.lastRevealedAt});
  factory _ListingRevealStat.fromJson(Map<String, dynamic> json) => _$ListingRevealStatFromJson(json);

@override final  String listingId;
@override final  String title;
@override@JsonKey() final  int revealCount;
@override final  DateTime? lastRevealedAt;

/// Create a copy of ListingRevealStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingRevealStatCopyWith<_ListingRevealStat> get copyWith => __$ListingRevealStatCopyWithImpl<_ListingRevealStat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingRevealStatToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingRevealStat&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.title, title) || other.title == title)&&(identical(other.revealCount, revealCount) || other.revealCount == revealCount)&&(identical(other.lastRevealedAt, lastRevealedAt) || other.lastRevealedAt == lastRevealedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listingId,title,revealCount,lastRevealedAt);
}

@override
String toString() {
    return 'ListingRevealStat(listingId: $listingId, title: $title, revealCount: $revealCount, lastRevealedAt: $lastRevealedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingRevealStatCopyWith<$Res> implements $ListingRevealStatCopyWith<$Res> {
  factory _$ListingRevealStatCopyWith(_ListingRevealStat value, $Res Function(_ListingRevealStat) _then) = __$ListingRevealStatCopyWithImpl;
@override @useResult
$Res call({
 String listingId, String title, int revealCount, DateTime? lastRevealedAt
});




}
/// @nodoc
class __$ListingRevealStatCopyWithImpl<$Res>
    implements _$ListingRevealStatCopyWith<$Res> {
  __$ListingRevealStatCopyWithImpl(this._self, this._then);

  final _ListingRevealStat _self;
  final $Res Function(_ListingRevealStat) _then;

/// Create a copy of ListingRevealStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? title = null,Object? revealCount = null,Object? lastRevealedAt = freezed,}) {
  return _then(_ListingRevealStat(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,revealCount: null == revealCount ? _self.revealCount : revealCount // ignore: cast_nullable_to_non_nullable
as int,lastRevealedAt: freezed == lastRevealedAt ? _self.lastRevealedAt : lastRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
