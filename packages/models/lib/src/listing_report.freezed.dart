// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportedListing {

 String get id; String get title; int get priceNpr; ListingStatus get status; String get district; String get city; String get sellerId;
/// Create a copy of ReportedListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportedListingCopyWith<ReportedListing> get copyWith => _$ReportedListingCopyWithImpl<ReportedListing>(this as ReportedListing, _$identity);

  /// Serializes this ReportedListing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportedListing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportedListing&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.priceNpr, _this.priceNpr) || other.priceNpr == _this.priceNpr)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportedListing;
  return Object.hash(runtimeType,_this.id,_this.title,_this.priceNpr,_this.status,_this.district,_this.city,_this.sellerId);
}

@override
String toString() {
  final _this = this as ReportedListing;
  return 'ReportedListing(id: ${_this.id}, title: ${_this.title}, priceNpr: ${_this.priceNpr}, status: ${_this.status}, district: ${_this.district}, city: ${_this.city}, sellerId: ${_this.sellerId})';
}


}

/// @nodoc
abstract mixin class $ReportedListingCopyWith<$Res>  {
  factory $ReportedListingCopyWith(ReportedListing value, $Res Function(ReportedListing) _then) = _$ReportedListingCopyWithImpl;
@useResult
$Res call({
 String id, String title, int priceNpr, ListingStatus status, String district, String city, String sellerId
});




}
/// @nodoc
class _$ReportedListingCopyWithImpl<$Res>
    implements $ReportedListingCopyWith<$Res> {
  _$ReportedListingCopyWithImpl(this._self, this._then);

  final ReportedListing _self;
  final $Res Function(ReportedListing) _then;

/// Create a copy of ReportedListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? priceNpr = null,Object? status = null,Object? district = null,Object? city = null,Object? sellerId = null,}) {
  return _then(ReportedListing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportedListing].
extension ReportedListingPatterns on ReportedListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportedListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportedListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportedListing value)  $default,){
final _that = this;
switch (_that) {
case _ReportedListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportedListing value)?  $default,){
final _that = this;
switch (_that) {
case _ReportedListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int priceNpr,  ListingStatus status,  String district,  String city,  String sellerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportedListing() when $default != null:
return $default(_that.id,_that.title,_that.priceNpr,_that.status,_that.district,_that.city,_that.sellerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int priceNpr,  ListingStatus status,  String district,  String city,  String sellerId)  $default,) {final _that = this;
switch (_that) {
case _ReportedListing():
return $default(_that.id,_that.title,_that.priceNpr,_that.status,_that.district,_that.city,_that.sellerId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int priceNpr,  ListingStatus status,  String district,  String city,  String sellerId)?  $default,) {final _that = this;
switch (_that) {
case _ReportedListing() when $default != null:
return $default(_that.id,_that.title,_that.priceNpr,_that.status,_that.district,_that.city,_that.sellerId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ReportedListing implements ReportedListing {
  const _ReportedListing({required this.id, required this.title, required this.priceNpr, required this.status, required this.district, required this.city, required this.sellerId});
  factory _ReportedListing.fromJson(Map<String, dynamic> json) => _$ReportedListingFromJson(json);

@override final  String id;
@override final  String title;
@override final  int priceNpr;
@override final  ListingStatus status;
@override final  String district;
@override final  String city;
@override final  String sellerId;

/// Create a copy of ReportedListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportedListingCopyWith<_ReportedListing> get copyWith => __$ReportedListingCopyWithImpl<_ReportedListing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportedListingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportedListing&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceNpr, priceNpr) || other.priceNpr == priceNpr)&&(identical(other.status, status) || other.status == status)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,priceNpr,status,district,city,sellerId);
}

@override
String toString() {
    return 'ReportedListing(id: $id, title: $title, priceNpr: $priceNpr, status: $status, district: $district, city: $city, sellerId: $sellerId)';
}


}

/// @nodoc
abstract mixin class _$ReportedListingCopyWith<$Res> implements $ReportedListingCopyWith<$Res> {
  factory _$ReportedListingCopyWith(_ReportedListing value, $Res Function(_ReportedListing) _then) = __$ReportedListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int priceNpr, ListingStatus status, String district, String city, String sellerId
});




}
/// @nodoc
class __$ReportedListingCopyWithImpl<$Res>
    implements _$ReportedListingCopyWith<$Res> {
  __$ReportedListingCopyWithImpl(this._self, this._then);

  final _ReportedListing _self;
  final $Res Function(_ReportedListing) _then;

/// Create a copy of ReportedListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? priceNpr = null,Object? status = null,Object? district = null,Object? city = null,Object? sellerId = null,}) {
  return _then(_ReportedListing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReportAuthor {

 String get id; String? get fullName; String? get role; bool get isVerified;
/// Create a copy of ReportAuthor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportAuthorCopyWith<ReportAuthor> get copyWith => _$ReportAuthorCopyWithImpl<ReportAuthor>(this as ReportAuthor, _$identity);

  /// Serializes this ReportAuthor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportAuthor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportAuthor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportAuthor;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.role,_this.isVerified);
}

@override
String toString() {
  final _this = this as ReportAuthor;
  return 'ReportAuthor(id: ${_this.id}, fullName: ${_this.fullName}, role: ${_this.role}, isVerified: ${_this.isVerified})';
}


}

/// @nodoc
abstract mixin class $ReportAuthorCopyWith<$Res>  {
  factory $ReportAuthorCopyWith(ReportAuthor value, $Res Function(ReportAuthor) _then) = _$ReportAuthorCopyWithImpl;
@useResult
$Res call({
 String id, String? fullName, String? role, bool isVerified
});




}
/// @nodoc
class _$ReportAuthorCopyWithImpl<$Res>
    implements $ReportAuthorCopyWith<$Res> {
  _$ReportAuthorCopyWithImpl(this._self, this._then);

  final ReportAuthor _self;
  final $Res Function(ReportAuthor) _then;

/// Create a copy of ReportAuthor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = freezed,Object? role = freezed,Object? isVerified = null,}) {
  return _then(ReportAuthor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportAuthor].
extension ReportAuthorPatterns on ReportAuthor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportAuthor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportAuthor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportAuthor value)  $default,){
final _that = this;
switch (_that) {
case _ReportAuthor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportAuthor value)?  $default,){
final _that = this;
switch (_that) {
case _ReportAuthor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? fullName,  String? role,  bool isVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportAuthor() when $default != null:
return $default(_that.id,_that.fullName,_that.role,_that.isVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? fullName,  String? role,  bool isVerified)  $default,) {final _that = this;
switch (_that) {
case _ReportAuthor():
return $default(_that.id,_that.fullName,_that.role,_that.isVerified);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? fullName,  String? role,  bool isVerified)?  $default,) {final _that = this;
switch (_that) {
case _ReportAuthor() when $default != null:
return $default(_that.id,_that.fullName,_that.role,_that.isVerified);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ReportAuthor implements ReportAuthor {
  const _ReportAuthor({required this.id, this.fullName, this.role, this.isVerified = false});
  factory _ReportAuthor.fromJson(Map<String, dynamic> json) => _$ReportAuthorFromJson(json);

@override final  String id;
@override final  String? fullName;
@override final  String? role;
@override@JsonKey() final  bool isVerified;

/// Create a copy of ReportAuthor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportAuthorCopyWith<_ReportAuthor> get copyWith => __$ReportAuthorCopyWithImpl<_ReportAuthor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportAuthorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportAuthor&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,role,isVerified);
}

@override
String toString() {
    return 'ReportAuthor(id: $id, fullName: $fullName, role: $role, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class _$ReportAuthorCopyWith<$Res> implements $ReportAuthorCopyWith<$Res> {
  factory _$ReportAuthorCopyWith(_ReportAuthor value, $Res Function(_ReportAuthor) _then) = __$ReportAuthorCopyWithImpl;
@override @useResult
$Res call({
 String id, String? fullName, String? role, bool isVerified
});




}
/// @nodoc
class __$ReportAuthorCopyWithImpl<$Res>
    implements _$ReportAuthorCopyWith<$Res> {
  __$ReportAuthorCopyWithImpl(this._self, this._then);

  final _ReportAuthor _self;
  final $Res Function(_ReportAuthor) _then;

/// Create a copy of ReportAuthor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = freezed,Object? role = freezed,Object? isVerified = null,}) {
  return _then(_ReportAuthor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AdminReportEntry {

 String get id; String get listingId; ReportReason get reason; ReportStatus get status; ReportedListing get listing; ReportAuthor get reporter; String? get details; DateTime? get resolvedAt; DateTime? get createdAt;
/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminReportEntryCopyWith<AdminReportEntry> get copyWith => _$AdminReportEntryCopyWithImpl<AdminReportEntry>(this as AdminReportEntry, _$identity);

  /// Serializes this AdminReportEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminReportEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminReportEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.listing, _this.listing) || other.listing == _this.listing)&&(identical(other.reporter, _this.reporter) || other.reporter == _this.reporter)&&(identical(other.details, _this.details) || other.details == _this.details)&&(identical(other.resolvedAt, _this.resolvedAt) || other.resolvedAt == _this.resolvedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminReportEntry;
  return Object.hash(runtimeType,_this.id,_this.listingId,_this.reason,_this.status,_this.listing,_this.reporter,_this.details,_this.resolvedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as AdminReportEntry;
  return 'AdminReportEntry(id: ${_this.id}, listingId: ${_this.listingId}, reason: ${_this.reason}, status: ${_this.status}, listing: ${_this.listing}, reporter: ${_this.reporter}, details: ${_this.details}, resolvedAt: ${_this.resolvedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AdminReportEntryCopyWith<$Res>  {
  factory $AdminReportEntryCopyWith(AdminReportEntry value, $Res Function(AdminReportEntry) _then) = _$AdminReportEntryCopyWithImpl;
@useResult
$Res call({
 String id, String listingId, ReportReason reason, ReportStatus status, ReportedListing listing, ReportAuthor reporter, String? details, DateTime? resolvedAt, DateTime? createdAt
});


$ReportedListingCopyWith<$Res> get listing;$ReportAuthorCopyWith<$Res> get reporter;

}
/// @nodoc
class _$AdminReportEntryCopyWithImpl<$Res>
    implements $AdminReportEntryCopyWith<$Res> {
  _$AdminReportEntryCopyWithImpl(this._self, this._then);

  final AdminReportEntry _self;
  final $Res Function(AdminReportEntry) _then;

/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listingId = null,Object? reason = null,Object? status = null,Object? listing = null,Object? reporter = null,Object? details = freezed,Object? resolvedAt = freezed,Object? createdAt = freezed,}) {
  return _then(AdminReportEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,listing: null == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as ReportedListing,reporter: null == reporter ? _self.reporter : reporter // ignore: cast_nullable_to_non_nullable
as ReportAuthor,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportedListingCopyWith<$Res> get listing {
  
  return $ReportedListingCopyWith<$Res>(_self.listing, (value) {
    return _then(_self.copyWith(listing: value));
  });
}/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportAuthorCopyWith<$Res> get reporter {
  
  return $ReportAuthorCopyWith<$Res>(_self.reporter, (value) {
    return _then(_self.copyWith(reporter: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminReportEntry].
extension AdminReportEntryPatterns on AdminReportEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminReportEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminReportEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminReportEntry value)  $default,){
final _that = this;
switch (_that) {
case _AdminReportEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminReportEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AdminReportEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String listingId,  ReportReason reason,  ReportStatus status,  ReportedListing listing,  ReportAuthor reporter,  String? details,  DateTime? resolvedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminReportEntry() when $default != null:
return $default(_that.id,_that.listingId,_that.reason,_that.status,_that.listing,_that.reporter,_that.details,_that.resolvedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String listingId,  ReportReason reason,  ReportStatus status,  ReportedListing listing,  ReportAuthor reporter,  String? details,  DateTime? resolvedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminReportEntry():
return $default(_that.id,_that.listingId,_that.reason,_that.status,_that.listing,_that.reporter,_that.details,_that.resolvedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String listingId,  ReportReason reason,  ReportStatus status,  ReportedListing listing,  ReportAuthor reporter,  String? details,  DateTime? resolvedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminReportEntry() when $default != null:
return $default(_that.id,_that.listingId,_that.reason,_that.status,_that.listing,_that.reporter,_that.details,_that.resolvedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _AdminReportEntry implements AdminReportEntry {
  const _AdminReportEntry({required this.id, required this.listingId, required this.reason, required this.status, required this.listing, required this.reporter, this.details, this.resolvedAt, this.createdAt});
  factory _AdminReportEntry.fromJson(Map<String, dynamic> json) => _$AdminReportEntryFromJson(json);

@override final  String id;
@override final  String listingId;
@override final  ReportReason reason;
@override final  ReportStatus status;
@override final  ReportedListing listing;
@override final  ReportAuthor reporter;
@override final  String? details;
@override final  DateTime? resolvedAt;
@override final  DateTime? createdAt;

/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminReportEntryCopyWith<_AdminReportEntry> get copyWith => __$AdminReportEntryCopyWithImpl<_AdminReportEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminReportEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminReportEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.listing, listing) || other.listing == listing)&&(identical(other.reporter, reporter) || other.reporter == reporter)&&(identical(other.details, details) || other.details == details)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,listingId,reason,status,listing,reporter,details,resolvedAt,createdAt);
}

@override
String toString() {
    return 'AdminReportEntry(id: $id, listingId: $listingId, reason: $reason, status: $status, listing: $listing, reporter: $reporter, details: $details, resolvedAt: $resolvedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminReportEntryCopyWith<$Res> implements $AdminReportEntryCopyWith<$Res> {
  factory _$AdminReportEntryCopyWith(_AdminReportEntry value, $Res Function(_AdminReportEntry) _then) = __$AdminReportEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String listingId, ReportReason reason, ReportStatus status, ReportedListing listing, ReportAuthor reporter, String? details, DateTime? resolvedAt, DateTime? createdAt
});


@override $ReportedListingCopyWith<$Res> get listing;@override $ReportAuthorCopyWith<$Res> get reporter;

}
/// @nodoc
class __$AdminReportEntryCopyWithImpl<$Res>
    implements _$AdminReportEntryCopyWith<$Res> {
  __$AdminReportEntryCopyWithImpl(this._self, this._then);

  final _AdminReportEntry _self;
  final $Res Function(_AdminReportEntry) _then;

/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listingId = null,Object? reason = null,Object? status = null,Object? listing = null,Object? reporter = null,Object? details = freezed,Object? resolvedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_AdminReportEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,listing: null == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as ReportedListing,reporter: null == reporter ? _self.reporter : reporter // ignore: cast_nullable_to_non_nullable
as ReportAuthor,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportedListingCopyWith<$Res> get listing {
  
  return $ReportedListingCopyWith<$Res>(_self.listing, (value) {
    return _then(_self.copyWith(listing: value));
  });
}/// Create a copy of AdminReportEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportAuthorCopyWith<$Res> get reporter {
  
  return $ReportAuthorCopyWith<$Res>(_self.reporter, (value) {
    return _then(_self.copyWith(reporter: value));
  });
}
}


/// @nodoc
mixin _$ListingReport {

 String get reportId; String get listingId; ReportReason get reason; String? get details; DateTime? get createdAt;
/// Create a copy of ListingReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingReportCopyWith<ListingReport> get copyWith => _$ListingReportCopyWithImpl<ListingReport>(this as ListingReport, _$identity);

  /// Serializes this ListingReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingReport&&(identical(other.reportId, _this.reportId) || other.reportId == _this.reportId)&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.details, _this.details) || other.details == _this.details)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingReport;
  return Object.hash(runtimeType,_this.reportId,_this.listingId,_this.reason,_this.details,_this.createdAt);
}

@override
String toString() {
  final _this = this as ListingReport;
  return 'ListingReport(reportId: ${_this.reportId}, listingId: ${_this.listingId}, reason: ${_this.reason}, details: ${_this.details}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ListingReportCopyWith<$Res>  {
  factory $ListingReportCopyWith(ListingReport value, $Res Function(ListingReport) _then) = _$ListingReportCopyWithImpl;
@useResult
$Res call({
 String reportId, String listingId, ReportReason reason, String? details, DateTime? createdAt
});




}
/// @nodoc
class _$ListingReportCopyWithImpl<$Res>
    implements $ListingReportCopyWith<$Res> {
  _$ListingReportCopyWithImpl(this._self, this._then);

  final ListingReport _self;
  final $Res Function(ListingReport) _then;

/// Create a copy of ListingReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportId = null,Object? listingId = null,Object? reason = null,Object? details = freezed,Object? createdAt = freezed,}) {
  return _then(ListingReport(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingReport].
extension ListingReportPatterns on ListingReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingReport value)  $default,){
final _that = this;
switch (_that) {
case _ListingReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingReport value)?  $default,){
final _that = this;
switch (_that) {
case _ListingReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reportId,  String listingId,  ReportReason reason,  String? details,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingReport() when $default != null:
return $default(_that.reportId,_that.listingId,_that.reason,_that.details,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reportId,  String listingId,  ReportReason reason,  String? details,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ListingReport():
return $default(_that.reportId,_that.listingId,_that.reason,_that.details,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reportId,  String listingId,  ReportReason reason,  String? details,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ListingReport() when $default != null:
return $default(_that.reportId,_that.listingId,_that.reason,_that.details,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ListingReport implements ListingReport {
  const _ListingReport({required this.reportId, required this.listingId, required this.reason, this.details, this.createdAt});
  factory _ListingReport.fromJson(Map<String, dynamic> json) => _$ListingReportFromJson(json);

@override final  String reportId;
@override final  String listingId;
@override final  ReportReason reason;
@override final  String? details;
@override final  DateTime? createdAt;

/// Create a copy of ListingReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingReportCopyWith<_ListingReport> get copyWith => __$ListingReportCopyWithImpl<_ListingReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingReport&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.details, details) || other.details == details)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reportId,listingId,reason,details,createdAt);
}

@override
String toString() {
    return 'ListingReport(reportId: $reportId, listingId: $listingId, reason: $reason, details: $details, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ListingReportCopyWith<$Res> implements $ListingReportCopyWith<$Res> {
  factory _$ListingReportCopyWith(_ListingReport value, $Res Function(_ListingReport) _then) = __$ListingReportCopyWithImpl;
@override @useResult
$Res call({
 String reportId, String listingId, ReportReason reason, String? details, DateTime? createdAt
});




}
/// @nodoc
class __$ListingReportCopyWithImpl<$Res>
    implements _$ListingReportCopyWith<$Res> {
  __$ListingReportCopyWithImpl(this._self, this._then);

  final _ListingReport _self;
  final $Res Function(_ListingReport) _then;

/// Create a copy of ListingReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportId = null,Object? listingId = null,Object? reason = null,Object? details = freezed,Object? createdAt = freezed,}) {
  return _then(_ListingReport(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$ReportCounts {

 int get open; int get actioned; int get dismissed;
/// Create a copy of ReportCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCountsCopyWith<ReportCounts> get copyWith => _$ReportCountsCopyWithImpl<ReportCounts>(this as ReportCounts, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReportCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportCounts&&(identical(other.open, _this.open) || other.open == _this.open)&&(identical(other.actioned, _this.actioned) || other.actioned == _this.actioned)&&(identical(other.dismissed, _this.dismissed) || other.dismissed == _this.dismissed));
}


@override
int get hashCode {
  final _this = this as ReportCounts;
  return Object.hash(runtimeType,_this.open,_this.actioned,_this.dismissed);
}

@override
String toString() {
  final _this = this as ReportCounts;
  return 'ReportCounts(open: ${_this.open}, actioned: ${_this.actioned}, dismissed: ${_this.dismissed})';
}


}

/// @nodoc
abstract mixin class $ReportCountsCopyWith<$Res>  {
  factory $ReportCountsCopyWith(ReportCounts value, $Res Function(ReportCounts) _then) = _$ReportCountsCopyWithImpl;
@useResult
$Res call({
 int open, int actioned, int dismissed
});




}
/// @nodoc
class _$ReportCountsCopyWithImpl<$Res>
    implements $ReportCountsCopyWith<$Res> {
  _$ReportCountsCopyWithImpl(this._self, this._then);

  final ReportCounts _self;
  final $Res Function(ReportCounts) _then;

/// Create a copy of ReportCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? open = null,Object? actioned = null,Object? dismissed = null,}) {
  return _then(ReportCounts(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as int,actioned: null == actioned ? _self.actioned : actioned // ignore: cast_nullable_to_non_nullable
as int,dismissed: null == dismissed ? _self.dismissed : dismissed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportCounts].
extension ReportCountsPatterns on ReportCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportCounts value)  $default,){
final _that = this;
switch (_that) {
case _ReportCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportCounts value)?  $default,){
final _that = this;
switch (_that) {
case _ReportCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int open,  int actioned,  int dismissed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportCounts() when $default != null:
return $default(_that.open,_that.actioned,_that.dismissed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int open,  int actioned,  int dismissed)  $default,) {final _that = this;
switch (_that) {
case _ReportCounts():
return $default(_that.open,_that.actioned,_that.dismissed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int open,  int actioned,  int dismissed)?  $default,) {final _that = this;
switch (_that) {
case _ReportCounts() when $default != null:
return $default(_that.open,_that.actioned,_that.dismissed);case _:
  return null;

}
}

}

/// @nodoc


class _ReportCounts implements ReportCounts {
  const _ReportCounts({this.open = 0, this.actioned = 0, this.dismissed = 0});
  

@override@JsonKey() final  int open;
@override@JsonKey() final  int actioned;
@override@JsonKey() final  int dismissed;

/// Create a copy of ReportCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCountsCopyWith<_ReportCounts> get copyWith => __$ReportCountsCopyWithImpl<_ReportCounts>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportCounts&&(identical(other.open, open) || other.open == open)&&(identical(other.actioned, actioned) || other.actioned == actioned)&&(identical(other.dismissed, dismissed) || other.dismissed == dismissed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,open,actioned,dismissed);
}

@override
String toString() {
    return 'ReportCounts(open: $open, actioned: $actioned, dismissed: $dismissed)';
}


}

/// @nodoc
abstract mixin class _$ReportCountsCopyWith<$Res> implements $ReportCountsCopyWith<$Res> {
  factory _$ReportCountsCopyWith(_ReportCounts value, $Res Function(_ReportCounts) _then) = __$ReportCountsCopyWithImpl;
@override @useResult
$Res call({
 int open, int actioned, int dismissed
});




}
/// @nodoc
class __$ReportCountsCopyWithImpl<$Res>
    implements _$ReportCountsCopyWith<$Res> {
  __$ReportCountsCopyWithImpl(this._self, this._then);

  final _ReportCounts _self;
  final $Res Function(_ReportCounts) _then;

/// Create a copy of ReportCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? open = null,Object? actioned = null,Object? dismissed = null,}) {
  return _then(_ReportCounts(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as int,actioned: null == actioned ? _self.actioned : actioned // ignore: cast_nullable_to_non_nullable
as int,dismissed: null == dismissed ? _self.dismissed : dismissed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
