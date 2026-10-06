// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedSearch {

 String get id; String get userId; String get name; String? get district; PropertyType? get propertyType; ListingPurpose? get listingPurpose; int? get minPriceNpr; int? get maxPriceNpr; double? get minAreaSqm; double? get maxAreaSqm; DateTime? get createdAt;
/// Create a copy of SavedSearch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedSearchCopyWith<SavedSearch> get copyWith => _$SavedSearchCopyWithImpl<SavedSearch>(this as SavedSearch, _$identity);

  /// Serializes this SavedSearch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavedSearch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedSearch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.listingPurpose, _this.listingPurpose) || other.listingPurpose == _this.listingPurpose)&&(identical(other.minPriceNpr, _this.minPriceNpr) || other.minPriceNpr == _this.minPriceNpr)&&(identical(other.maxPriceNpr, _this.maxPriceNpr) || other.maxPriceNpr == _this.maxPriceNpr)&&(identical(other.minAreaSqm, _this.minAreaSqm) || other.minAreaSqm == _this.minAreaSqm)&&(identical(other.maxAreaSqm, _this.maxAreaSqm) || other.maxAreaSqm == _this.maxAreaSqm)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavedSearch;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.name,_this.district,_this.propertyType,_this.listingPurpose,_this.minPriceNpr,_this.maxPriceNpr,_this.minAreaSqm,_this.maxAreaSqm,_this.createdAt);
}

@override
String toString() {
  final _this = this as SavedSearch;
  return 'SavedSearch(id: ${_this.id}, userId: ${_this.userId}, name: ${_this.name}, district: ${_this.district}, propertyType: ${_this.propertyType}, listingPurpose: ${_this.listingPurpose}, minPriceNpr: ${_this.minPriceNpr}, maxPriceNpr: ${_this.maxPriceNpr}, minAreaSqm: ${_this.minAreaSqm}, maxAreaSqm: ${_this.maxAreaSqm}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $SavedSearchCopyWith<$Res>  {
  factory $SavedSearchCopyWith(SavedSearch value, $Res Function(SavedSearch) _then) = _$SavedSearchCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? district, PropertyType? propertyType, ListingPurpose? listingPurpose, int? minPriceNpr, int? maxPriceNpr, double? minAreaSqm, double? maxAreaSqm, DateTime? createdAt
});




}
/// @nodoc
class _$SavedSearchCopyWithImpl<$Res>
    implements $SavedSearchCopyWith<$Res> {
  _$SavedSearchCopyWithImpl(this._self, this._then);

  final SavedSearch _self;
  final $Res Function(SavedSearch) _then;

/// Create a copy of SavedSearch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? district = freezed,Object? propertyType = freezed,Object? listingPurpose = freezed,Object? minPriceNpr = freezed,Object? maxPriceNpr = freezed,Object? minAreaSqm = freezed,Object? maxAreaSqm = freezed,Object? createdAt = freezed,}) {
  return _then(SavedSearch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,propertyType: freezed == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType?,listingPurpose: freezed == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose?,minPriceNpr: freezed == minPriceNpr ? _self.minPriceNpr : minPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,maxPriceNpr: freezed == maxPriceNpr ? _self.maxPriceNpr : maxPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,minAreaSqm: freezed == minAreaSqm ? _self.minAreaSqm : minAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,maxAreaSqm: freezed == maxAreaSqm ? _self.maxAreaSqm : maxAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedSearch].
extension SavedSearchPatterns on SavedSearch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedSearch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedSearch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedSearch value)  $default,){
final _that = this;
switch (_that) {
case _SavedSearch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedSearch value)?  $default,){
final _that = this;
switch (_that) {
case _SavedSearch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? district,  PropertyType? propertyType,  ListingPurpose? listingPurpose,  int? minPriceNpr,  int? maxPriceNpr,  double? minAreaSqm,  double? maxAreaSqm,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedSearch() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.district,_that.propertyType,_that.listingPurpose,_that.minPriceNpr,_that.maxPriceNpr,_that.minAreaSqm,_that.maxAreaSqm,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? district,  PropertyType? propertyType,  ListingPurpose? listingPurpose,  int? minPriceNpr,  int? maxPriceNpr,  double? minAreaSqm,  double? maxAreaSqm,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SavedSearch():
return $default(_that.id,_that.userId,_that.name,_that.district,_that.propertyType,_that.listingPurpose,_that.minPriceNpr,_that.maxPriceNpr,_that.minAreaSqm,_that.maxAreaSqm,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? district,  PropertyType? propertyType,  ListingPurpose? listingPurpose,  int? minPriceNpr,  int? maxPriceNpr,  double? minAreaSqm,  double? maxAreaSqm,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SavedSearch() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.district,_that.propertyType,_that.listingPurpose,_that.minPriceNpr,_that.maxPriceNpr,_that.minAreaSqm,_that.maxAreaSqm,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SavedSearch extends SavedSearch {
  const _SavedSearch({required this.id, required this.userId, required this.name, this.district, this.propertyType, this.listingPurpose, this.minPriceNpr, this.maxPriceNpr, this.minAreaSqm, this.maxAreaSqm, this.createdAt}): super._();
  factory _SavedSearch.fromJson(Map<String, dynamic> json) => _$SavedSearchFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String? district;
@override final  PropertyType? propertyType;
@override final  ListingPurpose? listingPurpose;
@override final  int? minPriceNpr;
@override final  int? maxPriceNpr;
@override final  double? minAreaSqm;
@override final  double? maxAreaSqm;
@override final  DateTime? createdAt;

/// Create a copy of SavedSearch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedSearchCopyWith<_SavedSearch> get copyWith => __$SavedSearchCopyWithImpl<_SavedSearch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedSearchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedSearch&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.district, district) || other.district == district)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.listingPurpose, listingPurpose) || other.listingPurpose == listingPurpose)&&(identical(other.minPriceNpr, minPriceNpr) || other.minPriceNpr == minPriceNpr)&&(identical(other.maxPriceNpr, maxPriceNpr) || other.maxPriceNpr == maxPriceNpr)&&(identical(other.minAreaSqm, minAreaSqm) || other.minAreaSqm == minAreaSqm)&&(identical(other.maxAreaSqm, maxAreaSqm) || other.maxAreaSqm == maxAreaSqm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,name,district,propertyType,listingPurpose,minPriceNpr,maxPriceNpr,minAreaSqm,maxAreaSqm,createdAt);
}

@override
String toString() {
    return 'SavedSearch(id: $id, userId: $userId, name: $name, district: $district, propertyType: $propertyType, listingPurpose: $listingPurpose, minPriceNpr: $minPriceNpr, maxPriceNpr: $maxPriceNpr, minAreaSqm: $minAreaSqm, maxAreaSqm: $maxAreaSqm, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SavedSearchCopyWith<$Res> implements $SavedSearchCopyWith<$Res> {
  factory _$SavedSearchCopyWith(_SavedSearch value, $Res Function(_SavedSearch) _then) = __$SavedSearchCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? district, PropertyType? propertyType, ListingPurpose? listingPurpose, int? minPriceNpr, int? maxPriceNpr, double? minAreaSqm, double? maxAreaSqm, DateTime? createdAt
});




}
/// @nodoc
class __$SavedSearchCopyWithImpl<$Res>
    implements _$SavedSearchCopyWith<$Res> {
  __$SavedSearchCopyWithImpl(this._self, this._then);

  final _SavedSearch _self;
  final $Res Function(_SavedSearch) _then;

/// Create a copy of SavedSearch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? district = freezed,Object? propertyType = freezed,Object? listingPurpose = freezed,Object? minPriceNpr = freezed,Object? maxPriceNpr = freezed,Object? minAreaSqm = freezed,Object? maxAreaSqm = freezed,Object? createdAt = freezed,}) {
  return _then(_SavedSearch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,propertyType: freezed == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType?,listingPurpose: freezed == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose?,minPriceNpr: freezed == minPriceNpr ? _self.minPriceNpr : minPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,maxPriceNpr: freezed == maxPriceNpr ? _self.maxPriceNpr : maxPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,minAreaSqm: freezed == minAreaSqm ? _self.minAreaSqm : minAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,maxAreaSqm: freezed == maxAreaSqm ? _self.maxAreaSqm : maxAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
