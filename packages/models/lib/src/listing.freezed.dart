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

 String get id; String get sellerId; PropertyType get propertyType; ListingPurpose get listingPurpose; String get title; int get priceNpr; String get district; String get city; String? get description; double? get areaSqm; int? get areaRopani; int? get areaAana; int? get areaPaisa; int? get areaDam; int? get areaBigha; int? get areaKattha; int? get areaDhur; String? get ward; int? get roadAccessFt;/// Land parcel (kitta) number as the seller wrote it (HYA-300).
///
/// Null means "not provided" and is itself a review signal; duplicates
/// across listings are a fraud signal. Free text: numbering varies by
/// district, so the server only trims and length-caps it.
 String? get kittaNumber;/// Bedroom count.
///
/// Null rather than 0 for land and commercial premises, which have none.
/// The column carries `CHECK (bedrooms > 0)`, so a stored 0 is impossible
/// and absence is the only way to say "not applicable".
 int? get bedrooms;/// Bathroom count. Null when not applicable, as with [bedrooms].
 int? get bathrooms;/// Lease length in months. Null unless [listingPurpose] is
/// [ListingPurpose.lease]; the `listings_field_applicability` trigger
/// nulls it for every other purpose.
 int? get leaseTermMonths;/// Whether the lease can be renewed. Null unless the purpose is lease.
///
/// Nullable on purpose: "the listing does not say" is a different answer
/// from "no", and coercing it loses information the tenant would ask about.
 bool? get leaseRenewable;/// Security deposit in NPR. Null unless the purpose is rent.
///
/// Zero is a real term (no deposit asked), so the CHECK is `>= 0` rather
/// than `> 0` unlike [bedrooms].
 int? get depositAmount;/// First date the property can be occupied. Null unless the purpose is
/// rent. Stored as a date, not a timestamptz: "available from the 1st"
/// must not shift with the viewer's offset.
 DateTime? get availableFrom;/// Furnishing level. Null unless the purpose is rent, or when the seller
/// left it unstated.
 FurnishingStatus? get furnishingStatus;/// Which utilities the rent covers. Null unless the purpose is rent.
///
/// Free text capped at 200 characters server-side; anything longer
/// belongs in the description.
 String? get utilitiesIncluded;/// Pet policy. Null unless the purpose is rent, or when unstated.
 PetPolicy? get petPolicy;/// Covered or off-street parking spaces.
///
/// Null for land, which has none to count. Zero is rejected so a stored
/// value is always a real count.
 int? get parkingSpaces;/// Floor this unit is on, zero being the ground floor.
///
/// Null for house, land, villa and business premises, which have no floor
/// number to report.
 int? get floorNumber;/// How many floors the building has. Null unless the building has floors.
 int? get totalFloors;/// Age of the building in years, zero being brand new.
///
/// Null for land, which is not aged.
 int? get propertyAgeYears;/// New, under construction, or resale. Null for land.
 ConstructionStatus? get constructionStatus; ListingStatus get status; String? get rejectionReason; DateTime? get createdAt; DateTime? get updatedAt; String? get reviewedBy; DateTime? get reviewedAt;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.listingPurpose, _this.listingPurpose) || other.listingPurpose == _this.listingPurpose)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.priceNpr, _this.priceNpr) || other.priceNpr == _this.priceNpr)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.areaSqm, _this.areaSqm) || other.areaSqm == _this.areaSqm)&&(identical(other.areaRopani, _this.areaRopani) || other.areaRopani == _this.areaRopani)&&(identical(other.areaAana, _this.areaAana) || other.areaAana == _this.areaAana)&&(identical(other.areaPaisa, _this.areaPaisa) || other.areaPaisa == _this.areaPaisa)&&(identical(other.areaDam, _this.areaDam) || other.areaDam == _this.areaDam)&&(identical(other.areaBigha, _this.areaBigha) || other.areaBigha == _this.areaBigha)&&(identical(other.areaKattha, _this.areaKattha) || other.areaKattha == _this.areaKattha)&&(identical(other.areaDhur, _this.areaDhur) || other.areaDhur == _this.areaDhur)&&(identical(other.ward, _this.ward) || other.ward == _this.ward)&&(identical(other.roadAccessFt, _this.roadAccessFt) || other.roadAccessFt == _this.roadAccessFt)&&(identical(other.kittaNumber, _this.kittaNumber) || other.kittaNumber == _this.kittaNumber)&&(identical(other.bedrooms, _this.bedrooms) || other.bedrooms == _this.bedrooms)&&(identical(other.bathrooms, _this.bathrooms) || other.bathrooms == _this.bathrooms)&&(identical(other.leaseTermMonths, _this.leaseTermMonths) || other.leaseTermMonths == _this.leaseTermMonths)&&(identical(other.leaseRenewable, _this.leaseRenewable) || other.leaseRenewable == _this.leaseRenewable)&&(identical(other.depositAmount, _this.depositAmount) || other.depositAmount == _this.depositAmount)&&(identical(other.availableFrom, _this.availableFrom) || other.availableFrom == _this.availableFrom)&&(identical(other.furnishingStatus, _this.furnishingStatus) || other.furnishingStatus == _this.furnishingStatus)&&(identical(other.utilitiesIncluded, _this.utilitiesIncluded) || other.utilitiesIncluded == _this.utilitiesIncluded)&&(identical(other.petPolicy, _this.petPolicy) || other.petPolicy == _this.petPolicy)&&(identical(other.parkingSpaces, _this.parkingSpaces) || other.parkingSpaces == _this.parkingSpaces)&&(identical(other.floorNumber, _this.floorNumber) || other.floorNumber == _this.floorNumber)&&(identical(other.totalFloors, _this.totalFloors) || other.totalFloors == _this.totalFloors)&&(identical(other.propertyAgeYears, _this.propertyAgeYears) || other.propertyAgeYears == _this.propertyAgeYears)&&(identical(other.constructionStatus, _this.constructionStatus) || other.constructionStatus == _this.constructionStatus)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rejectionReason, _this.rejectionReason) || other.rejectionReason == _this.rejectionReason)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.reviewedBy, _this.reviewedBy) || other.reviewedBy == _this.reviewedBy)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Listing;
  return Object.hashAll([runtimeType,_this.id,_this.sellerId,_this.propertyType,_this.listingPurpose,_this.title,_this.priceNpr,_this.district,_this.city,_this.description,_this.areaSqm,_this.areaRopani,_this.areaAana,_this.areaPaisa,_this.areaDam,_this.areaBigha,_this.areaKattha,_this.areaDhur,_this.ward,_this.roadAccessFt,_this.kittaNumber,_this.bedrooms,_this.bathrooms,_this.leaseTermMonths,_this.leaseRenewable,_this.depositAmount,_this.availableFrom,_this.furnishingStatus,_this.utilitiesIncluded,_this.petPolicy,_this.parkingSpaces,_this.floorNumber,_this.totalFloors,_this.propertyAgeYears,_this.constructionStatus,_this.status,_this.rejectionReason,_this.createdAt,_this.updatedAt,_this.reviewedBy,_this.reviewedAt]);
}

@override
String toString() {
  final _this = this as Listing;
  return 'Listing(id: ${_this.id}, sellerId: ${_this.sellerId}, propertyType: ${_this.propertyType}, listingPurpose: ${_this.listingPurpose}, title: ${_this.title}, priceNpr: ${_this.priceNpr}, district: ${_this.district}, city: ${_this.city}, description: ${_this.description}, areaSqm: ${_this.areaSqm}, areaRopani: ${_this.areaRopani}, areaAana: ${_this.areaAana}, areaPaisa: ${_this.areaPaisa}, areaDam: ${_this.areaDam}, areaBigha: ${_this.areaBigha}, areaKattha: ${_this.areaKattha}, areaDhur: ${_this.areaDhur}, ward: ${_this.ward}, roadAccessFt: ${_this.roadAccessFt}, kittaNumber: ${_this.kittaNumber}, bedrooms: ${_this.bedrooms}, bathrooms: ${_this.bathrooms}, leaseTermMonths: ${_this.leaseTermMonths}, leaseRenewable: ${_this.leaseRenewable}, depositAmount: ${_this.depositAmount}, availableFrom: ${_this.availableFrom}, furnishingStatus: ${_this.furnishingStatus}, utilitiesIncluded: ${_this.utilitiesIncluded}, petPolicy: ${_this.petPolicy}, parkingSpaces: ${_this.parkingSpaces}, floorNumber: ${_this.floorNumber}, totalFloors: ${_this.totalFloors}, propertyAgeYears: ${_this.propertyAgeYears}, constructionStatus: ${_this.constructionStatus}, status: ${_this.status}, rejectionReason: ${_this.rejectionReason}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, reviewedBy: ${_this.reviewedBy}, reviewedAt: ${_this.reviewedAt})';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, PropertyType propertyType, ListingPurpose listingPurpose, String title, int priceNpr, String district, String city, String? description, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? ward, int? roadAccessFt, String? kittaNumber, int? bedrooms, int? bathrooms, int? leaseTermMonths, bool? leaseRenewable, int? depositAmount, DateTime? availableFrom, FurnishingStatus? furnishingStatus, String? utilitiesIncluded, PetPolicy? petPolicy, int? parkingSpaces, int? floorNumber, int? totalFloors, int? propertyAgeYears, ConstructionStatus? constructionStatus, ListingStatus status, String? rejectionReason, DateTime? createdAt, DateTime? updatedAt, String? reviewedBy, DateTime? reviewedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? propertyType = null,Object? listingPurpose = null,Object? title = null,Object? priceNpr = null,Object? district = null,Object? city = null,Object? description = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? ward = freezed,Object? roadAccessFt = freezed,Object? kittaNumber = freezed,Object? bedrooms = freezed,Object? bathrooms = freezed,Object? leaseTermMonths = freezed,Object? leaseRenewable = freezed,Object? depositAmount = freezed,Object? availableFrom = freezed,Object? furnishingStatus = freezed,Object? utilitiesIncluded = freezed,Object? petPolicy = freezed,Object? parkingSpaces = freezed,Object? floorNumber = freezed,Object? totalFloors = freezed,Object? propertyAgeYears = freezed,Object? constructionStatus = freezed,Object? status = null,Object? rejectionReason = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,}) {
  return _then(Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
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
as int?,kittaNumber: freezed == kittaNumber ? _self.kittaNumber : kittaNumber // ignore: cast_nullable_to_non_nullable
as String?,bedrooms: freezed == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int?,bathrooms: freezed == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int?,leaseTermMonths: freezed == leaseTermMonths ? _self.leaseTermMonths : leaseTermMonths // ignore: cast_nullable_to_non_nullable
as int?,leaseRenewable: freezed == leaseRenewable ? _self.leaseRenewable : leaseRenewable // ignore: cast_nullable_to_non_nullable
as bool?,depositAmount: freezed == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as int?,availableFrom: freezed == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,furnishingStatus: freezed == furnishingStatus ? _self.furnishingStatus : furnishingStatus // ignore: cast_nullable_to_non_nullable
as FurnishingStatus?,utilitiesIncluded: freezed == utilitiesIncluded ? _self.utilitiesIncluded : utilitiesIncluded // ignore: cast_nullable_to_non_nullable
as String?,petPolicy: freezed == petPolicy ? _self.petPolicy : petPolicy // ignore: cast_nullable_to_non_nullable
as PetPolicy?,parkingSpaces: freezed == parkingSpaces ? _self.parkingSpaces : parkingSpaces // ignore: cast_nullable_to_non_nullable
as int?,floorNumber: freezed == floorNumber ? _self.floorNumber : floorNumber // ignore: cast_nullable_to_non_nullable
as int?,totalFloors: freezed == totalFloors ? _self.totalFloors : totalFloors // ignore: cast_nullable_to_non_nullable
as int?,propertyAgeYears: freezed == propertyAgeYears ? _self.propertyAgeYears : propertyAgeYears // ignore: cast_nullable_to_non_nullable
as int?,constructionStatus: freezed == constructionStatus ? _self.constructionStatus : constructionStatus // ignore: cast_nullable_to_non_nullable
as ConstructionStatus?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  PropertyType propertyType,  ListingPurpose listingPurpose,  String title,  int priceNpr,  String district,  String city,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  String? kittaNumber,  int? bedrooms,  int? bathrooms,  int? leaseTermMonths,  bool? leaseRenewable,  int? depositAmount,  DateTime? availableFrom,  FurnishingStatus? furnishingStatus,  String? utilitiesIncluded,  PetPolicy? petPolicy,  int? parkingSpaces,  int? floorNumber,  int? totalFloors,  int? propertyAgeYears,  ConstructionStatus? constructionStatus,  ListingStatus status,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt,  String? reviewedBy,  DateTime? reviewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.propertyType,_that.listingPurpose,_that.title,_that.priceNpr,_that.district,_that.city,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.kittaNumber,_that.bedrooms,_that.bathrooms,_that.leaseTermMonths,_that.leaseRenewable,_that.depositAmount,_that.availableFrom,_that.furnishingStatus,_that.utilitiesIncluded,_that.petPolicy,_that.parkingSpaces,_that.floorNumber,_that.totalFloors,_that.propertyAgeYears,_that.constructionStatus,_that.status,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.reviewedBy,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  PropertyType propertyType,  ListingPurpose listingPurpose,  String title,  int priceNpr,  String district,  String city,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  String? kittaNumber,  int? bedrooms,  int? bathrooms,  int? leaseTermMonths,  bool? leaseRenewable,  int? depositAmount,  DateTime? availableFrom,  FurnishingStatus? furnishingStatus,  String? utilitiesIncluded,  PetPolicy? petPolicy,  int? parkingSpaces,  int? floorNumber,  int? totalFloors,  int? propertyAgeYears,  ConstructionStatus? constructionStatus,  ListingStatus status,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt,  String? reviewedBy,  DateTime? reviewedAt)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.sellerId,_that.propertyType,_that.listingPurpose,_that.title,_that.priceNpr,_that.district,_that.city,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.kittaNumber,_that.bedrooms,_that.bathrooms,_that.leaseTermMonths,_that.leaseRenewable,_that.depositAmount,_that.availableFrom,_that.furnishingStatus,_that.utilitiesIncluded,_that.petPolicy,_that.parkingSpaces,_that.floorNumber,_that.totalFloors,_that.propertyAgeYears,_that.constructionStatus,_that.status,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.reviewedBy,_that.reviewedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  PropertyType propertyType,  ListingPurpose listingPurpose,  String title,  int priceNpr,  String district,  String city,  String? description,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? ward,  int? roadAccessFt,  String? kittaNumber,  int? bedrooms,  int? bathrooms,  int? leaseTermMonths,  bool? leaseRenewable,  int? depositAmount,  DateTime? availableFrom,  FurnishingStatus? furnishingStatus,  String? utilitiesIncluded,  PetPolicy? petPolicy,  int? parkingSpaces,  int? floorNumber,  int? totalFloors,  int? propertyAgeYears,  ConstructionStatus? constructionStatus,  ListingStatus status,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt,  String? reviewedBy,  DateTime? reviewedAt)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.propertyType,_that.listingPurpose,_that.title,_that.priceNpr,_that.district,_that.city,_that.description,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.ward,_that.roadAccessFt,_that.kittaNumber,_that.bedrooms,_that.bathrooms,_that.leaseTermMonths,_that.leaseRenewable,_that.depositAmount,_that.availableFrom,_that.furnishingStatus,_that.utilitiesIncluded,_that.petPolicy,_that.parkingSpaces,_that.floorNumber,_that.totalFloors,_that.propertyAgeYears,_that.constructionStatus,_that.status,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.reviewedBy,_that.reviewedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Listing implements Listing {
  const _Listing({required this.id, required this.sellerId, required this.propertyType, required this.listingPurpose, required this.title, required this.priceNpr, required this.district, required this.city, this.description, this.areaSqm, this.areaRopani, this.areaAana, this.areaPaisa, this.areaDam, this.areaBigha, this.areaKattha, this.areaDhur, this.ward, this.roadAccessFt, this.kittaNumber, this.bedrooms, this.bathrooms, this.leaseTermMonths, this.leaseRenewable, this.depositAmount, this.availableFrom, this.furnishingStatus, this.utilitiesIncluded, this.petPolicy, this.parkingSpaces, this.floorNumber, this.totalFloors, this.propertyAgeYears, this.constructionStatus, this.status = ListingStatus.draft, this.rejectionReason, this.createdAt, this.updatedAt, this.reviewedBy, this.reviewedAt});
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override final  String sellerId;
@override final  PropertyType propertyType;
@override final  ListingPurpose listingPurpose;
@override final  String title;
@override final  int priceNpr;
@override final  String district;
@override final  String city;
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
/// Land parcel (kitta) number as the seller wrote it (HYA-300).
///
/// Null means "not provided" and is itself a review signal; duplicates
/// across listings are a fraud signal. Free text: numbering varies by
/// district, so the server only trims and length-caps it.
@override final  String? kittaNumber;
/// Bedroom count.
///
/// Null rather than 0 for land and commercial premises, which have none.
/// The column carries `CHECK (bedrooms > 0)`, so a stored 0 is impossible
/// and absence is the only way to say "not applicable".
@override final  int? bedrooms;
/// Bathroom count. Null when not applicable, as with [bedrooms].
@override final  int? bathrooms;
/// Lease length in months. Null unless [listingPurpose] is
/// [ListingPurpose.lease]; the `listings_field_applicability` trigger
/// nulls it for every other purpose.
@override final  int? leaseTermMonths;
/// Whether the lease can be renewed. Null unless the purpose is lease.
///
/// Nullable on purpose: "the listing does not say" is a different answer
/// from "no", and coercing it loses information the tenant would ask about.
@override final  bool? leaseRenewable;
/// Security deposit in NPR. Null unless the purpose is rent.
///
/// Zero is a real term (no deposit asked), so the CHECK is `>= 0` rather
/// than `> 0` unlike [bedrooms].
@override final  int? depositAmount;
/// First date the property can be occupied. Null unless the purpose is
/// rent. Stored as a date, not a timestamptz: "available from the 1st"
/// must not shift with the viewer's offset.
@override final  DateTime? availableFrom;
/// Furnishing level. Null unless the purpose is rent, or when the seller
/// left it unstated.
@override final  FurnishingStatus? furnishingStatus;
/// Which utilities the rent covers. Null unless the purpose is rent.
///
/// Free text capped at 200 characters server-side; anything longer
/// belongs in the description.
@override final  String? utilitiesIncluded;
/// Pet policy. Null unless the purpose is rent, or when unstated.
@override final  PetPolicy? petPolicy;
/// Covered or off-street parking spaces.
///
/// Null for land, which has none to count. Zero is rejected so a stored
/// value is always a real count.
@override final  int? parkingSpaces;
/// Floor this unit is on, zero being the ground floor.
///
/// Null for house, land, villa and business premises, which have no floor
/// number to report.
@override final  int? floorNumber;
/// How many floors the building has. Null unless the building has floors.
@override final  int? totalFloors;
/// Age of the building in years, zero being brand new.
///
/// Null for land, which is not aged.
@override final  int? propertyAgeYears;
/// New, under construction, or resale. Null for land.
@override final  ConstructionStatus? constructionStatus;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.listingPurpose, listingPurpose) || other.listingPurpose == listingPurpose)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceNpr, priceNpr) || other.priceNpr == priceNpr)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.description, description) || other.description == description)&&(identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm)&&(identical(other.areaRopani, areaRopani) || other.areaRopani == areaRopani)&&(identical(other.areaAana, areaAana) || other.areaAana == areaAana)&&(identical(other.areaPaisa, areaPaisa) || other.areaPaisa == areaPaisa)&&(identical(other.areaDam, areaDam) || other.areaDam == areaDam)&&(identical(other.areaBigha, areaBigha) || other.areaBigha == areaBigha)&&(identical(other.areaKattha, areaKattha) || other.areaKattha == areaKattha)&&(identical(other.areaDhur, areaDhur) || other.areaDhur == areaDhur)&&(identical(other.ward, ward) || other.ward == ward)&&(identical(other.roadAccessFt, roadAccessFt) || other.roadAccessFt == roadAccessFt)&&(identical(other.kittaNumber, kittaNumber) || other.kittaNumber == kittaNumber)&&(identical(other.bedrooms, bedrooms) || other.bedrooms == bedrooms)&&(identical(other.bathrooms, bathrooms) || other.bathrooms == bathrooms)&&(identical(other.leaseTermMonths, leaseTermMonths) || other.leaseTermMonths == leaseTermMonths)&&(identical(other.leaseRenewable, leaseRenewable) || other.leaseRenewable == leaseRenewable)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.furnishingStatus, furnishingStatus) || other.furnishingStatus == furnishingStatus)&&(identical(other.utilitiesIncluded, utilitiesIncluded) || other.utilitiesIncluded == utilitiesIncluded)&&(identical(other.petPolicy, petPolicy) || other.petPolicy == petPolicy)&&(identical(other.parkingSpaces, parkingSpaces) || other.parkingSpaces == parkingSpaces)&&(identical(other.floorNumber, floorNumber) || other.floorNumber == floorNumber)&&(identical(other.totalFloors, totalFloors) || other.totalFloors == totalFloors)&&(identical(other.propertyAgeYears, propertyAgeYears) || other.propertyAgeYears == propertyAgeYears)&&(identical(other.constructionStatus, constructionStatus) || other.constructionStatus == constructionStatus)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sellerId,propertyType,listingPurpose,title,priceNpr,district,city,description,areaSqm,areaRopani,areaAana,areaPaisa,areaDam,areaBigha,areaKattha,areaDhur,ward,roadAccessFt,kittaNumber,bedrooms,bathrooms,leaseTermMonths,leaseRenewable,depositAmount,availableFrom,furnishingStatus,utilitiesIncluded,petPolicy,parkingSpaces,floorNumber,totalFloors,propertyAgeYears,constructionStatus,status,rejectionReason,createdAt,updatedAt,reviewedBy,reviewedAt]);
}

@override
String toString() {
    return 'Listing(id: $id, sellerId: $sellerId, propertyType: $propertyType, listingPurpose: $listingPurpose, title: $title, priceNpr: $priceNpr, district: $district, city: $city, description: $description, areaSqm: $areaSqm, areaRopani: $areaRopani, areaAana: $areaAana, areaPaisa: $areaPaisa, areaDam: $areaDam, areaBigha: $areaBigha, areaKattha: $areaKattha, areaDhur: $areaDhur, ward: $ward, roadAccessFt: $roadAccessFt, kittaNumber: $kittaNumber, bedrooms: $bedrooms, bathrooms: $bathrooms, leaseTermMonths: $leaseTermMonths, leaseRenewable: $leaseRenewable, depositAmount: $depositAmount, availableFrom: $availableFrom, furnishingStatus: $furnishingStatus, utilitiesIncluded: $utilitiesIncluded, petPolicy: $petPolicy, parkingSpaces: $parkingSpaces, floorNumber: $floorNumber, totalFloors: $totalFloors, propertyAgeYears: $propertyAgeYears, constructionStatus: $constructionStatus, status: $status, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, PropertyType propertyType, ListingPurpose listingPurpose, String title, int priceNpr, String district, String city, String? description, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? ward, int? roadAccessFt, String? kittaNumber, int? bedrooms, int? bathrooms, int? leaseTermMonths, bool? leaseRenewable, int? depositAmount, DateTime? availableFrom, FurnishingStatus? furnishingStatus, String? utilitiesIncluded, PetPolicy? petPolicy, int? parkingSpaces, int? floorNumber, int? totalFloors, int? propertyAgeYears, ConstructionStatus? constructionStatus, ListingStatus status, String? rejectionReason, DateTime? createdAt, DateTime? updatedAt, String? reviewedBy, DateTime? reviewedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? propertyType = null,Object? listingPurpose = null,Object? title = null,Object? priceNpr = null,Object? district = null,Object? city = null,Object? description = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? ward = freezed,Object? roadAccessFt = freezed,Object? kittaNumber = freezed,Object? bedrooms = freezed,Object? bathrooms = freezed,Object? leaseTermMonths = freezed,Object? leaseRenewable = freezed,Object? depositAmount = freezed,Object? availableFrom = freezed,Object? furnishingStatus = freezed,Object? utilitiesIncluded = freezed,Object? petPolicy = freezed,Object? parkingSpaces = freezed,Object? floorNumber = freezed,Object? totalFloors = freezed,Object? propertyAgeYears = freezed,Object? constructionStatus = freezed,Object? status = null,Object? rejectionReason = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
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
as int?,kittaNumber: freezed == kittaNumber ? _self.kittaNumber : kittaNumber // ignore: cast_nullable_to_non_nullable
as String?,bedrooms: freezed == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int?,bathrooms: freezed == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int?,leaseTermMonths: freezed == leaseTermMonths ? _self.leaseTermMonths : leaseTermMonths // ignore: cast_nullable_to_non_nullable
as int?,leaseRenewable: freezed == leaseRenewable ? _self.leaseRenewable : leaseRenewable // ignore: cast_nullable_to_non_nullable
as bool?,depositAmount: freezed == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as int?,availableFrom: freezed == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,furnishingStatus: freezed == furnishingStatus ? _self.furnishingStatus : furnishingStatus // ignore: cast_nullable_to_non_nullable
as FurnishingStatus?,utilitiesIncluded: freezed == utilitiesIncluded ? _self.utilitiesIncluded : utilitiesIncluded // ignore: cast_nullable_to_non_nullable
as String?,petPolicy: freezed == petPolicy ? _self.petPolicy : petPolicy // ignore: cast_nullable_to_non_nullable
as PetPolicy?,parkingSpaces: freezed == parkingSpaces ? _self.parkingSpaces : parkingSpaces // ignore: cast_nullable_to_non_nullable
as int?,floorNumber: freezed == floorNumber ? _self.floorNumber : floorNumber // ignore: cast_nullable_to_non_nullable
as int?,totalFloors: freezed == totalFloors ? _self.totalFloors : totalFloors // ignore: cast_nullable_to_non_nullable
as int?,propertyAgeYears: freezed == propertyAgeYears ? _self.propertyAgeYears : propertyAgeYears // ignore: cast_nullable_to_non_nullable
as int?,constructionStatus: freezed == constructionStatus ? _self.constructionStatus : constructionStatus // ignore: cast_nullable_to_non_nullable
as ConstructionStatus?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
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
