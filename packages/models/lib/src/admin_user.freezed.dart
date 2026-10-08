// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUser {

 String get id; String get email; String get fullName; String? get phone; UserRole get role; bool get isVerified; KycTier get kycTier; DateTime? get suspendedAt; String? get suspendedReason; bool get suspended; DateTime? get createdAt; Map<String, int> get listings; int get openReportsAgainst;
/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserCopyWith<AdminUser> get copyWith => _$AdminUserCopyWithImpl<AdminUser>(this as AdminUser, _$identity);

  /// Serializes this AdminUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.kycTier, _this.kycTier) || other.kycTier == _this.kycTier)&&(identical(other.suspendedAt, _this.suspendedAt) || other.suspendedAt == _this.suspendedAt)&&(identical(other.suspendedReason, _this.suspendedReason) || other.suspendedReason == _this.suspendedReason)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.listings, _this.listings)&&(identical(other.openReportsAgainst, _this.openReportsAgainst) || other.openReportsAgainst == _this.openReportsAgainst));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminUser;
  return Object.hash(runtimeType,_this.id,_this.email,_this.fullName,_this.phone,_this.role,_this.isVerified,_this.kycTier,_this.suspendedAt,_this.suspendedReason,_this.suspended,_this.createdAt,const DeepCollectionEquality().hash(_this.listings),_this.openReportsAgainst);
}

@override
String toString() {
  final _this = this as AdminUser;
  return 'AdminUser(id: ${_this.id}, email: ${_this.email}, fullName: ${_this.fullName}, phone: ${_this.phone}, role: ${_this.role}, isVerified: ${_this.isVerified}, kycTier: ${_this.kycTier}, suspendedAt: ${_this.suspendedAt}, suspendedReason: ${_this.suspendedReason}, suspended: ${_this.suspended}, createdAt: ${_this.createdAt}, listings: ${_this.listings}, openReportsAgainst: ${_this.openReportsAgainst})';
}


}

/// @nodoc
abstract mixin class $AdminUserCopyWith<$Res>  {
  factory $AdminUserCopyWith(AdminUser value, $Res Function(AdminUser) _then) = _$AdminUserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String fullName, String? phone, UserRole role, bool isVerified, KycTier kycTier, DateTime? suspendedAt, String? suspendedReason, bool suspended, DateTime? createdAt, Map<String, int> listings, int openReportsAgainst
});




}
/// @nodoc
class _$AdminUserCopyWithImpl<$Res>
    implements $AdminUserCopyWith<$Res> {
  _$AdminUserCopyWithImpl(this._self, this._then);

  final AdminUser _self;
  final $Res Function(AdminUser) _then;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? fullName = null,Object? phone = freezed,Object? role = null,Object? isVerified = null,Object? kycTier = null,Object? suspendedAt = freezed,Object? suspendedReason = freezed,Object? suspended = null,Object? createdAt = freezed,Object? listings = null,Object? openReportsAgainst = null,}) {
  return _then(AdminUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,kycTier: null == kycTier ? _self.kycTier : kycTier // ignore: cast_nullable_to_non_nullable
as KycTier,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedReason: freezed == suspendedReason ? _self.suspendedReason : suspendedReason // ignore: cast_nullable_to_non_nullable
as String?,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,listings: null == listings ? _self.listings : listings // ignore: cast_nullable_to_non_nullable
as Map<String, int>,openReportsAgainst: null == openReportsAgainst ? _self.openReportsAgainst : openReportsAgainst // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUser].
extension AdminUserPatterns on AdminUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUser value)  $default,){
final _that = this;
switch (_that) {
case _AdminUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUser value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String fullName,  String? phone,  UserRole role,  bool isVerified,  KycTier kycTier,  DateTime? suspendedAt,  String? suspendedReason,  bool suspended,  DateTime? createdAt,  Map<String, int> listings,  int openReportsAgainst)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that.id,_that.email,_that.fullName,_that.phone,_that.role,_that.isVerified,_that.kycTier,_that.suspendedAt,_that.suspendedReason,_that.suspended,_that.createdAt,_that.listings,_that.openReportsAgainst);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String fullName,  String? phone,  UserRole role,  bool isVerified,  KycTier kycTier,  DateTime? suspendedAt,  String? suspendedReason,  bool suspended,  DateTime? createdAt,  Map<String, int> listings,  int openReportsAgainst)  $default,) {final _that = this;
switch (_that) {
case _AdminUser():
return $default(_that.id,_that.email,_that.fullName,_that.phone,_that.role,_that.isVerified,_that.kycTier,_that.suspendedAt,_that.suspendedReason,_that.suspended,_that.createdAt,_that.listings,_that.openReportsAgainst);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String fullName,  String? phone,  UserRole role,  bool isVerified,  KycTier kycTier,  DateTime? suspendedAt,  String? suspendedReason,  bool suspended,  DateTime? createdAt,  Map<String, int> listings,  int openReportsAgainst)?  $default,) {final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that.id,_that.email,_that.fullName,_that.phone,_that.role,_that.isVerified,_that.kycTier,_that.suspendedAt,_that.suspendedReason,_that.suspended,_that.createdAt,_that.listings,_that.openReportsAgainst);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AdminUser implements AdminUser {
  const _AdminUser({required this.id, required this.email, required this.fullName, this.phone, this.role = UserRole.buyer, this.isVerified = false, this.kycTier = KycTier.none, this.suspendedAt, this.suspendedReason, this.suspended = false, this.createdAt,  Map<String, int> listings = const <String, int>{}, this.openReportsAgainst = 0}): _listings = listings;
  factory _AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String fullName;
@override final  String? phone;
@override@JsonKey() final  UserRole role;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  KycTier kycTier;
@override final  DateTime? suspendedAt;
@override final  String? suspendedReason;
@override@JsonKey() final  bool suspended;
@override final  DateTime? createdAt;
 final  Map<String, int> _listings;
@override@JsonKey() Map<String, int> get listings {
  if (_listings is EqualUnmodifiableMapView) return _listings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_listings);
}

@override@JsonKey() final  int openReportsAgainst;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserCopyWith<_AdminUser> get copyWith => __$AdminUserCopyWithImpl<_AdminUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.kycTier, kycTier) || other.kycTier == kycTier)&&(identical(other.suspendedAt, suspendedAt) || other.suspendedAt == suspendedAt)&&(identical(other.suspendedReason, suspendedReason) || other.suspendedReason == suspendedReason)&&(identical(other.suspended, suspended) || other.suspended == suspended)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.listings, _listings)&&(identical(other.openReportsAgainst, openReportsAgainst) || other.openReportsAgainst == openReportsAgainst));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,fullName,phone,role,isVerified,kycTier,suspendedAt,suspendedReason,suspended,createdAt,const DeepCollectionEquality().hash(_listings),openReportsAgainst);
}

@override
String toString() {
    return 'AdminUser(id: $id, email: $email, fullName: $fullName, phone: $phone, role: $role, isVerified: $isVerified, kycTier: $kycTier, suspendedAt: $suspendedAt, suspendedReason: $suspendedReason, suspended: $suspended, createdAt: $createdAt, listings: $listings, openReportsAgainst: $openReportsAgainst)';
}


}

/// @nodoc
abstract mixin class _$AdminUserCopyWith<$Res> implements $AdminUserCopyWith<$Res> {
  factory _$AdminUserCopyWith(_AdminUser value, $Res Function(_AdminUser) _then) = __$AdminUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String fullName, String? phone, UserRole role, bool isVerified, KycTier kycTier, DateTime? suspendedAt, String? suspendedReason, bool suspended, DateTime? createdAt, Map<String, int> listings, int openReportsAgainst
});




}
/// @nodoc
class __$AdminUserCopyWithImpl<$Res>
    implements _$AdminUserCopyWith<$Res> {
  __$AdminUserCopyWithImpl(this._self, this._then);

  final _AdminUser _self;
  final $Res Function(_AdminUser) _then;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? fullName = null,Object? phone = freezed,Object? role = null,Object? isVerified = null,Object? kycTier = null,Object? suspendedAt = freezed,Object? suspendedReason = freezed,Object? suspended = null,Object? createdAt = freezed,Object? listings = null,Object? openReportsAgainst = null,}) {
  return _then(_AdminUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,kycTier: null == kycTier ? _self.kycTier : kycTier // ignore: cast_nullable_to_non_nullable
as KycTier,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedReason: freezed == suspendedReason ? _self.suspendedReason : suspendedReason // ignore: cast_nullable_to_non_nullable
as String?,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,listings: null == listings ? _self._listings : listings // ignore: cast_nullable_to_non_nullable
as Map<String, int>,openReportsAgainst: null == openReportsAgainst ? _self.openReportsAgainst : openReportsAgainst // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
