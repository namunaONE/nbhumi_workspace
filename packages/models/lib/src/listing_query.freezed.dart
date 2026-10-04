// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingCursor {

 String get k; String get id;
/// Create a copy of ListingCursor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCursorCopyWith<ListingCursor> get copyWith => _$ListingCursorCopyWithImpl<ListingCursor>(this as ListingCursor, _$identity);

  /// Serializes this ListingCursor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingCursor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingCursor&&(identical(other.k, _this.k) || other.k == _this.k)&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingCursor;
  return Object.hash(runtimeType,_this.k,_this.id);
}

@override
String toString() {
  final _this = this as ListingCursor;
  return 'ListingCursor(k: ${_this.k}, id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $ListingCursorCopyWith<$Res>  {
  factory $ListingCursorCopyWith(ListingCursor value, $Res Function(ListingCursor) _then) = _$ListingCursorCopyWithImpl;
@useResult
$Res call({
 String k, String id
});




}
/// @nodoc
class _$ListingCursorCopyWithImpl<$Res>
    implements $ListingCursorCopyWith<$Res> {
  _$ListingCursorCopyWithImpl(this._self, this._then);

  final ListingCursor _self;
  final $Res Function(ListingCursor) _then;

/// Create a copy of ListingCursor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? k = null,Object? id = null,}) {
  return _then(ListingCursor(
k: null == k ? _self.k : k // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingCursor].
extension ListingCursorPatterns on ListingCursor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingCursor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingCursor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingCursor value)  $default,){
final _that = this;
switch (_that) {
case _ListingCursor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingCursor value)?  $default,){
final _that = this;
switch (_that) {
case _ListingCursor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String k,  String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingCursor() when $default != null:
return $default(_that.k,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String k,  String id)  $default,) {final _that = this;
switch (_that) {
case _ListingCursor():
return $default(_that.k,_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String k,  String id)?  $default,) {final _that = this;
switch (_that) {
case _ListingCursor() when $default != null:
return $default(_that.k,_that.id);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ListingCursor implements ListingCursor {
  const _ListingCursor({required this.k, required this.id});
  factory _ListingCursor.fromJson(Map<String, dynamic> json) => _$ListingCursorFromJson(json);

@override final  String k;
@override final  String id;

/// Create a copy of ListingCursor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCursorCopyWith<_ListingCursor> get copyWith => __$ListingCursorCopyWithImpl<_ListingCursor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingCursorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingCursor&&(identical(other.k, k) || other.k == k)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,k,id);
}

@override
String toString() {
    return 'ListingCursor(k: $k, id: $id)';
}


}

/// @nodoc
abstract mixin class _$ListingCursorCopyWith<$Res> implements $ListingCursorCopyWith<$Res> {
  factory _$ListingCursorCopyWith(_ListingCursor value, $Res Function(_ListingCursor) _then) = __$ListingCursorCopyWithImpl;
@override @useResult
$Res call({
 String k, String id
});




}
/// @nodoc
class __$ListingCursorCopyWithImpl<$Res>
    implements _$ListingCursorCopyWith<$Res> {
  __$ListingCursorCopyWithImpl(this._self, this._then);

  final _ListingCursor _self;
  final $Res Function(_ListingCursor) _then;

/// Create a copy of ListingCursor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? k = null,Object? id = null,}) {
  return _then(_ListingCursor(
k: null == k ? _self.k : k // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ListingFilter {

 PropertyType? get propertyType; ListingPurpose? get listingPurpose; String? get district; String? get municipality; int? get minPriceNpr; int? get maxPriceNpr; double? get minAreaSqm; double? get maxAreaSqm;/// Free-text search. Accepted by the model for UI state; the RPC does not
/// expose a text filter until a `tsvector` index exists (see SCHEMA.md
/// "Indexes"). Passing one is a no-op rather than an error so the search
/// field can ship ahead of the backend.
 String? get query; ListingSort get sort; int get pageSize;
/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingFilterCopyWith<ListingFilter> get copyWith => _$ListingFilterCopyWithImpl<ListingFilter>(this as ListingFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ListingFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingFilter&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.listingPurpose, _this.listingPurpose) || other.listingPurpose == _this.listingPurpose)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.municipality, _this.municipality) || other.municipality == _this.municipality)&&(identical(other.minPriceNpr, _this.minPriceNpr) || other.minPriceNpr == _this.minPriceNpr)&&(identical(other.maxPriceNpr, _this.maxPriceNpr) || other.maxPriceNpr == _this.maxPriceNpr)&&(identical(other.minAreaSqm, _this.minAreaSqm) || other.minAreaSqm == _this.minAreaSqm)&&(identical(other.maxAreaSqm, _this.maxAreaSqm) || other.maxAreaSqm == _this.maxAreaSqm)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.sort, _this.sort) || other.sort == _this.sort)&&(identical(other.pageSize, _this.pageSize) || other.pageSize == _this.pageSize));
}


@override
int get hashCode {
  final _this = this as ListingFilter;
  return Object.hash(runtimeType,_this.propertyType,_this.listingPurpose,_this.district,_this.municipality,_this.minPriceNpr,_this.maxPriceNpr,_this.minAreaSqm,_this.maxAreaSqm,_this.query,_this.sort,_this.pageSize);
}

@override
String toString() {
  final _this = this as ListingFilter;
  return 'ListingFilter(propertyType: ${_this.propertyType}, listingPurpose: ${_this.listingPurpose}, district: ${_this.district}, municipality: ${_this.municipality}, minPriceNpr: ${_this.minPriceNpr}, maxPriceNpr: ${_this.maxPriceNpr}, minAreaSqm: ${_this.minAreaSqm}, maxAreaSqm: ${_this.maxAreaSqm}, query: ${_this.query}, sort: ${_this.sort}, pageSize: ${_this.pageSize})';
}


}

/// @nodoc
abstract mixin class $ListingFilterCopyWith<$Res>  {
  factory $ListingFilterCopyWith(ListingFilter value, $Res Function(ListingFilter) _then) = _$ListingFilterCopyWithImpl;
@useResult
$Res call({
 PropertyType? propertyType, ListingPurpose? listingPurpose, String? district, String? municipality, int? minPriceNpr, int? maxPriceNpr, double? minAreaSqm, double? maxAreaSqm, String? query, ListingSort sort, int pageSize
});




}
/// @nodoc
class _$ListingFilterCopyWithImpl<$Res>
    implements $ListingFilterCopyWith<$Res> {
  _$ListingFilterCopyWithImpl(this._self, this._then);

  final ListingFilter _self;
  final $Res Function(ListingFilter) _then;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? propertyType = freezed,Object? listingPurpose = freezed,Object? district = freezed,Object? municipality = freezed,Object? minPriceNpr = freezed,Object? maxPriceNpr = freezed,Object? minAreaSqm = freezed,Object? maxAreaSqm = freezed,Object? query = freezed,Object? sort = null,Object? pageSize = null,}) {
  return _then(ListingFilter(
propertyType: freezed == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType?,listingPurpose: freezed == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,municipality: freezed == municipality ? _self.municipality : municipality // ignore: cast_nullable_to_non_nullable
as String?,minPriceNpr: freezed == minPriceNpr ? _self.minPriceNpr : minPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,maxPriceNpr: freezed == maxPriceNpr ? _self.maxPriceNpr : maxPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,minAreaSqm: freezed == minAreaSqm ? _self.minAreaSqm : minAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,maxAreaSqm: freezed == maxAreaSqm ? _self.maxAreaSqm : maxAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ListingSort,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingFilter].
extension ListingFilterPatterns on ListingFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingFilter value)  $default,){
final _that = this;
switch (_that) {
case _ListingFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PropertyType? propertyType,  ListingPurpose? listingPurpose,  String? district,  String? municipality,  int? minPriceNpr,  int? maxPriceNpr,  double? minAreaSqm,  double? maxAreaSqm,  String? query,  ListingSort sort,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
return $default(_that.propertyType,_that.listingPurpose,_that.district,_that.municipality,_that.minPriceNpr,_that.maxPriceNpr,_that.minAreaSqm,_that.maxAreaSqm,_that.query,_that.sort,_that.pageSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PropertyType? propertyType,  ListingPurpose? listingPurpose,  String? district,  String? municipality,  int? minPriceNpr,  int? maxPriceNpr,  double? minAreaSqm,  double? maxAreaSqm,  String? query,  ListingSort sort,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _ListingFilter():
return $default(_that.propertyType,_that.listingPurpose,_that.district,_that.municipality,_that.minPriceNpr,_that.maxPriceNpr,_that.minAreaSqm,_that.maxAreaSqm,_that.query,_that.sort,_that.pageSize);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PropertyType? propertyType,  ListingPurpose? listingPurpose,  String? district,  String? municipality,  int? minPriceNpr,  int? maxPriceNpr,  double? minAreaSqm,  double? maxAreaSqm,  String? query,  ListingSort sort,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
return $default(_that.propertyType,_that.listingPurpose,_that.district,_that.municipality,_that.minPriceNpr,_that.maxPriceNpr,_that.minAreaSqm,_that.maxAreaSqm,_that.query,_that.sort,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc


class _ListingFilter extends ListingFilter {
  const _ListingFilter({this.propertyType, this.listingPurpose, this.district, this.municipality, this.minPriceNpr, this.maxPriceNpr, this.minAreaSqm, this.maxAreaSqm, this.query, this.sort = ListingSort.newest, this.pageSize = 20}): super._();
  

@override final  PropertyType? propertyType;
@override final  ListingPurpose? listingPurpose;
@override final  String? district;
@override final  String? municipality;
@override final  int? minPriceNpr;
@override final  int? maxPriceNpr;
@override final  double? minAreaSqm;
@override final  double? maxAreaSqm;
/// Free-text search. Accepted by the model for UI state; the RPC does not
/// expose a text filter until a `tsvector` index exists (see SCHEMA.md
/// "Indexes"). Passing one is a no-op rather than an error so the search
/// field can ship ahead of the backend.
@override final  String? query;
@override@JsonKey() final  ListingSort sort;
@override@JsonKey() final  int pageSize;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingFilterCopyWith<_ListingFilter> get copyWith => __$ListingFilterCopyWithImpl<_ListingFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingFilter&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.listingPurpose, listingPurpose) || other.listingPurpose == listingPurpose)&&(identical(other.district, district) || other.district == district)&&(identical(other.municipality, municipality) || other.municipality == municipality)&&(identical(other.minPriceNpr, minPriceNpr) || other.minPriceNpr == minPriceNpr)&&(identical(other.maxPriceNpr, maxPriceNpr) || other.maxPriceNpr == maxPriceNpr)&&(identical(other.minAreaSqm, minAreaSqm) || other.minAreaSqm == minAreaSqm)&&(identical(other.maxAreaSqm, maxAreaSqm) || other.maxAreaSqm == maxAreaSqm)&&(identical(other.query, query) || other.query == query)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode {
    return Object.hash(runtimeType,propertyType,listingPurpose,district,municipality,minPriceNpr,maxPriceNpr,minAreaSqm,maxAreaSqm,query,sort,pageSize);
}

@override
String toString() {
    return 'ListingFilter(propertyType: $propertyType, listingPurpose: $listingPurpose, district: $district, municipality: $municipality, minPriceNpr: $minPriceNpr, maxPriceNpr: $maxPriceNpr, minAreaSqm: $minAreaSqm, maxAreaSqm: $maxAreaSqm, query: $query, sort: $sort, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$ListingFilterCopyWith<$Res> implements $ListingFilterCopyWith<$Res> {
  factory _$ListingFilterCopyWith(_ListingFilter value, $Res Function(_ListingFilter) _then) = __$ListingFilterCopyWithImpl;
@override @useResult
$Res call({
 PropertyType? propertyType, ListingPurpose? listingPurpose, String? district, String? municipality, int? minPriceNpr, int? maxPriceNpr, double? minAreaSqm, double? maxAreaSqm, String? query, ListingSort sort, int pageSize
});




}
/// @nodoc
class __$ListingFilterCopyWithImpl<$Res>
    implements _$ListingFilterCopyWith<$Res> {
  __$ListingFilterCopyWithImpl(this._self, this._then);

  final _ListingFilter _self;
  final $Res Function(_ListingFilter) _then;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? propertyType = freezed,Object? listingPurpose = freezed,Object? district = freezed,Object? municipality = freezed,Object? minPriceNpr = freezed,Object? maxPriceNpr = freezed,Object? minAreaSqm = freezed,Object? maxAreaSqm = freezed,Object? query = freezed,Object? sort = null,Object? pageSize = null,}) {
  return _then(_ListingFilter(
propertyType: freezed == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType?,listingPurpose: freezed == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,municipality: freezed == municipality ? _self.municipality : municipality // ignore: cast_nullable_to_non_nullable
as String?,minPriceNpr: freezed == minPriceNpr ? _self.minPriceNpr : minPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,maxPriceNpr: freezed == maxPriceNpr ? _self.maxPriceNpr : maxPriceNpr // ignore: cast_nullable_to_non_nullable
as int?,minAreaSqm: freezed == minAreaSqm ? _self.minAreaSqm : minAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,maxAreaSqm: freezed == maxAreaSqm ? _self.maxAreaSqm : maxAreaSqm // ignore: cast_nullable_to_non_nullable
as double?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ListingSort,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ListingPage {

 List<ListingSummary> get listings; int get totalCount; int get pageSize; bool get hasMore;
/// Create a copy of ListingPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingPageCopyWith<ListingPage> get copyWith => _$ListingPageCopyWithImpl<ListingPage>(this as ListingPage, _$identity);

  /// Serializes this ListingPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingPage&&const DeepCollectionEquality().equals(other.listings, _this.listings)&&(identical(other.totalCount, _this.totalCount) || other.totalCount == _this.totalCount)&&(identical(other.pageSize, _this.pageSize) || other.pageSize == _this.pageSize)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listings),_this.totalCount,_this.pageSize,_this.hasMore);
}

@override
String toString() {
  final _this = this as ListingPage;
  return 'ListingPage(listings: ${_this.listings}, totalCount: ${_this.totalCount}, pageSize: ${_this.pageSize}, hasMore: ${_this.hasMore})';
}


}

/// @nodoc
abstract mixin class $ListingPageCopyWith<$Res>  {
  factory $ListingPageCopyWith(ListingPage value, $Res Function(ListingPage) _then) = _$ListingPageCopyWithImpl;
@useResult
$Res call({
 List<ListingSummary> listings, int totalCount, int pageSize, bool hasMore
});




}
/// @nodoc
class _$ListingPageCopyWithImpl<$Res>
    implements $ListingPageCopyWith<$Res> {
  _$ListingPageCopyWithImpl(this._self, this._then);

  final ListingPage _self;
  final $Res Function(ListingPage) _then;

/// Create a copy of ListingPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listings = null,Object? totalCount = null,Object? pageSize = null,Object? hasMore = null,}) {
  return _then(ListingPage(
listings: null == listings ? _self.listings : listings // ignore: cast_nullable_to_non_nullable
as List<ListingSummary>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingPage].
extension ListingPagePatterns on ListingPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingPage value)  $default,){
final _that = this;
switch (_that) {
case _ListingPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingPage value)?  $default,){
final _that = this;
switch (_that) {
case _ListingPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ListingSummary> listings,  int totalCount,  int pageSize,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingPage() when $default != null:
return $default(_that.listings,_that.totalCount,_that.pageSize,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ListingSummary> listings,  int totalCount,  int pageSize,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _ListingPage():
return $default(_that.listings,_that.totalCount,_that.pageSize,_that.hasMore);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ListingSummary> listings,  int totalCount,  int pageSize,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _ListingPage() when $default != null:
return $default(_that.listings,_that.totalCount,_that.pageSize,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ListingPage extends ListingPage {
  const _ListingPage({ List<ListingSummary> listings = const <ListingSummary>[], this.totalCount = 0, this.pageSize = 20, this.hasMore = false}): _listings = listings,super._();
  factory _ListingPage.fromJson(Map<String, dynamic> json) => _$ListingPageFromJson(json);

 final  List<ListingSummary> _listings;
@override@JsonKey() List<ListingSummary> get listings {
  if (_listings is EqualUnmodifiableListView) return _listings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listings);
}

@override@JsonKey() final  int totalCount;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  bool hasMore;

/// Create a copy of ListingPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingPageCopyWith<_ListingPage> get copyWith => __$ListingPageCopyWithImpl<_ListingPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingPage&&const DeepCollectionEquality().equals(other.listings, _listings)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listings),totalCount,pageSize,hasMore);
}

@override
String toString() {
    return 'ListingPage(listings: $listings, totalCount: $totalCount, pageSize: $pageSize, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$ListingPageCopyWith<$Res> implements $ListingPageCopyWith<$Res> {
  factory _$ListingPageCopyWith(_ListingPage value, $Res Function(_ListingPage) _then) = __$ListingPageCopyWithImpl;
@override @useResult
$Res call({
 List<ListingSummary> listings, int totalCount, int pageSize, bool hasMore
});




}
/// @nodoc
class __$ListingPageCopyWithImpl<$Res>
    implements _$ListingPageCopyWith<$Res> {
  __$ListingPageCopyWithImpl(this._self, this._then);

  final _ListingPage _self;
  final $Res Function(_ListingPage) _then;

/// Create a copy of ListingPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listings = null,Object? totalCount = null,Object? pageSize = null,Object? hasMore = null,}) {
  return _then(_ListingPage(
listings: null == listings ? _self._listings : listings // ignore: cast_nullable_to_non_nullable
as List<ListingSummary>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
