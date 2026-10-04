// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingSummary {

 String get id; String get sellerId; String get title; int get priceNpr; String get district; String get city; PropertyType get propertyType; ListingPurpose get listingPurpose; ListingStatus get status; String? get description; double? get areaSqm; int? get areaRopani; int? get areaAana; int? get areaPaisa; int? get areaDam; int? get areaBigha; int? get areaKattha; int? get areaDhur; String? get ward; int? get roadAccessFt;/// Cover photo, already joined server-side (no N+1).
 String? get photoUrl;/// Whether the *seller* is KYC-verified, not the listing.
 bool? get isVerified; String? get sellerName;/// Pre-formatted area in the units the seller supplied, e.g.
/// `5 aana 4 paisa` for hill districts and `1 bigha` for terai. Falls back
/// to `1200 sqm`. Computed in SQL so cards, search results and the detail
/// page can never disagree on how an area reads (Rule 25).
 String? get areaDisplay; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingSummaryCopyWith<ListingSummary> get copyWith => _$ListingSummaryCopyWithImpl<ListingSummary>(this as ListingSummary, _$identity);

  /// Serializes this ListingSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.priceNpr, _this.priceNpr) || other.priceNpr == _this.priceNpr)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.listingPurpose, _this.listingPurpose) || other.listingPurpose == _this.listingPurpose)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.areaSqm, _this.areaSqm) || other.areaSqm == _this.areaSqm)&&(identical(other.areaRopani, _this.areaRopani) || other.areaRopani == _this.areaRopani)&&(identical(other.areaAana, _this.areaAana) || other.areaAana == _this.areaAana)&&(identical(other.areaPaisa, _this.areaPaisa) || other.areaPaisa == _this.areaPaisa)&&(identical(other.areaDam, _this.areaDam) || other.areaDam == _this.areaDam)&&(identical(other.areaBigha, _this.areaBigha) || other.areaBigha == _this.areaBigha)&&(identical(other.areaKattha, _this.areaKattha) || other.areaKattha == _this.areaKattha)&&(identical(other.areaDhur, _this.areaDhur) || other.areaDhur == _this.areaDhur)&&(identical(other.ward, _this.ward) || other.ward == _this.ward)&&(identical(other.roadAccessFt, _this.roadAccessFt) || other.roadAccessFt == _this.roadAccessFt)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.sellerName, _this.sellerName) || other.sellerName == _this.sellerName)&&(identical(other.areaDisplay, _this.areaDisplay) || other.areaDisplay == _this.areaDisplay)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingSummary;
  return Object.hashAll([runtimeType,_this.id,_this.sellerId,_this.title,_this.priceNpr,_this.district,_this.city,_this.propertyType,_this.listingPurpose,_this.status,_this.description,_this.areaSqm,_this.areaRopani,_this.areaAana,_this.areaPaisa,_this.areaDam,_this.areaBigha,_this.areaKattha,_this.areaDhur,_this.ward,_this.roadAccessFt,_this.photoUrl,_this.isVerified,_this.sellerName,_this.areaDisplay,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as ListingSummary;
  return 'ListingSummary(id: ${_this.id}, sellerId: ${_this.sellerId}, title: ${_this.title}, priceNpr: ${_this.priceNpr}, district: ${_this.district}, city: ${_this.city}, propertyType: ${_this.propertyType}, listingPurpose: ${_this.listingPurpose}, status: ${_this.status}, description: ${_this.description}, areaSqm: ${_this.areaSqm}, areaRopani: ${_this.areaRopani}, areaAana: ${_this.areaAana}, areaPaisa: ${_this.areaPaisa}, areaDam: ${_this.areaDam}, areaBigha: ${_this.areaBigha}, areaKattha: ${_this.areaKattha}, areaDhur: ${_this.areaDhur}, ward: ${_this.ward}, roadAccessFt: ${_this.roadAccessFt}, photoUrl: ${_this.photoUrl}, isVerified: ${_this.isVerified}, sellerName: ${_this.sellerName}, areaDisplay: ${_this.areaDisplay}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ListingSummaryCopyWith<$Res>  {
  factory $ListingSummaryCopyWith(ListingSummary value, $Res Function(ListingSummary) _then) = _$ListingSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, String title, int priceNpr, String district, String city, PropertyType propertyType, ListingPurpose listingPurpose, ListingStatus status, String? description, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? ward, int? roadAccessFt, String? photoUrl, bool? isVerified, String? sellerName, String? areaDisplay, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ListingSummaryCopyWithImpl<$Res>
    implements $ListingSummaryCopyWith<$Res> {
  _$ListingSummaryCopyWithImpl(this._self, this._then);

  final ListingSummary _self;
  final $Res Function(ListingSummary) _then;

/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? title = null,Object? priceNpr = null,Object? district = null,Object? city = null,Object? propertyType = null,Object? listingPurpose = null,Object? status = null,Object? description = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? ward = freezed,Object? roadAccessFt = freezed,Object? photoUrl = freezed,Object? isVerified = freezed,Object? sellerName = freezed,Object? areaDisplay = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(ListingSummary(
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
as int?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,areaDisplay: freezed == areaDisplay ? _self.areaDisplay : areaDisplay // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingSummary].
extension ListingSummaryPatterns on ListingSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingSummary value)  $default,){
final _that = this;
switch (_that) {
case _ListingSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  String title,  int priceNpr,  String district,  String city,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  String? photoUrl,  bool? isVerified,  String? sellerName,  String? areaDisplay,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
return $default(_that.id,_that.sellerId,_that.title,_that.priceNpr,_that.district,_that.city,_that.propertyType,_that.listingPurpose,_that.status,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.photoUrl,_that.isVerified,_that.sellerName,_that.areaDisplay,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  String title,  int priceNpr,  String district,  String city,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  String? photoUrl,  bool? isVerified,  String? sellerName,  String? areaDisplay,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ListingSummary():
return $default(_that.id,_that.sellerId,_that.title,_that.priceNpr,_that.district,_that.city,_that.propertyType,_that.listingPurpose,_that.status,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.photoUrl,_that.isVerified,_that.sellerName,_that.areaDisplay,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  String title,  int priceNpr,  String district,  String city,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  String? photoUrl,  bool? isVerified,  String? sellerName,  String? areaDisplay,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
return $default(_that.id,_that.sellerId,_that.title,_that.priceNpr,_that.district,_that.city,_that.propertyType,_that.listingPurpose,_that.status,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.photoUrl,_that.isVerified,_that.sellerName,_that.areaDisplay,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ListingSummary implements ListingSummary {
  const _ListingSummary({required this.id, required this.sellerId, required this.title, required this.priceNpr, required this.district, required this.city, required this.propertyType, required this.listingPurpose, this.status = ListingStatus.draft, this.description, this.areaSqm, this.areaRopani, this.areaAana, this.areaPaisa, this.areaDam, this.areaBigha, this.areaKattha, this.areaDhur, this.ward, this.roadAccessFt, this.photoUrl, this.isVerified, this.sellerName, this.areaDisplay, this.createdAt, this.updatedAt});
  factory _ListingSummary.fromJson(Map<String, dynamic> json) => _$ListingSummaryFromJson(json);

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
/// Cover photo, already joined server-side (no N+1).
@override final  String? photoUrl;
/// Whether the *seller* is KYC-verified, not the listing.
@override final  bool? isVerified;
@override final  String? sellerName;
/// Pre-formatted area in the units the seller supplied, e.g.
/// `5 aana 4 paisa` for hill districts and `1 bigha` for terai. Falls back
/// to `1200 sqm`. Computed in SQL so cards, search results and the detail
/// page can never disagree on how an area reads (Rule 25).
@override final  String? areaDisplay;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingSummaryCopyWith<_ListingSummary> get copyWith => __$ListingSummaryCopyWithImpl<_ListingSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceNpr, priceNpr) || other.priceNpr == priceNpr)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.listingPurpose, listingPurpose) || other.listingPurpose == listingPurpose)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm)&&(identical(other.areaRopani, areaRopani) || other.areaRopani == areaRopani)&&(identical(other.areaAana, areaAana) || other.areaAana == areaAana)&&(identical(other.areaPaisa, areaPaisa) || other.areaPaisa == areaPaisa)&&(identical(other.areaDam, areaDam) || other.areaDam == areaDam)&&(identical(other.areaBigha, areaBigha) || other.areaBigha == areaBigha)&&(identical(other.areaKattha, areaKattha) || other.areaKattha == areaKattha)&&(identical(other.areaDhur, areaDhur) || other.areaDhur == areaDhur)&&(identical(other.ward, ward) || other.ward == ward)&&(identical(other.roadAccessFt, roadAccessFt) || other.roadAccessFt == roadAccessFt)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.areaDisplay, areaDisplay) || other.areaDisplay == areaDisplay)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sellerId,title,priceNpr,district,city,propertyType,listingPurpose,status,description,areaSqm,areaRopani,areaAana,areaPaisa,areaDam,areaBigha,areaKattha,areaDhur,ward,roadAccessFt,photoUrl,isVerified,sellerName,areaDisplay,createdAt,updatedAt]);
}

@override
String toString() {
    return 'ListingSummary(id: $id, sellerId: $sellerId, title: $title, priceNpr: $priceNpr, district: $district, city: $city, propertyType: $propertyType, listingPurpose: $listingPurpose, status: $status, description: $description, areaSqm: $areaSqm, areaRopani: $areaRopani, areaAana: $areaAana, areaPaisa: $areaPaisa, areaDam: $areaDam, areaBigha: $areaBigha, areaKattha: $areaKattha, areaDhur: $areaDhur, ward: $ward, roadAccessFt: $roadAccessFt, photoUrl: $photoUrl, isVerified: $isVerified, sellerName: $sellerName, areaDisplay: $areaDisplay, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingSummaryCopyWith<$Res> implements $ListingSummaryCopyWith<$Res> {
  factory _$ListingSummaryCopyWith(_ListingSummary value, $Res Function(_ListingSummary) _then) = __$ListingSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, String title, int priceNpr, String district, String city, PropertyType propertyType, ListingPurpose listingPurpose, ListingStatus status, String? description, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? ward, int? roadAccessFt, String? photoUrl, bool? isVerified, String? sellerName, String? areaDisplay, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ListingSummaryCopyWithImpl<$Res>
    implements _$ListingSummaryCopyWith<$Res> {
  __$ListingSummaryCopyWithImpl(this._self, this._then);

  final _ListingSummary _self;
  final $Res Function(_ListingSummary) _then;

/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? title = null,Object? priceNpr = null,Object? district = null,Object? city = null,Object? propertyType = null,Object? listingPurpose = null,Object? status = null,Object? description = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? ward = freezed,Object? roadAccessFt = freezed,Object? photoUrl = freezed,Object? isVerified = freezed,Object? sellerName = freezed,Object? areaDisplay = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ListingSummary(
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
as int?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,areaDisplay: freezed == areaDisplay ? _self.areaDisplay : areaDisplay // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
