// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fraud_signal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FraudSignal {

 FraudSignalCode get code; String get messageEn; String get messageNe; FraudSeverity get severity; Map<String, dynamic> get detail;
/// Create a copy of FraudSignal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FraudSignalCopyWith<FraudSignal> get copyWith => _$FraudSignalCopyWithImpl<FraudSignal>(this as FraudSignal, _$identity);

  /// Serializes this FraudSignal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FraudSignal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FraudSignal&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.messageEn, _this.messageEn) || other.messageEn == _this.messageEn)&&(identical(other.messageNe, _this.messageNe) || other.messageNe == _this.messageNe)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&const DeepCollectionEquality().equals(other.detail, _this.detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FraudSignal;
  return Object.hash(runtimeType,_this.code,_this.messageEn,_this.messageNe,_this.severity,const DeepCollectionEquality().hash(_this.detail));
}

@override
String toString() {
  final _this = this as FraudSignal;
  return 'FraudSignal(code: ${_this.code}, messageEn: ${_this.messageEn}, messageNe: ${_this.messageNe}, severity: ${_this.severity}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $FraudSignalCopyWith<$Res>  {
  factory $FraudSignalCopyWith(FraudSignal value, $Res Function(FraudSignal) _then) = _$FraudSignalCopyWithImpl;
@useResult
$Res call({
 FraudSignalCode code, String messageEn, String messageNe, FraudSeverity severity, Map<String, dynamic> detail
});




}
/// @nodoc
class _$FraudSignalCopyWithImpl<$Res>
    implements $FraudSignalCopyWith<$Res> {
  _$FraudSignalCopyWithImpl(this._self, this._then);

  final FraudSignal _self;
  final $Res Function(FraudSignal) _then;

/// Create a copy of FraudSignal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? messageEn = null,Object? messageNe = null,Object? severity = null,Object? detail = null,}) {
  return _then(FraudSignal(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FraudSignalCode,messageEn: null == messageEn ? _self.messageEn : messageEn // ignore: cast_nullable_to_non_nullable
as String,messageNe: null == messageNe ? _self.messageNe : messageNe // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FraudSeverity,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [FraudSignal].
extension FraudSignalPatterns on FraudSignal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FraudSignal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FraudSignal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FraudSignal value)  $default,){
final _that = this;
switch (_that) {
case _FraudSignal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FraudSignal value)?  $default,){
final _that = this;
switch (_that) {
case _FraudSignal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FraudSignalCode code,  String messageEn,  String messageNe,  FraudSeverity severity,  Map<String, dynamic> detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FraudSignal() when $default != null:
return $default(_that.code,_that.messageEn,_that.messageNe,_that.severity,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FraudSignalCode code,  String messageEn,  String messageNe,  FraudSeverity severity,  Map<String, dynamic> detail)  $default,) {final _that = this;
switch (_that) {
case _FraudSignal():
return $default(_that.code,_that.messageEn,_that.messageNe,_that.severity,_that.detail);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FraudSignalCode code,  String messageEn,  String messageNe,  FraudSeverity severity,  Map<String, dynamic> detail)?  $default,) {final _that = this;
switch (_that) {
case _FraudSignal() when $default != null:
return $default(_that.code,_that.messageEn,_that.messageNe,_that.severity,_that.detail);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _FraudSignal implements FraudSignal {
  const _FraudSignal({required this.code, required this.messageEn, required this.messageNe, this.severity = FraudSeverity.info,  Map<String, dynamic> detail = const <String, dynamic>{}}): _detail = detail;
  factory _FraudSignal.fromJson(Map<String, dynamic> json) => _$FraudSignalFromJson(json);

@override final  FraudSignalCode code;
@override final  String messageEn;
@override final  String messageNe;
@override@JsonKey() final  FraudSeverity severity;
 final  Map<String, dynamic> _detail;
@override@JsonKey() Map<String, dynamic> get detail {
  if (_detail is EqualUnmodifiableMapView) return _detail;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_detail);
}


/// Create a copy of FraudSignal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FraudSignalCopyWith<_FraudSignal> get copyWith => __$FraudSignalCopyWithImpl<_FraudSignal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FraudSignalToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FraudSignal&&(identical(other.code, code) || other.code == code)&&(identical(other.messageEn, messageEn) || other.messageEn == messageEn)&&(identical(other.messageNe, messageNe) || other.messageNe == messageNe)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other.detail, _detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,messageEn,messageNe,severity,const DeepCollectionEquality().hash(_detail));
}

@override
String toString() {
    return 'FraudSignal(code: $code, messageEn: $messageEn, messageNe: $messageNe, severity: $severity, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$FraudSignalCopyWith<$Res> implements $FraudSignalCopyWith<$Res> {
  factory _$FraudSignalCopyWith(_FraudSignal value, $Res Function(_FraudSignal) _then) = __$FraudSignalCopyWithImpl;
@override @useResult
$Res call({
 FraudSignalCode code, String messageEn, String messageNe, FraudSeverity severity, Map<String, dynamic> detail
});




}
/// @nodoc
class __$FraudSignalCopyWithImpl<$Res>
    implements _$FraudSignalCopyWith<$Res> {
  __$FraudSignalCopyWithImpl(this._self, this._then);

  final _FraudSignal _self;
  final $Res Function(_FraudSignal) _then;

/// Create a copy of FraudSignal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? messageEn = null,Object? messageNe = null,Object? severity = null,Object? detail = null,}) {
  return _then(_FraudSignal(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FraudSignalCode,messageEn: null == messageEn ? _self.messageEn : messageEn // ignore: cast_nullable_to_non_nullable
as String,messageNe: null == messageNe ? _self.messageNe : messageNe // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FraudSeverity,detail: null == detail ? _self._detail : detail // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$ListingFraudSignals {

 String get listingId; List<FraudSignal> get signals;
/// Create a copy of ListingFraudSignals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingFraudSignalsCopyWith<ListingFraudSignals> get copyWith => _$ListingFraudSignalsCopyWithImpl<ListingFraudSignals>(this as ListingFraudSignals, _$identity);

  /// Serializes this ListingFraudSignals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingFraudSignals;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingFraudSignals&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&const DeepCollectionEquality().equals(other.signals, _this.signals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingFraudSignals;
  return Object.hash(runtimeType,_this.listingId,const DeepCollectionEquality().hash(_this.signals));
}

@override
String toString() {
  final _this = this as ListingFraudSignals;
  return 'ListingFraudSignals(listingId: ${_this.listingId}, signals: ${_this.signals})';
}


}

/// @nodoc
abstract mixin class $ListingFraudSignalsCopyWith<$Res>  {
  factory $ListingFraudSignalsCopyWith(ListingFraudSignals value, $Res Function(ListingFraudSignals) _then) = _$ListingFraudSignalsCopyWithImpl;
@useResult
$Res call({
 String listingId, List<FraudSignal> signals
});




}
/// @nodoc
class _$ListingFraudSignalsCopyWithImpl<$Res>
    implements $ListingFraudSignalsCopyWith<$Res> {
  _$ListingFraudSignalsCopyWithImpl(this._self, this._then);

  final ListingFraudSignals _self;
  final $Res Function(ListingFraudSignals) _then;

/// Create a copy of ListingFraudSignals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? signals = null,}) {
  return _then(ListingFraudSignals(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,signals: null == signals ? _self.signals : signals // ignore: cast_nullable_to_non_nullable
as List<FraudSignal>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingFraudSignals].
extension ListingFraudSignalsPatterns on ListingFraudSignals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingFraudSignals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingFraudSignals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingFraudSignals value)  $default,){
final _that = this;
switch (_that) {
case _ListingFraudSignals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingFraudSignals value)?  $default,){
final _that = this;
switch (_that) {
case _ListingFraudSignals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listingId,  List<FraudSignal> signals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingFraudSignals() when $default != null:
return $default(_that.listingId,_that.signals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listingId,  List<FraudSignal> signals)  $default,) {final _that = this;
switch (_that) {
case _ListingFraudSignals():
return $default(_that.listingId,_that.signals);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listingId,  List<FraudSignal> signals)?  $default,) {final _that = this;
switch (_that) {
case _ListingFraudSignals() when $default != null:
return $default(_that.listingId,_that.signals);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ListingFraudSignals implements ListingFraudSignals {
  const _ListingFraudSignals({required this.listingId,  List<FraudSignal> signals = const <FraudSignal>[]}): _signals = signals;
  factory _ListingFraudSignals.fromJson(Map<String, dynamic> json) => _$ListingFraudSignalsFromJson(json);

@override final  String listingId;
 final  List<FraudSignal> _signals;
@override@JsonKey() List<FraudSignal> get signals {
  if (_signals is EqualUnmodifiableListView) return _signals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signals);
}


/// Create a copy of ListingFraudSignals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingFraudSignalsCopyWith<_ListingFraudSignals> get copyWith => __$ListingFraudSignalsCopyWithImpl<_ListingFraudSignals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingFraudSignalsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingFraudSignals&&(identical(other.listingId, listingId) || other.listingId == listingId)&&const DeepCollectionEquality().equals(other.signals, _signals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listingId,const DeepCollectionEquality().hash(_signals));
}

@override
String toString() {
    return 'ListingFraudSignals(listingId: $listingId, signals: $signals)';
}


}

/// @nodoc
abstract mixin class _$ListingFraudSignalsCopyWith<$Res> implements $ListingFraudSignalsCopyWith<$Res> {
  factory _$ListingFraudSignalsCopyWith(_ListingFraudSignals value, $Res Function(_ListingFraudSignals) _then) = __$ListingFraudSignalsCopyWithImpl;
@override @useResult
$Res call({
 String listingId, List<FraudSignal> signals
});




}
/// @nodoc
class __$ListingFraudSignalsCopyWithImpl<$Res>
    implements _$ListingFraudSignalsCopyWith<$Res> {
  __$ListingFraudSignalsCopyWithImpl(this._self, this._then);

  final _ListingFraudSignals _self;
  final $Res Function(_ListingFraudSignals) _then;

/// Create a copy of ListingFraudSignals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? signals = null,}) {
  return _then(_ListingFraudSignals(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,signals: null == signals ? _self._signals : signals // ignore: cast_nullable_to_non_nullable
as List<FraudSignal>,
  ));
}


}

// dart format on
