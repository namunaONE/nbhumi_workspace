// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KycDocument {

 String get id; String get profileId; KycDocType get docType; String get storagePath; KycDocStatus get status; String? get reviewedBy; DateTime? get reviewedAt; DateTime? get createdAt;
/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycDocumentCopyWith<KycDocument> get copyWith => _$KycDocumentCopyWithImpl<KycDocument>(this as KycDocument, _$identity);

  /// Serializes this KycDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KycDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycDocument&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.docType, _this.docType) || other.docType == _this.docType)&&(identical(other.storagePath, _this.storagePath) || other.storagePath == _this.storagePath)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.reviewedBy, _this.reviewedBy) || other.reviewedBy == _this.reviewedBy)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KycDocument;
  return Object.hash(runtimeType,_this.id,_this.profileId,_this.docType,_this.storagePath,_this.status,_this.reviewedBy,_this.reviewedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as KycDocument;
  return 'KycDocument(id: ${_this.id}, profileId: ${_this.profileId}, docType: ${_this.docType}, storagePath: ${_this.storagePath}, status: ${_this.status}, reviewedBy: ${_this.reviewedBy}, reviewedAt: ${_this.reviewedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $KycDocumentCopyWith<$Res>  {
  factory $KycDocumentCopyWith(KycDocument value, $Res Function(KycDocument) _then) = _$KycDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String profileId, KycDocType docType, String storagePath, KycDocStatus status, String? reviewedBy, DateTime? reviewedAt, DateTime? createdAt
});




}
/// @nodoc
class _$KycDocumentCopyWithImpl<$Res>
    implements $KycDocumentCopyWith<$Res> {
  _$KycDocumentCopyWithImpl(this._self, this._then);

  final KycDocument _self;
  final $Res Function(KycDocument) _then;

/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? profileId = null,Object? docType = null,Object? storagePath = null,Object? status = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(KycDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as KycDocType,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as KycDocStatus,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [KycDocument].
extension KycDocumentPatterns on KycDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycDocument value)  $default,){
final _that = this;
switch (_that) {
case _KycDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycDocument value)?  $default,){
final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String profileId,  KycDocType docType,  String storagePath,  KycDocStatus status,  String? reviewedBy,  DateTime? reviewedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
return $default(_that.id,_that.profileId,_that.docType,_that.storagePath,_that.status,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String profileId,  KycDocType docType,  String storagePath,  KycDocStatus status,  String? reviewedBy,  DateTime? reviewedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _KycDocument():
return $default(_that.id,_that.profileId,_that.docType,_that.storagePath,_that.status,_that.reviewedBy,_that.reviewedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String profileId,  KycDocType docType,  String storagePath,  KycDocStatus status,  String? reviewedBy,  DateTime? reviewedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
return $default(_that.id,_that.profileId,_that.docType,_that.storagePath,_that.status,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _KycDocument implements KycDocument {
  const _KycDocument({required this.id, required this.profileId, required this.docType, required this.storagePath, this.status = KycDocStatus.pending, this.reviewedBy, this.reviewedAt, this.createdAt});
  factory _KycDocument.fromJson(Map<String, dynamic> json) => _$KycDocumentFromJson(json);

@override final  String id;
@override final  String profileId;
@override final  KycDocType docType;
@override final  String storagePath;
@override@JsonKey() final  KycDocStatus status;
@override final  String? reviewedBy;
@override final  DateTime? reviewedAt;
@override final  DateTime? createdAt;

/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycDocumentCopyWith<_KycDocument> get copyWith => __$KycDocumentCopyWithImpl<_KycDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,profileId,docType,storagePath,status,reviewedBy,reviewedAt,createdAt);
}

@override
String toString() {
    return 'KycDocument(id: $id, profileId: $profileId, docType: $docType, storagePath: $storagePath, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$KycDocumentCopyWith<$Res> implements $KycDocumentCopyWith<$Res> {
  factory _$KycDocumentCopyWith(_KycDocument value, $Res Function(_KycDocument) _then) = __$KycDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String profileId, KycDocType docType, String storagePath, KycDocStatus status, String? reviewedBy, DateTime? reviewedAt, DateTime? createdAt
});




}
/// @nodoc
class __$KycDocumentCopyWithImpl<$Res>
    implements _$KycDocumentCopyWith<$Res> {
  __$KycDocumentCopyWithImpl(this._self, this._then);

  final _KycDocument _self;
  final $Res Function(_KycDocument) _then;

/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? profileId = null,Object? docType = null,Object? storagePath = null,Object? status = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_KycDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as KycDocType,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as KycDocStatus,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
