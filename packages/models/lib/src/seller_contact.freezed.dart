// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SellerContact {

 String get listingId; String get sellerId; String? get sellerName; String? get sellerPhone; String? get sellerEmail; String? get agencyName; bool get isVerified; DateTime? get revealedAt; DateTime? get expiresAt;
/// Create a copy of SellerContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerContactCopyWith<SellerContact> get copyWith => _$SellerContactCopyWithImpl<SellerContact>(this as SellerContact, _$identity);

  /// Serializes this SellerContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SellerContact;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerContact&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.sellerName, _this.sellerName) || other.sellerName == _this.sellerName)&&(identical(other.sellerPhone, _this.sellerPhone) || other.sellerPhone == _this.sellerPhone)&&(identical(other.sellerEmail, _this.sellerEmail) || other.sellerEmail == _this.sellerEmail)&&(identical(other.agencyName, _this.agencyName) || other.agencyName == _this.agencyName)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.revealedAt, _this.revealedAt) || other.revealedAt == _this.revealedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SellerContact;
  return Object.hash(runtimeType,_this.listingId,_this.sellerId,_this.sellerName,_this.sellerPhone,_this.sellerEmail,_this.agencyName,_this.isVerified,_this.revealedAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as SellerContact;
  return 'SellerContact(listingId: ${_this.listingId}, sellerId: ${_this.sellerId}, sellerName: ${_this.sellerName}, sellerPhone: ${_this.sellerPhone}, sellerEmail: ${_this.sellerEmail}, agencyName: ${_this.agencyName}, isVerified: ${_this.isVerified}, revealedAt: ${_this.revealedAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $SellerContactCopyWith<$Res>  {
  factory $SellerContactCopyWith(SellerContact value, $Res Function(SellerContact) _then) = _$SellerContactCopyWithImpl;
@useResult
$Res call({
 String listingId, String sellerId, String? sellerName, String? sellerPhone, String? sellerEmail, String? agencyName, bool isVerified, DateTime? revealedAt, DateTime? expiresAt
});




}
/// @nodoc
class _$SellerContactCopyWithImpl<$Res>
    implements $SellerContactCopyWith<$Res> {
  _$SellerContactCopyWithImpl(this._self, this._then);

  final SellerContact _self;
  final $Res Function(SellerContact) _then;

/// Create a copy of SellerContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? sellerId = null,Object? sellerName = freezed,Object? sellerPhone = freezed,Object? sellerEmail = freezed,Object? agencyName = freezed,Object? isVerified = null,Object? revealedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(SellerContact(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,sellerPhone: freezed == sellerPhone ? _self.sellerPhone : sellerPhone // ignore: cast_nullable_to_non_nullable
as String?,sellerEmail: freezed == sellerEmail ? _self.sellerEmail : sellerEmail // ignore: cast_nullable_to_non_nullable
as String?,agencyName: freezed == agencyName ? _self.agencyName : agencyName // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,revealedAt: freezed == revealedAt ? _self.revealedAt : revealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerContact].
extension SellerContactPatterns on SellerContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerContact value)  $default,){
final _that = this;
switch (_that) {
case _SellerContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerContact value)?  $default,){
final _that = this;
switch (_that) {
case _SellerContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listingId,  String sellerId,  String? sellerName,  String? sellerPhone,  String? sellerEmail,  String? agencyName,  bool isVerified,  DateTime? revealedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerContact() when $default != null:
return $default(_that.listingId,_that.sellerId,_that.sellerName,_that.sellerPhone,_that.sellerEmail,_that.agencyName,_that.isVerified,_that.revealedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listingId,  String sellerId,  String? sellerName,  String? sellerPhone,  String? sellerEmail,  String? agencyName,  bool isVerified,  DateTime? revealedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _SellerContact():
return $default(_that.listingId,_that.sellerId,_that.sellerName,_that.sellerPhone,_that.sellerEmail,_that.agencyName,_that.isVerified,_that.revealedAt,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listingId,  String sellerId,  String? sellerName,  String? sellerPhone,  String? sellerEmail,  String? agencyName,  bool isVerified,  DateTime? revealedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _SellerContact() when $default != null:
return $default(_that.listingId,_that.sellerId,_that.sellerName,_that.sellerPhone,_that.sellerEmail,_that.agencyName,_that.isVerified,_that.revealedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SellerContact extends SellerContact {
  const _SellerContact({required this.listingId, required this.sellerId, this.sellerName, this.sellerPhone, this.sellerEmail, this.agencyName, this.isVerified = false, this.revealedAt, this.expiresAt}): super._();
  factory _SellerContact.fromJson(Map<String, dynamic> json) => _$SellerContactFromJson(json);

@override final  String listingId;
@override final  String sellerId;
@override final  String? sellerName;
@override final  String? sellerPhone;
@override final  String? sellerEmail;
@override final  String? agencyName;
@override@JsonKey() final  bool isVerified;
@override final  DateTime? revealedAt;
@override final  DateTime? expiresAt;

/// Create a copy of SellerContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerContactCopyWith<_SellerContact> get copyWith => __$SellerContactCopyWithImpl<_SellerContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerContactToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerContact&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.sellerPhone, sellerPhone) || other.sellerPhone == sellerPhone)&&(identical(other.sellerEmail, sellerEmail) || other.sellerEmail == sellerEmail)&&(identical(other.agencyName, agencyName) || other.agencyName == agencyName)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.revealedAt, revealedAt) || other.revealedAt == revealedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listingId,sellerId,sellerName,sellerPhone,sellerEmail,agencyName,isVerified,revealedAt,expiresAt);
}

@override
String toString() {
    return 'SellerContact(listingId: $listingId, sellerId: $sellerId, sellerName: $sellerName, sellerPhone: $sellerPhone, sellerEmail: $sellerEmail, agencyName: $agencyName, isVerified: $isVerified, revealedAt: $revealedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$SellerContactCopyWith<$Res> implements $SellerContactCopyWith<$Res> {
  factory _$SellerContactCopyWith(_SellerContact value, $Res Function(_SellerContact) _then) = __$SellerContactCopyWithImpl;
@override @useResult
$Res call({
 String listingId, String sellerId, String? sellerName, String? sellerPhone, String? sellerEmail, String? agencyName, bool isVerified, DateTime? revealedAt, DateTime? expiresAt
});




}
/// @nodoc
class __$SellerContactCopyWithImpl<$Res>
    implements _$SellerContactCopyWith<$Res> {
  __$SellerContactCopyWithImpl(this._self, this._then);

  final _SellerContact _self;
  final $Res Function(_SellerContact) _then;

/// Create a copy of SellerContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? sellerId = null,Object? sellerName = freezed,Object? sellerPhone = freezed,Object? sellerEmail = freezed,Object? agencyName = freezed,Object? isVerified = null,Object? revealedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_SellerContact(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,sellerPhone: freezed == sellerPhone ? _self.sellerPhone : sellerPhone // ignore: cast_nullable_to_non_nullable
as String?,sellerEmail: freezed == sellerEmail ? _self.sellerEmail : sellerEmail // ignore: cast_nullable_to_non_nullable
as String?,agencyName: freezed == agencyName ? _self.agencyName : agencyName // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,revealedAt: freezed == revealedAt ? _self.revealedAt : revealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
