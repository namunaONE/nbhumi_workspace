// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_reveal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyReveal {

 String get listingId;/// Listing title at read time. Null when the listing is no longer
/// visible to the caller (unpublished since the reveal); the row still
/// renders with a fallback title.
 String? get listingTitle; DateTime? get revealedAt; DateTime? get expiresAt;
/// Create a copy of MyReveal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyRevealCopyWith<MyReveal> get copyWith => _$MyRevealCopyWithImpl<MyReveal>(this as MyReveal, _$identity);

  /// Serializes this MyReveal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MyReveal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyReveal&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.listingTitle, _this.listingTitle) || other.listingTitle == _this.listingTitle)&&(identical(other.revealedAt, _this.revealedAt) || other.revealedAt == _this.revealedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MyReveal;
  return Object.hash(runtimeType,_this.listingId,_this.listingTitle,_this.revealedAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as MyReveal;
  return 'MyReveal(listingId: ${_this.listingId}, listingTitle: ${_this.listingTitle}, revealedAt: ${_this.revealedAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $MyRevealCopyWith<$Res>  {
  factory $MyRevealCopyWith(MyReveal value, $Res Function(MyReveal) _then) = _$MyRevealCopyWithImpl;
@useResult
$Res call({
 String listingId, String? listingTitle, DateTime? revealedAt, DateTime? expiresAt
});




}
/// @nodoc
class _$MyRevealCopyWithImpl<$Res>
    implements $MyRevealCopyWith<$Res> {
  _$MyRevealCopyWithImpl(this._self, this._then);

  final MyReveal _self;
  final $Res Function(MyReveal) _then;

/// Create a copy of MyReveal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? listingTitle = freezed,Object? revealedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(MyReveal(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,listingTitle: freezed == listingTitle ? _self.listingTitle : listingTitle // ignore: cast_nullable_to_non_nullable
as String?,revealedAt: freezed == revealedAt ? _self.revealedAt : revealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyReveal].
extension MyRevealPatterns on MyReveal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyReveal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyReveal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyReveal value)  $default,){
final _that = this;
switch (_that) {
case _MyReveal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyReveal value)?  $default,){
final _that = this;
switch (_that) {
case _MyReveal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listingId,  String? listingTitle,  DateTime? revealedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyReveal() when $default != null:
return $default(_that.listingId,_that.listingTitle,_that.revealedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listingId,  String? listingTitle,  DateTime? revealedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _MyReveal():
return $default(_that.listingId,_that.listingTitle,_that.revealedAt,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listingId,  String? listingTitle,  DateTime? revealedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _MyReveal() when $default != null:
return $default(_that.listingId,_that.listingTitle,_that.revealedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MyReveal extends MyReveal {
  const _MyReveal({required this.listingId, this.listingTitle, this.revealedAt, this.expiresAt}): super._();
  factory _MyReveal.fromJson(Map<String, dynamic> json) => _$MyRevealFromJson(json);

@override final  String listingId;
/// Listing title at read time. Null when the listing is no longer
/// visible to the caller (unpublished since the reveal); the row still
/// renders with a fallback title.
@override final  String? listingTitle;
@override final  DateTime? revealedAt;
@override final  DateTime? expiresAt;

/// Create a copy of MyReveal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyRevealCopyWith<_MyReveal> get copyWith => __$MyRevealCopyWithImpl<_MyReveal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyRevealToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyReveal&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.listingTitle, listingTitle) || other.listingTitle == listingTitle)&&(identical(other.revealedAt, revealedAt) || other.revealedAt == revealedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listingId,listingTitle,revealedAt,expiresAt);
}

@override
String toString() {
    return 'MyReveal(listingId: $listingId, listingTitle: $listingTitle, revealedAt: $revealedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$MyRevealCopyWith<$Res> implements $MyRevealCopyWith<$Res> {
  factory _$MyRevealCopyWith(_MyReveal value, $Res Function(_MyReveal) _then) = __$MyRevealCopyWithImpl;
@override @useResult
$Res call({
 String listingId, String? listingTitle, DateTime? revealedAt, DateTime? expiresAt
});




}
/// @nodoc
class __$MyRevealCopyWithImpl<$Res>
    implements _$MyRevealCopyWith<$Res> {
  __$MyRevealCopyWithImpl(this._self, this._then);

  final _MyReveal _self;
  final $Res Function(_MyReveal) _then;

/// Create a copy of MyReveal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? listingTitle = freezed,Object? revealedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_MyReveal(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,listingTitle: freezed == listingTitle ? _self.listingTitle : listingTitle // ignore: cast_nullable_to_non_nullable
as String?,revealedAt: freezed == revealedAt ? _self.revealedAt : revealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
