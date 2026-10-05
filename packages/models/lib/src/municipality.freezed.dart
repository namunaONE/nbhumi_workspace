// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'municipality.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Municipality {

 String get id; String get slug; String get district; String get name; MunicipalityType get type; int get wardCount; String? get nameNe;
/// Create a copy of Municipality
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MunicipalityCopyWith<Municipality> get copyWith => _$MunicipalityCopyWithImpl<Municipality>(this as Municipality, _$identity);

  /// Serializes this Municipality to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Municipality;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Municipality&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.wardCount, _this.wardCount) || other.wardCount == _this.wardCount)&&(identical(other.nameNe, _this.nameNe) || other.nameNe == _this.nameNe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Municipality;
  return Object.hash(runtimeType,_this.id,_this.slug,_this.district,_this.name,_this.type,_this.wardCount,_this.nameNe);
}

@override
String toString() {
  final _this = this as Municipality;
  return 'Municipality(id: ${_this.id}, slug: ${_this.slug}, district: ${_this.district}, name: ${_this.name}, type: ${_this.type}, wardCount: ${_this.wardCount}, nameNe: ${_this.nameNe})';
}


}

/// @nodoc
abstract mixin class $MunicipalityCopyWith<$Res>  {
  factory $MunicipalityCopyWith(Municipality value, $Res Function(Municipality) _then) = _$MunicipalityCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String district, String name, MunicipalityType type, int wardCount, String? nameNe
});




}
/// @nodoc
class _$MunicipalityCopyWithImpl<$Res>
    implements $MunicipalityCopyWith<$Res> {
  _$MunicipalityCopyWithImpl(this._self, this._then);

  final Municipality _self;
  final $Res Function(Municipality) _then;

/// Create a copy of Municipality
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? district = null,Object? name = null,Object? type = null,Object? wardCount = null,Object? nameNe = freezed,}) {
  return _then(Municipality(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MunicipalityType,wardCount: null == wardCount ? _self.wardCount : wardCount // ignore: cast_nullable_to_non_nullable
as int,nameNe: freezed == nameNe ? _self.nameNe : nameNe // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Municipality].
extension MunicipalityPatterns on Municipality {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Municipality value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Municipality() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Municipality value)  $default,){
final _that = this;
switch (_that) {
case _Municipality():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Municipality value)?  $default,){
final _that = this;
switch (_that) {
case _Municipality() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String district,  String name,  MunicipalityType type,  int wardCount,  String? nameNe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Municipality() when $default != null:
return $default(_that.id,_that.slug,_that.district,_that.name,_that.type,_that.wardCount,_that.nameNe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String district,  String name,  MunicipalityType type,  int wardCount,  String? nameNe)  $default,) {final _that = this;
switch (_that) {
case _Municipality():
return $default(_that.id,_that.slug,_that.district,_that.name,_that.type,_that.wardCount,_that.nameNe);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String district,  String name,  MunicipalityType type,  int wardCount,  String? nameNe)?  $default,) {final _that = this;
switch (_that) {
case _Municipality() when $default != null:
return $default(_that.id,_that.slug,_that.district,_that.name,_that.type,_that.wardCount,_that.nameNe);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Municipality extends Municipality {
  const _Municipality({required this.id, required this.slug, required this.district, required this.name, required this.type, required this.wardCount, this.nameNe}): super._();
  factory _Municipality.fromJson(Map<String, dynamic> json) => _$MunicipalityFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String district;
@override final  String name;
@override final  MunicipalityType type;
@override final  int wardCount;
@override final  String? nameNe;

/// Create a copy of Municipality
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MunicipalityCopyWith<_Municipality> get copyWith => __$MunicipalityCopyWithImpl<_Municipality>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MunicipalityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Municipality&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.district, district) || other.district == district)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.wardCount, wardCount) || other.wardCount == wardCount)&&(identical(other.nameNe, nameNe) || other.nameNe == nameNe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,slug,district,name,type,wardCount,nameNe);
}

@override
String toString() {
    return 'Municipality(id: $id, slug: $slug, district: $district, name: $name, type: $type, wardCount: $wardCount, nameNe: $nameNe)';
}


}

/// @nodoc
abstract mixin class _$MunicipalityCopyWith<$Res> implements $MunicipalityCopyWith<$Res> {
  factory _$MunicipalityCopyWith(_Municipality value, $Res Function(_Municipality) _then) = __$MunicipalityCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String district, String name, MunicipalityType type, int wardCount, String? nameNe
});




}
/// @nodoc
class __$MunicipalityCopyWithImpl<$Res>
    implements _$MunicipalityCopyWith<$Res> {
  __$MunicipalityCopyWithImpl(this._self, this._then);

  final _Municipality _self;
  final $Res Function(_Municipality) _then;

/// Create a copy of Municipality
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? district = null,Object? name = null,Object? type = null,Object? wardCount = null,Object? nameNe = freezed,}) {
  return _then(_Municipality(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MunicipalityType,wardCount: null == wardCount ? _self.wardCount : wardCount // ignore: cast_nullable_to_non_nullable
as int,nameNe: freezed == nameNe ? _self.nameNe : nameNe // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
