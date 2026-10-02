// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Listing {

 String get id; String get sellerId; PropertyType get propertyType; ListingPurpose get listingPurpose; String get title; String? get description; int get priceNpr; double? get areaSqm; int? get areaRopani; int? get areaAana; int? get areaPaisa; int? get areaDam; int? get areaBigha; int? get areaKattha; int? get areaDhur; String get district; String get city; String? get ward; int? get roadAccessFt; ListingStatus get status; String? get rejectionReason; DateTime? get createdAt; DateTime? get updatedAt; String? get reviewedBy; DateTime? get reviewedAt;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Listing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.listingPurpose, _this.listingPurpose) || other.listingPurpose == _this.listingPurpose)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.priceNpr, _this.priceNpr) || other.priceNpr == _this.priceNpr)&&(identical(other.areaSqm, _this.areaSqm) || other.areaSqm == _this.areaSqm)&&(identical(other.areaRopani, _this.areaRopani) || other.areaRopani == _this.areaRopani)&&(identical(other.areaAana, _this.areaAana) || other.areaAana == _this.areaAana)&&(identical(other.areaPaisa, _this.areaPaisa) || other.areaPaisa == _this.areaPaisa)&&(identical(other.areaDam, _this.areaDam) || other.areaDam == _this.areaDam)&&(identical(other.areaBigha, _this.areaBigha) || other.areaBigha == _this.areaBigha)&&(identical(other.areaKattha, _this.areaKattha) || other.areaKattha == _this.areaKattha)&&(identical(other.areaDhur, _this.areaDhur) || other.areaDhur == _this.areaDhur)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.ward, _this.ward) || other.ward == _this.ward)&&(identical(other.roadAccessFt, _this.roadAccessFt) || other.roadAccessFt == _this.roadAccessFt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rejectionReason, _this.rejectionReason) || other.rejectionReason == _this.rejectionReason)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.reviewedBy, _this.reviewedBy) || other.reviewedBy == _this.reviewedBy)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Listing;
  return Object.hashAll([runtimeType,_this.id,_this.sellerId,_this.propertyType,_this.listingPurpose,_this.title,_this.description,_this.priceNpr,_this.areaSqm,_this.areaRopani,_this.areaAana,_this.areaPaisa,_this.areaDam,_this.areaBigha,_this.areaKattha,_this.areaDhur,_this.district,_this.city,_this.ward,_this.roadAccessFt,_this.status,_this.rejectionReason,_this.createdAt,_this.updatedAt,_this.reviewedBy,_this.reviewedAt]);
}

@override
String toString() {
  final _this = this as Listing;
  return 'Listing(id: ${_this.id}, sellerId: ${_this.sellerId}, propertyType: ${_this.propertyType}, listingPurpose: ${_this.listingPurpose}, title: ${_this.title}, description: ${_this.description}, priceNpr: ${_this.priceNpr}, areaSqm: ${_this.areaSqm}, areaRopani: ${_this.areaRopani}, areaAana: ${_this.areaAana}, areaPaisa: ${_this.areaPaisa}, areaDam: ${_this.areaDam}, areaBigha: ${_this.areaBigha}, areaKattha: ${_this.areaKattha}, areaDhur: ${_this.areaDhur}, district: ${_this.district}, city: ${_this.city}, ward: ${_this.ward}, roadAccessFt: ${_this.roadAccessFt}, status: ${_this.status}, rejectionReason: ${_this.rejectionReason}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, reviewedBy: ${_this.reviewedBy}, reviewedAt: ${_this.reviewedAt})';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, PropertyType propertyType, ListingPurpose listingPurpose, String title, String? description, int priceNpr, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String district, String city, String? ward, int? roadAccessFt, ListingStatus status, String? rejectionReason, DateTime? createdAt, DateTime? updatedAt, String? reviewedBy, DateTime? reviewedAt
});




}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? propertyType = null,Object? listingPurpose = null,Object? title = null,Object? description = freezed,Object? priceNpr = null,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? district = null,Object? city = null,Object? ward = freezed,Object? roadAccessFt = freezed,Object? status = null,Object? rejectionReason = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,}) {
  return _then(Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,areaSqm: freezed == areaSqm ? _self.areaSqm : areaSqm // ignore: cast_nullable_to_non_nullable
as double?,areaRopani: freezed == areaRopani ? _self.areaRopani : areaRopani // ignore: cast_nullable_to_non_nullable
as int?,areaAana: freezed == areaAana ? _self.areaAana : areaAana // ignore: cast_nullable_to_non_nullable
as int?,areaPaisa: freezed == areaPaisa ? _self.areaPaisa : areaPaisa // ignore: cast_nullable_to_non_nullable
as int?,areaDam: freezed == areaDam ? _self.areaDam : areaDam // ignore: cast_nullable_to_non_nullable
as int?,areaBigha: freezed == areaBigha ? _self.areaBigha : areaBigha // ignore: cast_nullable_to_non_nullable
as int?,areaKattha: freezed == areaKattha ? _self.areaKattha : areaKattha // ignore: cast_nullable_to_non_nullable
as int?,areaDhur: freezed == areaDhur ? _self.areaDhur : areaDhur // ignore: cast_nullable_to_non_nullable
as int?,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,ward: freezed == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String?,roadAccessFt: freezed == roadAccessFt ? _self.roadAccessFt : roadAccessFt // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  PropertyType propertyType,  ListingPurpose listingPurpose,  String title,  String? description,  int priceNpr,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String district,  String city,  String? ward,  int? roadAccessFt,  ListingStatus status,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt,  String? reviewedBy,  DateTime? reviewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.propertyType,_that.listingPurpose,_that.title,_that.description,_that.priceNpr,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.district,_that.city,_that.ward,_that.roadAccessFt,_that.status,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.reviewedBy,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  PropertyType propertyType,  ListingPurpose listingPurpose,  String title,  String? description,  int priceNpr,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String district,  String city,  String? ward,  int? roadAccessFt,  ListingStatus status,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt,  String? reviewedBy,  DateTime? reviewedAt)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.sellerId,_that.propertyType,_that.listingPurpose,_that.title,_that.description,_that.priceNpr,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.district,_that.city,_that.ward,_that.roadAccessFt,_that.status,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.reviewedBy,_that.reviewedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  PropertyType propertyType,  ListingPurpose listingPurpose,  String title,  String? description,  int priceNpr,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String district,  String city,  String? ward,  int? roadAccessFt,  ListingStatus status,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt,  String? reviewedBy,  DateTime? reviewedAt)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.propertyType,_that.listingPurpose,_that.title,_that.description,_that.priceNpr,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.district,_that.city,_that.ward,_that.roadAccessFt,_that.status,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.reviewedBy,_that.reviewedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Listing implements Listing {
  const _Listing({required this.id, required this.sellerId, required this.propertyType, required this.listingPurpose, required this.title, this.description, required this.priceNpr, this.areaSqm, this.areaRopani, this.areaAana, this.areaPaisa, this.areaDam, this.areaBigha, this.areaKattha, this.areaDhur, required this.district, required this.city, this.ward, this.roadAccessFt, this.status = ListingStatus.draft, this.rejectionReason, this.createdAt, this.updatedAt, this.reviewedBy, this.reviewedAt});
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override final  String sellerId;
@override final  PropertyType propertyType;
@override final  ListingPurpose listingPurpose;
@override final  String title;
@override final  String? description;
@override final  int priceNpr;
@override final  double? areaSqm;
@override final  int? areaRopani;
@override final  int? areaAana;
@override final  int? areaPaisa;
@override final  int? areaDam;
@override final  int? areaBigha;
@override final  int? areaKattha;
@override final  int? areaDhur;
@override final  String district;
@override final  String city;
@override final  String? ward;
@override final  int? roadAccessFt;
@override@JsonKey() final  ListingStatus status;
@override final  String? rejectionReason;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  String? reviewedBy;
@override final  DateTime? reviewedAt;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.listingPurpose, listingPurpose) || other.listingPurpose == listingPurpose)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceNpr, priceNpr) || other.priceNpr == priceNpr)&&(identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm)&&(identical(other.areaRopani, areaRopani) || other.areaRopani == areaRopani)&&(identical(other.areaAana, areaAana) || other.areaAana == areaAana)&&(identical(other.areaPaisa, areaPaisa) || other.areaPaisa == areaPaisa)&&(identical(other.areaDam, areaDam) || other.areaDam == areaDam)&&(identical(other.areaBigha, areaBigha) || other.areaBigha == areaBigha)&&(identical(other.areaKattha, areaKattha) || other.areaKattha == areaKattha)&&(identical(other.areaDhur, areaDhur) || other.areaDhur == areaDhur)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.ward, ward) || other.ward == ward)&&(identical(other.roadAccessFt, roadAccessFt) || other.roadAccessFt == roadAccessFt)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sellerId,propertyType,listingPurpose,title,description,priceNpr,areaSqm,areaRopani,areaAana,areaPaisa,areaDam,areaBigha,areaKattha,areaDhur,district,city,ward,roadAccessFt,status,rejectionReason,createdAt,updatedAt,reviewedBy,reviewedAt]);
}

@override
String toString() {
    return 'Listing(id: $id, sellerId: $sellerId, propertyType: $propertyType, listingPurpose: $listingPurpose, title: $title, description: $description, priceNpr: $priceNpr, areaSqm: $areaSqm, areaRopani: $areaRopani, areaAana: $areaAana, areaPaisa: $areaPaisa, areaDam: $areaDam, areaBigha: $areaBigha, areaKattha: $areaKattha, areaDhur: $areaDhur, district: $district, city: $city, ward: $ward, roadAccessFt: $roadAccessFt, status: $status, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, PropertyType propertyType, ListingPurpose listingPurpose, String title, String? description, int priceNpr, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String district, String city, String? ward, int? roadAccessFt, ListingStatus status, String? rejectionReason, DateTime? createdAt, DateTime? updatedAt, String? reviewedBy, DateTime? reviewedAt
});




}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? propertyType = null,Object? listingPurpose = null,Object? title = null,Object? description = freezed,Object? priceNpr = null,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? district = null,Object? city = null,Object? ward = freezed,Object? roadAccessFt = freezed,Object? status = null,Object? rejectionReason = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,areaSqm: freezed == areaSqm ? _self.areaSqm : areaSqm // ignore: cast_nullable_to_non_nullable
as double?,areaRopani: freezed == areaRopani ? _self.areaRopani : areaRopani // ignore: cast_nullable_to_non_nullable
as int?,areaAana: freezed == areaAana ? _self.areaAana : areaAana // ignore: cast_nullable_to_non_nullable
as int?,areaPaisa: freezed == areaPaisa ? _self.areaPaisa : areaPaisa // ignore: cast_nullable_to_non_nullable
as int?,areaDam: freezed == areaDam ? _self.areaDam : areaDam // ignore: cast_nullable_to_non_nullable
as int?,areaBigha: freezed == areaBigha ? _self.areaBigha : areaBigha // ignore: cast_nullable_to_non_nullable
as int?,areaKattha: freezed == areaKattha ? _self.areaKattha : areaKattha // ignore: cast_nullable_to_non_nullable
as int?,areaDhur: freezed == areaDhur ? _self.areaDhur : areaDhur // ignore: cast_nullable_to_non_nullable
as int?,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,ward: freezed == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String?,roadAccessFt: freezed == roadAccessFt ? _self.roadAccessFt : roadAccessFt // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
