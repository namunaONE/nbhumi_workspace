// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_queue_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QueueSeller {

 String get id; String? get fullName; String? get role; bool get isVerified; String get kycTier; String? get agencyName; String? get agencyRegNo;
/// Create a copy of QueueSeller
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueSellerCopyWith<QueueSeller> get copyWith => _$QueueSellerCopyWithImpl<QueueSeller>(this as QueueSeller, _$identity);

  /// Serializes this QueueSeller to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QueueSeller;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueSeller&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.kycTier, _this.kycTier) || other.kycTier == _this.kycTier)&&(identical(other.agencyName, _this.agencyName) || other.agencyName == _this.agencyName)&&(identical(other.agencyRegNo, _this.agencyRegNo) || other.agencyRegNo == _this.agencyRegNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QueueSeller;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.role,_this.isVerified,_this.kycTier,_this.agencyName,_this.agencyRegNo);
}

@override
String toString() {
  final _this = this as QueueSeller;
  return 'QueueSeller(id: ${_this.id}, fullName: ${_this.fullName}, role: ${_this.role}, isVerified: ${_this.isVerified}, kycTier: ${_this.kycTier}, agencyName: ${_this.agencyName}, agencyRegNo: ${_this.agencyRegNo})';
}


}

/// @nodoc
abstract mixin class $QueueSellerCopyWith<$Res>  {
  factory $QueueSellerCopyWith(QueueSeller value, $Res Function(QueueSeller) _then) = _$QueueSellerCopyWithImpl;
@useResult
$Res call({
 String id, String? fullName, String? role, bool isVerified, String kycTier, String? agencyName, String? agencyRegNo
});




}
/// @nodoc
class _$QueueSellerCopyWithImpl<$Res>
    implements $QueueSellerCopyWith<$Res> {
  _$QueueSellerCopyWithImpl(this._self, this._then);

  final QueueSeller _self;
  final $Res Function(QueueSeller) _then;

/// Create a copy of QueueSeller
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = freezed,Object? role = freezed,Object? isVerified = null,Object? kycTier = null,Object? agencyName = freezed,Object? agencyRegNo = freezed,}) {
  return _then(QueueSeller(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,kycTier: null == kycTier ? _self.kycTier : kycTier // ignore: cast_nullable_to_non_nullable
as String,agencyName: freezed == agencyName ? _self.agencyName : agencyName // ignore: cast_nullable_to_non_nullable
as String?,agencyRegNo: freezed == agencyRegNo ? _self.agencyRegNo : agencyRegNo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QueueSeller].
extension QueueSellerPatterns on QueueSeller {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueSeller value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueSeller() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueSeller value)  $default,){
final _that = this;
switch (_that) {
case _QueueSeller():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueSeller value)?  $default,){
final _that = this;
switch (_that) {
case _QueueSeller() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? fullName,  String? role,  bool isVerified,  String kycTier,  String? agencyName,  String? agencyRegNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueSeller() when $default != null:
return $default(_that.id,_that.fullName,_that.role,_that.isVerified,_that.kycTier,_that.agencyName,_that.agencyRegNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? fullName,  String? role,  bool isVerified,  String kycTier,  String? agencyName,  String? agencyRegNo)  $default,) {final _that = this;
switch (_that) {
case _QueueSeller():
return $default(_that.id,_that.fullName,_that.role,_that.isVerified,_that.kycTier,_that.agencyName,_that.agencyRegNo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? fullName,  String? role,  bool isVerified,  String kycTier,  String? agencyName,  String? agencyRegNo)?  $default,) {final _that = this;
switch (_that) {
case _QueueSeller() when $default != null:
return $default(_that.id,_that.fullName,_that.role,_that.isVerified,_that.kycTier,_that.agencyName,_that.agencyRegNo);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _QueueSeller implements QueueSeller {
  const _QueueSeller({required this.id, this.fullName, this.role, this.isVerified = false, this.kycTier = 'none', this.agencyName, this.agencyRegNo});
  factory _QueueSeller.fromJson(Map<String, dynamic> json) => _$QueueSellerFromJson(json);

@override final  String id;
@override final  String? fullName;
@override final  String? role;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  String kycTier;
@override final  String? agencyName;
@override final  String? agencyRegNo;

/// Create a copy of QueueSeller
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueSellerCopyWith<_QueueSeller> get copyWith => __$QueueSellerCopyWithImpl<_QueueSeller>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QueueSellerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueSeller&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.kycTier, kycTier) || other.kycTier == kycTier)&&(identical(other.agencyName, agencyName) || other.agencyName == agencyName)&&(identical(other.agencyRegNo, agencyRegNo) || other.agencyRegNo == agencyRegNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,role,isVerified,kycTier,agencyName,agencyRegNo);
}

@override
String toString() {
    return 'QueueSeller(id: $id, fullName: $fullName, role: $role, isVerified: $isVerified, kycTier: $kycTier, agencyName: $agencyName, agencyRegNo: $agencyRegNo)';
}


}

/// @nodoc
abstract mixin class _$QueueSellerCopyWith<$Res> implements $QueueSellerCopyWith<$Res> {
  factory _$QueueSellerCopyWith(_QueueSeller value, $Res Function(_QueueSeller) _then) = __$QueueSellerCopyWithImpl;
@override @useResult
$Res call({
 String id, String? fullName, String? role, bool isVerified, String kycTier, String? agencyName, String? agencyRegNo
});




}
/// @nodoc
class __$QueueSellerCopyWithImpl<$Res>
    implements _$QueueSellerCopyWith<$Res> {
  __$QueueSellerCopyWithImpl(this._self, this._then);

  final _QueueSeller _self;
  final $Res Function(_QueueSeller) _then;

/// Create a copy of QueueSeller
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = freezed,Object? role = freezed,Object? isVerified = null,Object? kycTier = null,Object? agencyName = freezed,Object? agencyRegNo = freezed,}) {
  return _then(_QueueSeller(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,kycTier: null == kycTier ? _self.kycTier : kycTier // ignore: cast_nullable_to_non_nullable
as String,agencyName: freezed == agencyName ? _self.agencyName : agencyName // ignore: cast_nullable_to_non_nullable
as String?,agencyRegNo: freezed == agencyRegNo ? _self.agencyRegNo : agencyRegNo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminQueueEntry {

 String get id; String get title; String get district; String get city; int get priceNpr; PropertyType get propertyType; ListingPurpose get listingPurpose; ListingStatus get status; QueueSeller get seller; String? get ward; double? get areaSqm; int? get areaRopani; int? get areaAana; int? get areaPaisa; int? get areaDam; int? get areaBigha; int? get areaKattha; int? get areaDhur;/// Cover photo for the queue row, joined server-side.
 String? get photoUrl;/// Total photos attached. Shown as a warning when below the 3 the seller is
/// asked for in the wizard, so a reviewer sees it without opening the row.
 int get photoCount; String? get rejectionReason;/// When the seller submitted this for review. Null for a draft.
 DateTime? get submittedAt;/// When an admin last acted on it. Null while still pending.
 DateTime? get reviewedAt; DateTime? get createdAt;
/// Create a copy of AdminQueueEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminQueueEntryCopyWith<AdminQueueEntry> get copyWith => _$AdminQueueEntryCopyWithImpl<AdminQueueEntry>(this as AdminQueueEntry, _$identity);

  /// Serializes this AdminQueueEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminQueueEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminQueueEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.priceNpr, _this.priceNpr) || other.priceNpr == _this.priceNpr)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.listingPurpose, _this.listingPurpose) || other.listingPurpose == _this.listingPurpose)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.seller, _this.seller) || other.seller == _this.seller)&&(identical(other.ward, _this.ward) || other.ward == _this.ward)&&(identical(other.areaSqm, _this.areaSqm) || other.areaSqm == _this.areaSqm)&&(identical(other.areaRopani, _this.areaRopani) || other.areaRopani == _this.areaRopani)&&(identical(other.areaAana, _this.areaAana) || other.areaAana == _this.areaAana)&&(identical(other.areaPaisa, _this.areaPaisa) || other.areaPaisa == _this.areaPaisa)&&(identical(other.areaDam, _this.areaDam) || other.areaDam == _this.areaDam)&&(identical(other.areaBigha, _this.areaBigha) || other.areaBigha == _this.areaBigha)&&(identical(other.areaKattha, _this.areaKattha) || other.areaKattha == _this.areaKattha)&&(identical(other.areaDhur, _this.areaDhur) || other.areaDhur == _this.areaDhur)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.photoCount, _this.photoCount) || other.photoCount == _this.photoCount)&&(identical(other.rejectionReason, _this.rejectionReason) || other.rejectionReason == _this.rejectionReason)&&(identical(other.submittedAt, _this.submittedAt) || other.submittedAt == _this.submittedAt)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminQueueEntry;
  return Object.hashAll([runtimeType,_this.id,_this.title,_this.district,_this.city,_this.priceNpr,_this.propertyType,_this.listingPurpose,_this.status,_this.seller,_this.ward,_this.areaSqm,_this.areaRopani,_this.areaAana,_this.areaPaisa,_this.areaDam,_this.areaBigha,_this.areaKattha,_this.areaDhur,_this.photoUrl,_this.photoCount,_this.rejectionReason,_this.submittedAt,_this.reviewedAt,_this.createdAt]);
}

@override
String toString() {
  final _this = this as AdminQueueEntry;
  return 'AdminQueueEntry(id: ${_this.id}, title: ${_this.title}, district: ${_this.district}, city: ${_this.city}, priceNpr: ${_this.priceNpr}, propertyType: ${_this.propertyType}, listingPurpose: ${_this.listingPurpose}, status: ${_this.status}, seller: ${_this.seller}, ward: ${_this.ward}, areaSqm: ${_this.areaSqm}, areaRopani: ${_this.areaRopani}, areaAana: ${_this.areaAana}, areaPaisa: ${_this.areaPaisa}, areaDam: ${_this.areaDam}, areaBigha: ${_this.areaBigha}, areaKattha: ${_this.areaKattha}, areaDhur: ${_this.areaDhur}, photoUrl: ${_this.photoUrl}, photoCount: ${_this.photoCount}, rejectionReason: ${_this.rejectionReason}, submittedAt: ${_this.submittedAt}, reviewedAt: ${_this.reviewedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AdminQueueEntryCopyWith<$Res>  {
  factory $AdminQueueEntryCopyWith(AdminQueueEntry value, $Res Function(AdminQueueEntry) _then) = _$AdminQueueEntryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String district, String city, int priceNpr, PropertyType propertyType, ListingPurpose listingPurpose, ListingStatus status, QueueSeller seller, String? ward, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? photoUrl, int photoCount, String? rejectionReason, DateTime? submittedAt, DateTime? reviewedAt, DateTime? createdAt
});


$QueueSellerCopyWith<$Res> get seller;

}
/// @nodoc
class _$AdminQueueEntryCopyWithImpl<$Res>
    implements $AdminQueueEntryCopyWith<$Res> {
  _$AdminQueueEntryCopyWithImpl(this._self, this._then);

  final AdminQueueEntry _self;
  final $Res Function(AdminQueueEntry) _then;

/// Create a copy of AdminQueueEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? district = null,Object? city = null,Object? priceNpr = null,Object? propertyType = null,Object? listingPurpose = null,Object? status = null,Object? seller = null,Object? ward = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? photoUrl = freezed,Object? photoCount = null,Object? rejectionReason = freezed,Object? submittedAt = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(AdminQueueEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,seller: null == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as QueueSeller,ward: freezed == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String?,areaSqm: freezed == areaSqm ? _self.areaSqm : areaSqm // ignore: cast_nullable_to_non_nullable
as double?,areaRopani: freezed == areaRopani ? _self.areaRopani : areaRopani // ignore: cast_nullable_to_non_nullable
as int?,areaAana: freezed == areaAana ? _self.areaAana : areaAana // ignore: cast_nullable_to_non_nullable
as int?,areaPaisa: freezed == areaPaisa ? _self.areaPaisa : areaPaisa // ignore: cast_nullable_to_non_nullable
as int?,areaDam: freezed == areaDam ? _self.areaDam : areaDam // ignore: cast_nullable_to_non_nullable
as int?,areaBigha: freezed == areaBigha ? _self.areaBigha : areaBigha // ignore: cast_nullable_to_non_nullable
as int?,areaKattha: freezed == areaKattha ? _self.areaKattha : areaKattha // ignore: cast_nullable_to_non_nullable
as int?,areaDhur: freezed == areaDhur ? _self.areaDhur : areaDhur // ignore: cast_nullable_to_non_nullable
as int?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of AdminQueueEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueSellerCopyWith<$Res> get seller {
  
  return $QueueSellerCopyWith<$Res>(_self.seller, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminQueueEntry].
extension AdminQueueEntryPatterns on AdminQueueEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminQueueEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminQueueEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminQueueEntry value)  $default,){
final _that = this;
switch (_that) {
case _AdminQueueEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminQueueEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AdminQueueEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String district,  String city,  int priceNpr,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  QueueSeller seller,  String? ward,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? photoUrl,  int photoCount,  String? rejectionReason,  DateTime? submittedAt,  DateTime? reviewedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminQueueEntry() when $default != null:
return $default(_that.id,_that.title,_that.district,_that.city,_that.priceNpr,_that.propertyType,_that.listingPurpose,_that.status,_that.seller,_that.ward,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.photoUrl,_that.photoCount,_that.rejectionReason,_that.submittedAt,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String district,  String city,  int priceNpr,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  QueueSeller seller,  String? ward,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? photoUrl,  int photoCount,  String? rejectionReason,  DateTime? submittedAt,  DateTime? reviewedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminQueueEntry():
return $default(_that.id,_that.title,_that.district,_that.city,_that.priceNpr,_that.propertyType,_that.listingPurpose,_that.status,_that.seller,_that.ward,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.photoUrl,_that.photoCount,_that.rejectionReason,_that.submittedAt,_that.reviewedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String district,  String city,  int priceNpr,  PropertyType propertyType,  ListingPurpose listingPurpose,  ListingStatus status,  QueueSeller seller,  String? ward,  double? areaSqm,  int? areaRopani,  int? areaAana,  int? areaPaisa,  int? areaDam,  int? areaBigha,  int? areaKattha,  int? areaDhur,  String? photoUrl,  int photoCount,  String? rejectionReason,  DateTime? submittedAt,  DateTime? reviewedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminQueueEntry() when $default != null:
return $default(_that.id,_that.title,_that.district,_that.city,_that.priceNpr,_that.propertyType,_that.listingPurpose,_that.status,_that.seller,_that.ward,_that.areaSqm,_that.areaRopani,_that.areaAana,_that.areaPaisa,_that.areaDam,_that.areaBigha,_that.areaKattha,_that.areaDhur,_that.photoUrl,_that.photoCount,_that.rejectionReason,_that.submittedAt,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _AdminQueueEntry implements AdminQueueEntry {
  const _AdminQueueEntry({required this.id, required this.title, required this.district, required this.city, required this.priceNpr, required this.propertyType, required this.listingPurpose, required this.status, required this.seller, this.ward, this.areaSqm, this.areaRopani, this.areaAana, this.areaPaisa, this.areaDam, this.areaBigha, this.areaKattha, this.areaDhur, this.photoUrl, this.photoCount = 0, this.rejectionReason, this.submittedAt, this.reviewedAt, this.createdAt});
  factory _AdminQueueEntry.fromJson(Map<String, dynamic> json) => _$AdminQueueEntryFromJson(json);

@override final  String id;
@override final  String title;
@override final  String district;
@override final  String city;
@override final  int priceNpr;
@override final  PropertyType propertyType;
@override final  ListingPurpose listingPurpose;
@override final  ListingStatus status;
@override final  QueueSeller seller;
@override final  String? ward;
@override final  double? areaSqm;
@override final  int? areaRopani;
@override final  int? areaAana;
@override final  int? areaPaisa;
@override final  int? areaDam;
@override final  int? areaBigha;
@override final  int? areaKattha;
@override final  int? areaDhur;
/// Cover photo for the queue row, joined server-side.
@override final  String? photoUrl;
/// Total photos attached. Shown as a warning when below the 3 the seller is
/// asked for in the wizard, so a reviewer sees it without opening the row.
@override@JsonKey() final  int photoCount;
@override final  String? rejectionReason;
/// When the seller submitted this for review. Null for a draft.
@override final  DateTime? submittedAt;
/// When an admin last acted on it. Null while still pending.
@override final  DateTime? reviewedAt;
@override final  DateTime? createdAt;

/// Create a copy of AdminQueueEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminQueueEntryCopyWith<_AdminQueueEntry> get copyWith => __$AdminQueueEntryCopyWithImpl<_AdminQueueEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminQueueEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminQueueEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.priceNpr, priceNpr) || other.priceNpr == priceNpr)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.listingPurpose, listingPurpose) || other.listingPurpose == listingPurpose)&&(identical(other.status, status) || other.status == status)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.ward, ward) || other.ward == ward)&&(identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm)&&(identical(other.areaRopani, areaRopani) || other.areaRopani == areaRopani)&&(identical(other.areaAana, areaAana) || other.areaAana == areaAana)&&(identical(other.areaPaisa, areaPaisa) || other.areaPaisa == areaPaisa)&&(identical(other.areaDam, areaDam) || other.areaDam == areaDam)&&(identical(other.areaBigha, areaBigha) || other.areaBigha == areaBigha)&&(identical(other.areaKattha, areaKattha) || other.areaKattha == areaKattha)&&(identical(other.areaDhur, areaDhur) || other.areaDhur == areaDhur)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,title,district,city,priceNpr,propertyType,listingPurpose,status,seller,ward,areaSqm,areaRopani,areaAana,areaPaisa,areaDam,areaBigha,areaKattha,areaDhur,photoUrl,photoCount,rejectionReason,submittedAt,reviewedAt,createdAt]);
}

@override
String toString() {
    return 'AdminQueueEntry(id: $id, title: $title, district: $district, city: $city, priceNpr: $priceNpr, propertyType: $propertyType, listingPurpose: $listingPurpose, status: $status, seller: $seller, ward: $ward, areaSqm: $areaSqm, areaRopani: $areaRopani, areaAana: $areaAana, areaPaisa: $areaPaisa, areaDam: $areaDam, areaBigha: $areaBigha, areaKattha: $areaKattha, areaDhur: $areaDhur, photoUrl: $photoUrl, photoCount: $photoCount, rejectionReason: $rejectionReason, submittedAt: $submittedAt, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminQueueEntryCopyWith<$Res> implements $AdminQueueEntryCopyWith<$Res> {
  factory _$AdminQueueEntryCopyWith(_AdminQueueEntry value, $Res Function(_AdminQueueEntry) _then) = __$AdminQueueEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String district, String city, int priceNpr, PropertyType propertyType, ListingPurpose listingPurpose, ListingStatus status, QueueSeller seller, String? ward, double? areaSqm, int? areaRopani, int? areaAana, int? areaPaisa, int? areaDam, int? areaBigha, int? areaKattha, int? areaDhur, String? photoUrl, int photoCount, String? rejectionReason, DateTime? submittedAt, DateTime? reviewedAt, DateTime? createdAt
});


@override $QueueSellerCopyWith<$Res> get seller;

}
/// @nodoc
class __$AdminQueueEntryCopyWithImpl<$Res>
    implements _$AdminQueueEntryCopyWith<$Res> {
  __$AdminQueueEntryCopyWithImpl(this._self, this._then);

  final _AdminQueueEntry _self;
  final $Res Function(_AdminQueueEntry) _then;

/// Create a copy of AdminQueueEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? district = null,Object? city = null,Object? priceNpr = null,Object? propertyType = null,Object? listingPurpose = null,Object? status = null,Object? seller = null,Object? ward = freezed,Object? areaSqm = freezed,Object? areaRopani = freezed,Object? areaAana = freezed,Object? areaPaisa = freezed,Object? areaDam = freezed,Object? areaBigha = freezed,Object? areaKattha = freezed,Object? areaDhur = freezed,Object? photoUrl = freezed,Object? photoCount = null,Object? rejectionReason = freezed,Object? submittedAt = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_AdminQueueEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,priceNpr: null == priceNpr ? _self.priceNpr : priceNpr // ignore: cast_nullable_to_non_nullable
as int,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as PropertyType,listingPurpose: null == listingPurpose ? _self.listingPurpose : listingPurpose // ignore: cast_nullable_to_non_nullable
as ListingPurpose,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,seller: null == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as QueueSeller,ward: freezed == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String?,areaSqm: freezed == areaSqm ? _self.areaSqm : areaSqm // ignore: cast_nullable_to_non_nullable
as double?,areaRopani: freezed == areaRopani ? _self.areaRopani : areaRopani // ignore: cast_nullable_to_non_nullable
as int?,areaAana: freezed == areaAana ? _self.areaAana : areaAana // ignore: cast_nullable_to_non_nullable
as int?,areaPaisa: freezed == areaPaisa ? _self.areaPaisa : areaPaisa // ignore: cast_nullable_to_non_nullable
as int?,areaDam: freezed == areaDam ? _self.areaDam : areaDam // ignore: cast_nullable_to_non_nullable
as int?,areaBigha: freezed == areaBigha ? _self.areaBigha : areaBigha // ignore: cast_nullable_to_non_nullable
as int?,areaKattha: freezed == areaKattha ? _self.areaKattha : areaKattha // ignore: cast_nullable_to_non_nullable
as int?,areaDhur: freezed == areaDhur ? _self.areaDhur : areaDhur // ignore: cast_nullable_to_non_nullable
as int?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of AdminQueueEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueSellerCopyWith<$Res> get seller {
  
  return $QueueSellerCopyWith<$Res>(_self.seller, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}

/// @nodoc
mixin _$QueueCounts {

 int get pendingReview; int get live; int get rejected;
/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<QueueCounts> get copyWith => _$QueueCountsCopyWithImpl<QueueCounts>(this as QueueCounts, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QueueCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueCounts&&(identical(other.pendingReview, _this.pendingReview) || other.pendingReview == _this.pendingReview)&&(identical(other.live, _this.live) || other.live == _this.live)&&(identical(other.rejected, _this.rejected) || other.rejected == _this.rejected));
}


@override
int get hashCode {
  final _this = this as QueueCounts;
  return Object.hash(runtimeType,_this.pendingReview,_this.live,_this.rejected);
}

@override
String toString() {
  final _this = this as QueueCounts;
  return 'QueueCounts(pendingReview: ${_this.pendingReview}, live: ${_this.live}, rejected: ${_this.rejected})';
}


}

/// @nodoc
abstract mixin class $QueueCountsCopyWith<$Res>  {
  factory $QueueCountsCopyWith(QueueCounts value, $Res Function(QueueCounts) _then) = _$QueueCountsCopyWithImpl;
@useResult
$Res call({
 int pendingReview, int live, int rejected
});




}
/// @nodoc
class _$QueueCountsCopyWithImpl<$Res>
    implements $QueueCountsCopyWith<$Res> {
  _$QueueCountsCopyWithImpl(this._self, this._then);

  final QueueCounts _self;
  final $Res Function(QueueCounts) _then;

/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pendingReview = null,Object? live = null,Object? rejected = null,}) {
  return _then(QueueCounts(
pendingReview: null == pendingReview ? _self.pendingReview : pendingReview // ignore: cast_nullable_to_non_nullable
as int,live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QueueCounts].
extension QueueCountsPatterns on QueueCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueCounts value)  $default,){
final _that = this;
switch (_that) {
case _QueueCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueCounts value)?  $default,){
final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pendingReview,  int live,  int rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
return $default(_that.pendingReview,_that.live,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pendingReview,  int live,  int rejected)  $default,) {final _that = this;
switch (_that) {
case _QueueCounts():
return $default(_that.pendingReview,_that.live,_that.rejected);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pendingReview,  int live,  int rejected)?  $default,) {final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
return $default(_that.pendingReview,_that.live,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc


class _QueueCounts implements QueueCounts {
  const _QueueCounts({this.pendingReview = 0, this.live = 0, this.rejected = 0});
  

@override@JsonKey() final  int pendingReview;
@override@JsonKey() final  int live;
@override@JsonKey() final  int rejected;

/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueCountsCopyWith<_QueueCounts> get copyWith => __$QueueCountsCopyWithImpl<_QueueCounts>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueCounts&&(identical(other.pendingReview, pendingReview) || other.pendingReview == pendingReview)&&(identical(other.live, live) || other.live == live)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pendingReview,live,rejected);
}

@override
String toString() {
    return 'QueueCounts(pendingReview: $pendingReview, live: $live, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$QueueCountsCopyWith<$Res> implements $QueueCountsCopyWith<$Res> {
  factory _$QueueCountsCopyWith(_QueueCounts value, $Res Function(_QueueCounts) _then) = __$QueueCountsCopyWithImpl;
@override @useResult
$Res call({
 int pendingReview, int live, int rejected
});




}
/// @nodoc
class __$QueueCountsCopyWithImpl<$Res>
    implements _$QueueCountsCopyWith<$Res> {
  __$QueueCountsCopyWithImpl(this._self, this._then);

  final _QueueCounts _self;
  final $Res Function(_QueueCounts) _then;

/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pendingReview = null,Object? live = null,Object? rejected = null,}) {
  return _then(_QueueCounts(
pendingReview: null == pendingReview ? _self.pendingReview : pendingReview // ignore: cast_nullable_to_non_nullable
as int,live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AuditLogEntry {

 String get id; String get actorId; String get action; String get entityType; String get entityId; DateTime? get createdAt;/// Action-specific payload: `{"to": "live"}` for an approve,
/// `{"to": "rejected", "reason": "..."}` for a reject.
 Map<String, dynamic>? get details;
/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogEntryCopyWith<AuditLogEntry> get copyWith => _$AuditLogEntryCopyWithImpl<AuditLogEntry>(this as AuditLogEntry, _$identity);

  /// Serializes this AuditLogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuditLogEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.actorId, _this.actorId) || other.actorId == _this.actorId)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.details, _this.details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuditLogEntry;
  return Object.hash(runtimeType,_this.id,_this.actorId,_this.action,_this.entityType,_this.entityId,_this.createdAt,const DeepCollectionEquality().hash(_this.details));
}

@override
String toString() {
  final _this = this as AuditLogEntry;
  return 'AuditLogEntry(id: ${_this.id}, actorId: ${_this.actorId}, action: ${_this.action}, entityType: ${_this.entityType}, entityId: ${_this.entityId}, createdAt: ${_this.createdAt}, details: ${_this.details})';
}


}

/// @nodoc
abstract mixin class $AuditLogEntryCopyWith<$Res>  {
  factory $AuditLogEntryCopyWith(AuditLogEntry value, $Res Function(AuditLogEntry) _then) = _$AuditLogEntryCopyWithImpl;
@useResult
$Res call({
 String id, String actorId, String action, String entityType, String entityId, DateTime? createdAt, Map<String, dynamic>? details
});




}
/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._self, this._then);

  final AuditLogEntry _self;
  final $Res Function(AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? actorId = null,Object? action = null,Object? entityType = null,Object? entityId = null,Object? createdAt = freezed,Object? details = freezed,}) {
  return _then(AuditLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogEntry].
extension AuditLogEntryPatterns on AuditLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String actorId,  String action,  String entityType,  String entityId,  DateTime? createdAt,  Map<String, dynamic>? details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.actorId,_that.action,_that.entityType,_that.entityId,_that.createdAt,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String actorId,  String action,  String entityType,  String entityId,  DateTime? createdAt,  Map<String, dynamic>? details)  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry():
return $default(_that.id,_that.actorId,_that.action,_that.entityType,_that.entityId,_that.createdAt,_that.details);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String actorId,  String action,  String entityType,  String entityId,  DateTime? createdAt,  Map<String, dynamic>? details)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.actorId,_that.action,_that.entityType,_that.entityId,_that.createdAt,_that.details);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AuditLogEntry implements AuditLogEntry {
  const _AuditLogEntry({required this.id, required this.actorId, required this.action, required this.entityType, required this.entityId, this.createdAt,  Map<String, dynamic>? details}): _details = details;
  factory _AuditLogEntry.fromJson(Map<String, dynamic> json) => _$AuditLogEntryFromJson(json);

@override final  String id;
@override final  String actorId;
@override final  String action;
@override final  String entityType;
@override final  String entityId;
@override final  DateTime? createdAt;
/// Action-specific payload: `{"to": "live"}` for an approve,
/// `{"to": "rejected", "reason": "..."}` for a reject.
 final  Map<String, dynamic>? _details;
/// Action-specific payload: `{"to": "live"}` for an approve,
/// `{"to": "rejected", "reason": "..."}` for a reject.
@override Map<String, dynamic>? get details {
  final value = _details;
  if (value == null) return null;
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogEntryCopyWith<_AuditLogEntry> get copyWith => __$AuditLogEntryCopyWithImpl<_AuditLogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.action, action) || other.action == action)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.details, _details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,actorId,action,entityType,entityId,createdAt,const DeepCollectionEquality().hash(_details));
}

@override
String toString() {
    return 'AuditLogEntry(id: $id, actorId: $actorId, action: $action, entityType: $entityType, entityId: $entityId, createdAt: $createdAt, details: $details)';
}


}

/// @nodoc
abstract mixin class _$AuditLogEntryCopyWith<$Res> implements $AuditLogEntryCopyWith<$Res> {
  factory _$AuditLogEntryCopyWith(_AuditLogEntry value, $Res Function(_AuditLogEntry) _then) = __$AuditLogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String actorId, String action, String entityType, String entityId, DateTime? createdAt, Map<String, dynamic>? details
});




}
/// @nodoc
class __$AuditLogEntryCopyWithImpl<$Res>
    implements _$AuditLogEntryCopyWith<$Res> {
  __$AuditLogEntryCopyWithImpl(this._self, this._then);

  final _AuditLogEntry _self;
  final $Res Function(_AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? actorId = null,Object? action = null,Object? entityType = null,Object? entityId = null,Object? createdAt = freezed,Object? details = freezed,}) {
  return _then(_AuditLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,details: freezed == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
