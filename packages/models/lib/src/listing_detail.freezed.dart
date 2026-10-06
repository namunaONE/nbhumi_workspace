// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingSeller {

 String get id; String? get fullName; bool get isVerified; String? get kycTier; String? get role; String? get agencyName;
/// Create a copy of ListingSeller
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingSellerCopyWith<ListingSeller> get copyWith => _$ListingSellerCopyWithImpl<ListingSeller>(this as ListingSeller, _$identity);

  /// Serializes this ListingSeller to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingSeller;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingSeller&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.kycTier, _this.kycTier) || other.kycTier == _this.kycTier)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.agencyName, _this.agencyName) || other.agencyName == _this.agencyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingSeller;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.isVerified,_this.kycTier,_this.role,_this.agencyName);
}

@override
String toString() {
  final _this = this as ListingSeller;
  return 'ListingSeller(id: ${_this.id}, fullName: ${_this.fullName}, isVerified: ${_this.isVerified}, kycTier: ${_this.kycTier}, role: ${_this.role}, agencyName: ${_this.agencyName})';
}


}

/// @nodoc
abstract mixin class $ListingSellerCopyWith<$Res>  {
  factory $ListingSellerCopyWith(ListingSeller value, $Res Function(ListingSeller) _then) = _$ListingSellerCopyWithImpl;
@useResult
$Res call({
 String id, String? fullName, bool isVerified, String? kycTier, String? role, String? agencyName
});




}
/// @nodoc
class _$ListingSellerCopyWithImpl<$Res>
    implements $ListingSellerCopyWith<$Res> {
  _$ListingSellerCopyWithImpl(this._self, this._then);

  final ListingSeller _self;
  final $Res Function(ListingSeller) _then;

/// Create a copy of ListingSeller
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = freezed,Object? isVerified = null,Object? kycTier = freezed,Object? role = freezed,Object? agencyName = freezed,}) {
  return _then(ListingSeller(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,kycTier: freezed == kycTier ? _self.kycTier : kycTier // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,agencyName: freezed == agencyName ? _self.agencyName : agencyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingSeller].
extension ListingSellerPatterns on ListingSeller {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingSeller value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingSeller() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingSeller value)  $default,){
final _that = this;
switch (_that) {
case _ListingSeller():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingSeller value)?  $default,){
final _that = this;
switch (_that) {
case _ListingSeller() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? fullName,  bool isVerified,  String? kycTier,  String? role,  String? agencyName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingSeller() when $default != null:
return $default(_that.id,_that.fullName,_that.isVerified,_that.kycTier,_that.role,_that.agencyName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? fullName,  bool isVerified,  String? kycTier,  String? role,  String? agencyName)  $default,) {final _that = this;
switch (_that) {
case _ListingSeller():
return $default(_that.id,_that.fullName,_that.isVerified,_that.kycTier,_that.role,_that.agencyName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? fullName,  bool isVerified,  String? kycTier,  String? role,  String? agencyName)?  $default,) {final _that = this;
switch (_that) {
case _ListingSeller() when $default != null:
return $default(_that.id,_that.fullName,_that.isVerified,_that.kycTier,_that.role,_that.agencyName);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ListingSeller implements ListingSeller {
  const _ListingSeller({required this.id, this.fullName, this.isVerified = false, this.kycTier, this.role, this.agencyName});
  factory _ListingSeller.fromJson(Map<String, dynamic> json) => _$ListingSellerFromJson(json);

@override final  String id;
@override final  String? fullName;
@override@JsonKey() final  bool isVerified;
@override final  String? kycTier;
@override final  String? role;
@override final  String? agencyName;

/// Create a copy of ListingSeller
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingSellerCopyWith<_ListingSeller> get copyWith => __$ListingSellerCopyWithImpl<_ListingSeller>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingSellerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingSeller&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.kycTier, kycTier) || other.kycTier == kycTier)&&(identical(other.role, role) || other.role == role)&&(identical(other.agencyName, agencyName) || other.agencyName == agencyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,isVerified,kycTier,role,agencyName);
}

@override
String toString() {
    return 'ListingSeller(id: $id, fullName: $fullName, isVerified: $isVerified, kycTier: $kycTier, role: $role, agencyName: $agencyName)';
}


}

/// @nodoc
abstract mixin class _$ListingSellerCopyWith<$Res> implements $ListingSellerCopyWith<$Res> {
  factory _$ListingSellerCopyWith(_ListingSeller value, $Res Function(_ListingSeller) _then) = __$ListingSellerCopyWithImpl;
@override @useResult
$Res call({
 String id, String? fullName, bool isVerified, String? kycTier, String? role, String? agencyName
});




}
/// @nodoc
class __$ListingSellerCopyWithImpl<$Res>
    implements _$ListingSellerCopyWith<$Res> {
  __$ListingSellerCopyWithImpl(this._self, this._then);

  final _ListingSeller _self;
  final $Res Function(_ListingSeller) _then;

/// Create a copy of ListingSeller
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = freezed,Object? isVerified = null,Object? kycTier = freezed,Object? role = freezed,Object? agencyName = freezed,}) {
  return _then(_ListingSeller(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,kycTier: freezed == kycTier ? _self.kycTier : kycTier // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,agencyName: freezed == agencyName ? _self.agencyName : agencyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListingDetail {

 String get id; String get sellerId; String get title; int get priceNpr; String get district; String get city; PropertyType get propertyType; ListingPurpose get listingPurpose; ListingStatus get status; String? get description; double? get areaSqm; int? get areaRopani; int? get areaAana; int? get areaPaisa; int? get areaDam; int? get areaBigha; int? get areaKattha; int? get areaDhur; String? get ward; int? get roadAccessFt;/// Bedroom and bathroom counts.
///
/// Null for land and commercial premises. Absent from browse responses on
/// purpose: the card never renders them, so `v1_get_listings` does not send
/// them.
 int? get bedrooms; int? get bathrooms; String? get rejectionReason;/// When the seller submitted this for review. Null for a draft.
///
/// Carried here rather than left to the admin queue's own model because the
/// admin panel deep-links to a listing by id: `/listing/:id` is reachable
/// in a fresh tab with no queue loaded, and without this the detail pane
/// would have no submission clock to compute the 48h SLA against.
/// Migration 010 added the column to `v1_get_listing_detail` for the same
/// reason.
 DateTime? get submittedAt;/// Ordered by `sort_order` server-side.
 List<String> get photos; ListingSeller? get seller; String? get areaDisplay;/// Always false until M3 implements favourites.
 bool get isFavorite; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingDetailCopyWith<ListingDetail> get copyWith => _$ListingDetailCopyWithImpl<ListingDetail>(this as ListingDetail, _$identity);

  /// Serializes this ListingDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.priceNpr, _this.priceNpr) || other.priceNpr == _this.priceNpr)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.listingPurpose, _this.listingPurpose) || other.listingPurpose == _this.listingPurpose)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.areaSqm, _this.areaSqm) || other.areaSqm == _this.areaSqm)&&(identical(other.areaRopani, _this.areaRopani) || other.areaRopani == _this.areaRopani)&&(identical(other.areaAana, _this.areaAana) || other.areaAana == _this.areaAana)&&(identical(other.areaPaisa, _this.areaPaisa) || other.areaPaisa == _this.areaPaisa)&&(identical(other.areaDam, _this.areaDam) || other.areaDam == _this.areaDam)&&(identical(other.areaBigha, _this.areaBigha) || other.areaBigha == _this.areaBigha)&&(identical(other.areaKattha, _this.areaKattha) || other.areaKattha == _this.areaKattha)&&(identical(other.areaDhur, _this.areaDhur) || other.areaDhur == _this.areaDhur)&&(identical(other.ward, _this.ward) || other.ward == _this.ward)&&(identical(other.roadAccessFt, _this.roadAccessFt) || other.roadAccessFt == _this.roadAccessFt)&&(identical(other.bedrooms, _this.bedrooms) || other.bedrooms == _this.bedrooms)&&(identical(other.bathrooms, _this.bathrooms) || other.bathrooms == _this.bathrooms)&&(identical(other.rejectionReason, _this.rejectionReason) || other.rejectionReason == _this.rejectionReason)&&(identical(other.submittedAt, _this.submittedAt) || other.submittedAt == _this.submittedAt)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.seller, _this.seller) || other.seller == _this.seller)&&(identical(other.areaDisplay, _this.areaDisplay) || other.areaDisplay == _this.areaDisplay)&&(identical(other.isFavorite, _this.isFavorite) || other.isFavorite == _this.isFavorite)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingDetail;
  return Object.hashAll([runtimeType,_this.id,_this.sellerId,_this.title,_this.priceNpr,_this.district,_this.city,_this.propertyType,_this.listingPurpose,_this.status,_this.description,_this.areaSqm,_this.areaRopani,_this.areaAana,_this.areaPaisa,_this.areaDam,_this.areaBigha,_this.areaKattha,_this.areaDhur,_this.ward,_this.roadAccessFt,_this.bedrooms,_this.bathrooms,_this.rejectionReason,_this.submittedAt,const DeepCollectionEquality().hash(_this.photos),_this.seller,_this.areaDisplay,_this.isFavorite,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as ListingDetail;
  return 'ListingDetail(id: ${_this.id}, sellerId: ${_this.sellerId}, title: ${_this.title}, priceNpr: ${_this.priceNpr}, district: ${_this.district}, city: ${_this.city}, propertyType: ${_this.propertyType}, listingPurpose: ${_this.listingPurpose}, status: ${_this.status}, description: ${_this.description}, areaSqm: ${_this.areaSqm}, areaRopani: ${_this.areaRopani}, areaAana: ${_this.areaAana}, areaPaisa: ${_this.areaPaisa}, areaDam: ${_this.areaDam}, areaBigha: ${_this.areaBigha}, areaKattha: ${_this.areaKattha}, areaDhur: ${_this.areaDhur}, ward: ${_this.ward}, roadAccessFt: ${_this.roadAccessFt}, bedrooms: ${_this.bedrooms}, bathrooms: ${_this.bathrooms}, rejectionReason: ${_this.rejectionReason}, submittedAt: ${_this.submittedAt}, photos: ${_this.photos}, seller: ${_this.seller}, areaDisplay: ${_this.areaDisplay}, isFavorite: ${_this.isFavorite}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ListingDetailCopyWith<$Res>  {
  factory $ListingDetailCopyWith(ListingDetail value, $Res Function(ListingDetail) _then) = _$ListingDetailCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, String title, int priceNpr, String district, String city, PropertyType propertyType, ListingPurpose listingPurpose, ListingStatus status, String? description, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? ward, int? roadAccessFt, int? bedrooms, int? bathrooms, String? rejectionReason, DateTime? submittedAt, List<String> photos, ListingSeller? seller, String? areaDisplay, bool isFavorite, DateTime? createdAt, DateTime? updatedAt
});


$ListingSellerCopyWith<$Res>? get seller;

}
/// @nodoc
class _$ListingDetailCopyWithImpl<$Res>
    implements $ListingDetailCopyWith<$Res> {
  _$ListingDetailCopyWithImpl(this._self, this._then);

  final ListingDetail _self;
  final $Res Function(ListingDetail) _then;

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? title = null,Object? priceNpr = null,Object? district = null,Object? city = null,Object? propertyType = null,Object? listingPurpose = null,Object? status = null,Object? description = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? ward = freezed,Object? roadAccessFt = freezed,Object? bedrooms = freezed,Object? bathrooms = freezed,Object? rejectionReason = freezed,Object? submittedAt = freezed,Object? photos = null,Object? seller = freezed,Object? areaDisplay = freezed,Object? isFavorite = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(ListingDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,areaSqm: freezed == areaSqm ? _self.areaSqm : areaSqm // ignore: cast_nullable_to_non_nullable
as double?,areaRopani: freezed == areaRopani ? _self.areaRopani : areaRopani // ignore: cast_nullable_to_non_nullable
as int?,areaAana: freezed == areaAana ? _self.areaAana : areaAana // ignore: cast_nullable_to_non_nullable
as int?,areaPaisa: freezed == areaPaisa ? _self.areaPaisa : areaPaisa // ignore: cast_nullable_to_non_nullable
as int?,areaDam: freezed == areaDam ? _self.areaDam : areaDam // ignore: cast_nullable_to_non_nullable
as int?,areaBigha: freezed == areaBigha ? _self.areaBigha : areaBigha // ignore: cast_nullable_to_non_nullable
as int?,areaKattha: freezed == areaKattha ? _self.areaKattha : areaKattha // ignore: cast_nullable_to_non_nullable
as int?,areaDhur: freezed == areaDhur ? _self.areaDhur : areaDhur // ignore: cast_nullable_to_non_nullable
as int?,ward: freezed == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String?,roadAccessFt: freezed == roadAccessFt ? _self.roadAccessFt : roadAccessFt // ignore: cast_nullable_to_non_nullable
as int?,bedrooms: freezed == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int?,bathrooms: freezed == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as ListingSeller?,areaDisplay: freezed == areaDisplay ? _self.areaDisplay : areaDisplay // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingSellerCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $ListingSellerCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListingDetail].
extension ListingDetailPatterns on ListingDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingDetail value)  $default,){
final _that = this;
switch (_that) {
case _ListingDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  String title,  int priceNpr,  String district,  String city,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  int? bedrooms,  int? bathrooms,  String? rejectionReason,  DateTime? submittedAt,  List<String> photos,  ListingSeller? seller,  String? areaDisplay,  bool isFavorite,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
return $default(_that.id,_that.sellerId,_that.title,_that.priceNpr,_that.district,_that.city,_that.propertyType,_that.listingPurpose,_that.status,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.bedrooms,_that.bathrooms,_that.rejectionReason,_that.submittedAt,_that.photos,_that.seller,_that.areaDisplay,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  String title,  int priceNpr,  String district,  String city,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  int? bedrooms,  int? bathrooms,  String? rejectionReason,  DateTime? submittedAt,  List<String> photos,  ListingSeller? seller,  String? areaDisplay,  bool isFavorite,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ListingDetail():
return $default(_that.id,_that.sellerId,_that.title,_that.priceNpr,_that.district,_that.city,_that.propertyType,_that.listingPurpose,_that.status,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.bedrooms,_that.bathrooms,_that.rejectionReason,_that.submittedAt,_that.photos,_that.seller,_that.areaDisplay,_that.isFavorite,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  String title,  int priceNpr,  String district,  String city,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  int? bedrooms,  int? bathrooms,  String? rejectionReason,  DateTime? submittedAt,  List<String> photos,  ListingSeller? seller,  String? areaDisplay,  bool isFavorite,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
return $default(_that.id,_that.sellerId,_that.title,_that.priceNpr,_that.district,_that.city,_that.propertyType,_that.listingPurpose,_that.status,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.bedrooms,_that.bathrooms,_that.rejectionReason,_that.submittedAt,_that.photos,_that.seller,_that.areaDisplay,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _ListingDetail implements ListingDetail {
  const _ListingDetail({required this.id, required this.sellerId, required this.title, required this.priceNpr, required this.district, required this.city, required this.propertyType, required this.listingPurpose, this.status = ListingStatus.draft, this.description, this.areaSqm, this.areaRopani, this.areaAana, this.areaPaisa, this.areaDam, this.areaBigha, this.areaKattha, this.areaDhur, this.ward, this.roadAccessFt, this.bedrooms, this.bathrooms, this.rejectionReason, this.submittedAt,  List<String> photos = const <String>[], this.seller, this.areaDisplay, this.isFavorite = false, this.createdAt, this.updatedAt}): _photos = photos;
  factory _ListingDetail.fromJson(Map<String, dynamic> json) => _$ListingDetailFromJson(json);

@override final  String id;
@override final  String sellerId;
@override final  String title;
@override final  int priceNpr;
@override final  String district;
@override final  String city;
@override final  PropertyType propertyType;
@override final  ListingPurpose listingPurpose;
@override@JsonKey() final  ListingStatus status;
@override final  String? description;
@override final  double? areaSqm;
@override final  int? areaRopani;
@override final  int? areaAana;
@override final  int? areaPaisa;
@override final  int? areaDam;
@override final  int? areaBigha;
@override final  int? areaKattha;
@override final  int? areaDhur;
@override final  String? ward;
@override final  int? roadAccessFt;
/// Bedroom and bathroom counts.
///
/// Null for land and commercial premises. Absent from browse responses on
/// purpose: the card never renders them, so `v1_get_listings` does not send
/// them.
@override final  int? bedrooms;
@override final  int? bathrooms;
@override final  String? rejectionReason;
/// When the seller submitted this for review. Null for a draft.
///
/// Carried here rather than left to the admin queue's own model because the
/// admin panel deep-links to a listing by id: `/listing/:id` is reachable
/// in a fresh tab with no queue loaded, and without this the detail pane
/// would have no submission clock to compute the 48h SLA against.
/// Migration 010 added the column to `v1_get_listing_detail` for the same
/// reason.
@override final  DateTime? submittedAt;
/// Ordered by `sort_order` server-side.
 final  List<String> _photos;
/// Ordered by `sort_order` server-side.
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  ListingSeller? seller;
@override final  String? areaDisplay;
/// Always false until M3 implements favourites.
@override@JsonKey() final  bool isFavorite;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingDetailCopyWith<_ListingDetail> get copyWith => __$ListingDetailCopyWithImpl<_ListingDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceNpr, priceNpr) || other.priceNpr == priceNpr)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.listingPurpose, listingPurpose) || other.listingPurpose == listingPurpose)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm)&&(identical(other.areaRopani, areaRopani) || other.areaRopani == areaRopani)&&(identical(other.areaAana, areaAana) || other.areaAana == areaAana)&&(identical(other.areaPaisa, areaPaisa) || other.areaPaisa == areaPaisa)&&(identical(other.areaDam, areaDam) || other.areaDam == areaDam)&&(identical(other.areaBigha, areaBigha) || other.areaBigha == areaBigha)&&(identical(other.areaKattha, areaKattha) || other.areaKattha == areaKattha)&&(identical(other.areaDhur, areaDhur) || other.areaDhur == areaDhur)&&(identical(other.ward, ward) || other.ward == ward)&&(identical(other.roadAccessFt, roadAccessFt) || other.roadAccessFt == roadAccessFt)&&(identical(other.bedrooms, bedrooms) || other.bedrooms == bedrooms)&&(identical(other.bathrooms, bathrooms) || other.bathrooms == bathrooms)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.areaDisplay, areaDisplay) || other.areaDisplay == areaDisplay)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sellerId,title,priceNpr,district,city,propertyType,listingPurpose,status,description,areaSqm,areaRopani,areaAana,areaPaisa,areaDam,areaBigha,areaKattha,areaDhur,ward,roadAccessFt,bedrooms,bathrooms,rejectionReason,submittedAt,const DeepCollectionEquality().hash(_photos),seller,areaDisplay,isFavorite,createdAt,updatedAt]);
}

@override
String toString() {
    return 'ListingDetail(id: $id, sellerId: $sellerId, title: $title, priceNpr: $priceNpr, district: $district, city: $city, propertyType: $propertyType, listingPurpose: $listingPurpose, status: $status, description: $description, areaSqm: $areaSqm, areaRopani: $areaRopani, areaAana: $areaAana, areaPaisa: $areaPaisa, areaDam: $areaDam, areaBigha: $areaBigha, areaKattha: $areaKattha, areaDhur: $areaDhur, ward: $ward, roadAccessFt: $roadAccessFt, bedrooms: $bedrooms, bathrooms: $bathrooms, rejectionReason: $rejectionReason, submittedAt: $submittedAt, photos: $photos, seller: $seller, areaDisplay: $areaDisplay, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingDetailCopyWith<$Res> implements $ListingDetailCopyWith<$Res> {
  factory _$ListingDetailCopyWith(_ListingDetail value, $Res Function(_ListingDetail) _then) = __$ListingDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, String title, int priceNpr, String district, String city, PropertyType propertyType, ListingPurpose listingPurpose, ListingStatus status, String? description, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? ward, int? roadAccessFt, int? bedrooms, int? bathrooms, String? rejectionReason, DateTime? submittedAt, List<String> photos, ListingSeller? seller, String? areaDisplay, bool isFavorite, DateTime? createdAt, DateTime? updatedAt
});


@override $ListingSellerCopyWith<$Res>? get seller;

}
/// @nodoc
class __$ListingDetailCopyWithImpl<$Res>
    implements _$ListingDetailCopyWith<$Res> {
  __$ListingDetailCopyWithImpl(this._self, this._then);

  final _ListingDetail _self;
  final $Res Function(_ListingDetail) _then;

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? title = null,Object? priceNpr = null,Object? district = null,Object? city = null,Object? propertyType = null,Object? listingPurpose = null,Object? status = null,Object? description = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? ward = freezed,Object? roadAccessFt = freezed,Object? bedrooms = freezed,Object? bathrooms = freezed,Object? rejectionReason = freezed,Object? submittedAt = freezed,Object? photos = null,Object? seller = freezed,Object? areaDisplay = freezed,Object? isFavorite = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ListingDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,areaSqm: freezed == areaSqm ? _self.areaSqm : areaSqm // ignore: cast_nullable_to_non_nullable
as double?,areaRopani: freezed == areaRopani ? _self.areaRopani : areaRopani // ignore: cast_nullable_to_non_nullable
as int?,areaAana: freezed == areaAana ? _self.areaAana : areaAana // ignore: cast_nullable_to_non_nullable
as int?,areaPaisa: freezed == areaPaisa ? _self.areaPaisa : areaPaisa // ignore: cast_nullable_to_non_nullable
as int?,areaDam: freezed == areaDam ? _self.areaDam : areaDam // ignore: cast_nullable_to_non_nullable
as int?,areaBigha: freezed == areaBigha ? _self.areaBigha : areaBigha // ignore: cast_nullable_to_non_nullable
as int?,areaKattha: freezed == areaKattha ? _self.areaKattha : areaKattha // ignore: cast_nullable_to_non_nullable
as int?,areaDhur: freezed == areaDhur ? _self.areaDhur : areaDhur // ignore: cast_nullable_to_non_nullable
as int?,ward: freezed == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String?,roadAccessFt: freezed == roadAccessFt ? _self.roadAccessFt : roadAccessFt // ignore: cast_nullable_to_non_nullable
as int?,bedrooms: freezed == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int?,bathrooms: freezed == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as ListingSeller?,areaDisplay: freezed == areaDisplay ? _self.areaDisplay : areaDisplay // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingSellerCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $ListingSellerCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}

// dart format on
