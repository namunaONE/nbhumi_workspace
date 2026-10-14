// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_kyc_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminKycEntry {

 String get id; String get profileId; String get profileName; KycDocType get docType; String get storagePath; KycDocStatus get status; DateTime get createdAt; DateTime? get reviewedAt; String? get reviewedByName; String? get listingId; String? get listingTitle;
/// Create a copy of AdminKycEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminKycEntryCopyWith<AdminKycEntry> get copyWith => _$AdminKycEntryCopyWithImpl<AdminKycEntry>(this as AdminKycEntry, _$identity);

  /// Serializes this AdminKycEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminKycEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminKycEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.profileName, _this.profileName) || other.profileName == _this.profileName)&&(identical(other.docType, _this.docType) || other.docType == _this.docType)&&(identical(other.storagePath, _this.storagePath) || other.storagePath == _this.storagePath)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt)&&(identical(other.reviewedByName, _this.reviewedByName) || other.reviewedByName == _this.reviewedByName)&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.listingTitle, _this.listingTitle) || other.listingTitle == _this.listingTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminKycEntry;
  return Object.hash(runtimeType,_this.id,_this.profileId,_this.profileName,_this.docType,_this.storagePath,_this.status,_this.createdAt,_this.reviewedAt,_this.reviewedByName,_this.listingId,_this.listingTitle);
}

@override
String toString() {
  final _this = this as AdminKycEntry;
  return 'AdminKycEntry(id: ${_this.id}, profileId: ${_this.profileId}, profileName: ${_this.profileName}, docType: ${_this.docType}, storagePath: ${_this.storagePath}, status: ${_this.status}, createdAt: ${_this.createdAt}, reviewedAt: ${_this.reviewedAt}, reviewedByName: ${_this.reviewedByName}, listingId: ${_this.listingId}, listingTitle: ${_this.listingTitle})';
}


}

/// @nodoc
abstract mixin class $AdminKycEntryCopyWith<$Res>  {
  factory $AdminKycEntryCopyWith(AdminKycEntry value, $Res Function(AdminKycEntry) _then) = _$AdminKycEntryCopyWithImpl;
@useResult
$Res call({
 String id, String profileId, String profileName, KycDocType docType, String storagePath, KycDocStatus status, DateTime createdAt, DateTime? reviewedAt, String? reviewedByName, String? listingId, String? listingTitle
});




}
/// @nodoc
class _$AdminKycEntryCopyWithImpl<$Res>
    implements $AdminKycEntryCopyWith<$Res> {
  _$AdminKycEntryCopyWithImpl(this._self, this._then);

  final AdminKycEntry _self;
  final $Res Function(AdminKycEntry) _then;

/// Create a copy of AdminKycEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? profileId = null,Object? profileName = null,Object? docType = null,Object? storagePath = null,Object? status = null,Object? createdAt = null,Object? reviewedAt = freezed,Object? reviewedByName = freezed,Object? listingId = freezed,Object? listingTitle = freezed,}) {
  return _then(AdminKycEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileName: null == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as KycDocType,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as KycDocStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByName: freezed == reviewedByName ? _self.reviewedByName : reviewedByName // ignore: cast_nullable_to_non_nullable
as String?,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String?,listingTitle: freezed == listingTitle ? _self.listingTitle : listingTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminKycEntry].
extension AdminKycEntryPatterns on AdminKycEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminKycEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminKycEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminKycEntry value)  $default,){
final _that = this;
switch (_that) {
case _AdminKycEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminKycEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AdminKycEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String profileId,  String profileName,  KycDocType docType,  String storagePath,  KycDocStatus status,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByName,  String? listingId,  String? listingTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminKycEntry() when $default != null:
return $default(_that.id,_that.profileId,_that.profileName,_that.docType,_that.storagePath,_that.status,_that.createdAt,_that.reviewedAt,_that.reviewedByName,_that.listingId,_that.listingTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String profileId,  String profileName,  KycDocType docType,  String storagePath,  KycDocStatus status,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByName,  String? listingId,  String? listingTitle)  $default,) {final _that = this;
switch (_that) {
case _AdminKycEntry():
return $default(_that.id,_that.profileId,_that.profileName,_that.docType,_that.storagePath,_that.status,_that.createdAt,_that.reviewedAt,_that.reviewedByName,_that.listingId,_that.listingTitle);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String profileId,  String profileName,  KycDocType docType,  String storagePath,  KycDocStatus status,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByName,  String? listingId,  String? listingTitle)?  $default,) {final _that = this;
switch (_that) {
case _AdminKycEntry() when $default != null:
return $default(_that.id,_that.profileId,_that.profileName,_that.docType,_that.storagePath,_that.status,_that.createdAt,_that.reviewedAt,_that.reviewedByName,_that.listingId,_that.listingTitle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminKycEntry implements AdminKycEntry {
  const _AdminKycEntry({required this.id, required this.profileId, required this.profileName, required this.docType, required this.storagePath, required this.status, required this.createdAt, required this.reviewedAt, required this.reviewedByName, required this.listingId, required this.listingTitle});
  factory _AdminKycEntry.fromJson(Map<String, dynamic> json) => _$AdminKycEntryFromJson(json);

@override final  String id;
@override final  String profileId;
@override final  String profileName;
@override final  KycDocType docType;
@override final  String storagePath;
@override final  KycDocStatus status;
@override final  DateTime createdAt;
@override final  DateTime? reviewedAt;
@override final  String? reviewedByName;
@override final  String? listingId;
@override final  String? listingTitle;

/// Create a copy of AdminKycEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminKycEntryCopyWith<_AdminKycEntry> get copyWith => __$AdminKycEntryCopyWithImpl<_AdminKycEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminKycEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminKycEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileName, profileName) || other.profileName == profileName)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByName, reviewedByName) || other.reviewedByName == reviewedByName)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.listingTitle, listingTitle) || other.listingTitle == listingTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,profileId,profileName,docType,storagePath,status,createdAt,reviewedAt,reviewedByName,listingId,listingTitle);
}

@override
String toString() {
    return 'AdminKycEntry(id: $id, profileId: $profileId, profileName: $profileName, docType: $docType, storagePath: $storagePath, status: $status, createdAt: $createdAt, reviewedAt: $reviewedAt, reviewedByName: $reviewedByName, listingId: $listingId, listingTitle: $listingTitle)';
}


}

/// @nodoc
abstract mixin class _$AdminKycEntryCopyWith<$Res> implements $AdminKycEntryCopyWith<$Res> {
  factory _$AdminKycEntryCopyWith(_AdminKycEntry value, $Res Function(_AdminKycEntry) _then) = __$AdminKycEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String profileId, String profileName, KycDocType docType, String storagePath, KycDocStatus status, DateTime createdAt, DateTime? reviewedAt, String? reviewedByName, String? listingId, String? listingTitle
});




}
/// @nodoc
class __$AdminKycEntryCopyWithImpl<$Res>
    implements _$AdminKycEntryCopyWith<$Res> {
  __$AdminKycEntryCopyWithImpl(this._self, this._then);

  final _AdminKycEntry _self;
  final $Res Function(_AdminKycEntry) _then;

/// Create a copy of AdminKycEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? profileId = null,Object? profileName = null,Object? docType = null,Object? storagePath = null,Object? status = null,Object? createdAt = null,Object? reviewedAt = freezed,Object? reviewedByName = freezed,Object? listingId = freezed,Object? listingTitle = freezed,}) {
  return _then(_AdminKycEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileName: null == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as KycDocType,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as KycDocStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByName: freezed == reviewedByName ? _self.reviewedByName : reviewedByName // ignore: cast_nullable_to_non_nullable
as String?,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String?,listingTitle: freezed == listingTitle ? _self.listingTitle : listingTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminKycCounts {

 int get pending; int get verified; int get rejected;
/// Create a copy of AdminKycCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminKycCountsCopyWith<AdminKycCounts> get copyWith => _$AdminKycCountsCopyWithImpl<AdminKycCounts>(this as AdminKycCounts, _$identity);

  /// Serializes this AdminKycCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminKycCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminKycCounts&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.rejected, _this.rejected) || other.rejected == _this.rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminKycCounts;
  return Object.hash(runtimeType,_this.pending,_this.verified,_this.rejected);
}

@override
String toString() {
  final _this = this as AdminKycCounts;
  return 'AdminKycCounts(pending: ${_this.pending}, verified: ${_this.verified}, rejected: ${_this.rejected})';
}


}

/// @nodoc
abstract mixin class $AdminKycCountsCopyWith<$Res>  {
  factory $AdminKycCountsCopyWith(AdminKycCounts value, $Res Function(AdminKycCounts) _then) = _$AdminKycCountsCopyWithImpl;
@useResult
$Res call({
 int pending, int verified, int rejected
});




}
/// @nodoc
class _$AdminKycCountsCopyWithImpl<$Res>
    implements $AdminKycCountsCopyWith<$Res> {
  _$AdminKycCountsCopyWithImpl(this._self, this._then);

  final AdminKycCounts _self;
  final $Res Function(AdminKycCounts) _then;

/// Create a copy of AdminKycCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pending = null,Object? verified = null,Object? rejected = null,}) {
  return _then(AdminKycCounts(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminKycCounts].
extension AdminKycCountsPatterns on AdminKycCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminKycCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminKycCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminKycCounts value)  $default,){
final _that = this;
switch (_that) {
case _AdminKycCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminKycCounts value)?  $default,){
final _that = this;
switch (_that) {
case _AdminKycCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pending,  int verified,  int rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminKycCounts() when $default != null:
return $default(_that.pending,_that.verified,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pending,  int verified,  int rejected)  $default,) {final _that = this;
switch (_that) {
case _AdminKycCounts():
return $default(_that.pending,_that.verified,_that.rejected);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pending,  int verified,  int rejected)?  $default,) {final _that = this;
switch (_that) {
case _AdminKycCounts() when $default != null:
return $default(_that.pending,_that.verified,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminKycCounts implements AdminKycCounts {
  const _AdminKycCounts({this.pending = 0, this.verified = 0, this.rejected = 0});
  factory _AdminKycCounts.fromJson(Map<String, dynamic> json) => _$AdminKycCountsFromJson(json);

@override@JsonKey() final  int pending;
@override@JsonKey() final  int verified;
@override@JsonKey() final  int rejected;

/// Create a copy of AdminKycCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminKycCountsCopyWith<_AdminKycCounts> get copyWith => __$AdminKycCountsCopyWithImpl<_AdminKycCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminKycCountsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminKycCounts&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pending,verified,rejected);
}

@override
String toString() {
    return 'AdminKycCounts(pending: $pending, verified: $verified, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$AdminKycCountsCopyWith<$Res> implements $AdminKycCountsCopyWith<$Res> {
  factory _$AdminKycCountsCopyWith(_AdminKycCounts value, $Res Function(_AdminKycCounts) _then) = __$AdminKycCountsCopyWithImpl;
@override @useResult
$Res call({
 int pending, int verified, int rejected
});




}
/// @nodoc
class __$AdminKycCountsCopyWithImpl<$Res>
    implements _$AdminKycCountsCopyWith<$Res> {
  __$AdminKycCountsCopyWithImpl(this._self, this._then);

  final _AdminKycCounts _self;
  final $Res Function(_AdminKycCounts) _then;

/// Create a copy of AdminKycCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pending = null,Object? verified = null,Object? rejected = null,}) {
  return _then(_AdminKycCounts(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AdminKycPage {

 List<AdminKycEntry> get entries; AdminKycCounts get counts; String? get nextCursor;
/// Create a copy of AdminKycPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminKycPageCopyWith<AdminKycPage> get copyWith => _$AdminKycPageCopyWithImpl<AdminKycPage>(this as AdminKycPage, _$identity);

  /// Serializes this AdminKycPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminKycPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminKycPage&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.counts, _this.counts) || other.counts == _this.counts)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminKycPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.entries),_this.counts,_this.nextCursor);
}

@override
String toString() {
  final _this = this as AdminKycPage;
  return 'AdminKycPage(entries: ${_this.entries}, counts: ${_this.counts}, nextCursor: ${_this.nextCursor})';
}


}

/// @nodoc
abstract mixin class $AdminKycPageCopyWith<$Res>  {
  factory $AdminKycPageCopyWith(AdminKycPage value, $Res Function(AdminKycPage) _then) = _$AdminKycPageCopyWithImpl;
@useResult
$Res call({
 List<AdminKycEntry> entries, AdminKycCounts counts, String? nextCursor
});


$AdminKycCountsCopyWith<$Res> get counts;

}
/// @nodoc
class _$AdminKycPageCopyWithImpl<$Res>
    implements $AdminKycPageCopyWith<$Res> {
  _$AdminKycPageCopyWithImpl(this._self, this._then);

  final AdminKycPage _self;
  final $Res Function(AdminKycPage) _then;

/// Create a copy of AdminKycPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? counts = null,Object? nextCursor = freezed,}) {
  return _then(AdminKycPage(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<AdminKycEntry>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as AdminKycCounts,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AdminKycPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminKycCountsCopyWith<$Res> get counts {
  
  return $AdminKycCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminKycPage].
extension AdminKycPagePatterns on AdminKycPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminKycPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminKycPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminKycPage value)  $default,){
final _that = this;
switch (_that) {
case _AdminKycPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminKycPage value)?  $default,){
final _that = this;
switch (_that) {
case _AdminKycPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AdminKycEntry> entries,  AdminKycCounts counts,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminKycPage() when $default != null:
return $default(_that.entries,_that.counts,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AdminKycEntry> entries,  AdminKycCounts counts,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _AdminKycPage():
return $default(_that.entries,_that.counts,_that.nextCursor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AdminKycEntry> entries,  AdminKycCounts counts,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _AdminKycPage() when $default != null:
return $default(_that.entries,_that.counts,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminKycPage implements AdminKycPage {
  const _AdminKycPage({required  List<AdminKycEntry> entries, required this.counts, this.nextCursor}): _entries = entries;
  factory _AdminKycPage.fromJson(Map<String, dynamic> json) => _$AdminKycPageFromJson(json);

 final  List<AdminKycEntry> _entries;
@override List<AdminKycEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  AdminKycCounts counts;
@override final  String? nextCursor;

/// Create a copy of AdminKycPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminKycPageCopyWith<_AdminKycPage> get copyWith => __$AdminKycPageCopyWithImpl<_AdminKycPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminKycPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminKycPage&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),counts,nextCursor);
}

@override
String toString() {
    return 'AdminKycPage(entries: $entries, counts: $counts, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$AdminKycPageCopyWith<$Res> implements $AdminKycPageCopyWith<$Res> {
  factory _$AdminKycPageCopyWith(_AdminKycPage value, $Res Function(_AdminKycPage) _then) = __$AdminKycPageCopyWithImpl;
@override @useResult
$Res call({
 List<AdminKycEntry> entries, AdminKycCounts counts, String? nextCursor
});


@override $AdminKycCountsCopyWith<$Res> get counts;

}
/// @nodoc
class __$AdminKycPageCopyWithImpl<$Res>
    implements _$AdminKycPageCopyWith<$Res> {
  __$AdminKycPageCopyWithImpl(this._self, this._then);

  final _AdminKycPage _self;
  final $Res Function(_AdminKycPage) _then;

/// Create a copy of AdminKycPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? counts = null,Object? nextCursor = freezed,}) {
  return _then(_AdminKycPage(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<AdminKycEntry>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as AdminKycCounts,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AdminKycPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminKycCountsCopyWith<$Res> get counts {
  
  return $AdminKycCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}

// dart format on
