// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discount_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiscountModel _$DiscountModelFromJson(Map<String, dynamic> json) {
  return _DiscountModel.fromJson(json);
}

/// @nodoc
mixin _$DiscountModel {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  DateTime? get validFrom => throw _privateConstructorUsedError;
  DateTime? get validUntil => throw _privateConstructorUsedError;
  int? get maxUses => throw _privateConstructorUsedError;
  int? get usedCount => throw _privateConstructorUsedError;
  bool get status => throw _privateConstructorUsedError;

  /// Serializes this DiscountModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscountModelCopyWith<DiscountModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscountModelCopyWith<$Res> {
  factory $DiscountModelCopyWith(
          DiscountModel value, $Res Function(DiscountModel) then) =
      _$DiscountModelCopyWithImpl<$Res, DiscountModel>;
  @useResult
  $Res call(
      {String id,
      String code,
      String type,
      double value,
      bool isValid,
      String? message,
      String? productId,
      DateTime? validFrom,
      DateTime? validUntil,
      int? maxUses,
      int? usedCount,
      bool status});
}

/// @nodoc
class _$DiscountModelCopyWithImpl<$Res, $Val extends DiscountModel>
    implements $DiscountModelCopyWith<$Res> {
  _$DiscountModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? type = null,
    Object? value = null,
    Object? isValid = null,
    Object? message = freezed,
    Object? productId = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? maxUses = freezed,
    Object? usedCount = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int?,
      usedCount: freezed == usedCount
          ? _value.usedCount
          : usedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiscountModelImplCopyWith<$Res>
    implements $DiscountModelCopyWith<$Res> {
  factory _$$DiscountModelImplCopyWith(
          _$DiscountModelImpl value, $Res Function(_$DiscountModelImpl) then) =
      __$$DiscountModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String type,
      double value,
      bool isValid,
      String? message,
      String? productId,
      DateTime? validFrom,
      DateTime? validUntil,
      int? maxUses,
      int? usedCount,
      bool status});
}

/// @nodoc
class __$$DiscountModelImplCopyWithImpl<$Res>
    extends _$DiscountModelCopyWithImpl<$Res, _$DiscountModelImpl>
    implements _$$DiscountModelImplCopyWith<$Res> {
  __$$DiscountModelImplCopyWithImpl(
      _$DiscountModelImpl _value, $Res Function(_$DiscountModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiscountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? type = null,
    Object? value = null,
    Object? isValid = null,
    Object? message = freezed,
    Object? productId = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? maxUses = freezed,
    Object? usedCount = freezed,
    Object? status = null,
  }) {
    return _then(_$DiscountModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int?,
      usedCount: freezed == usedCount
          ? _value.usedCount
          : usedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscountModelImpl implements _DiscountModel {
  const _$DiscountModelImpl(
      {required this.id,
      required this.code,
      required this.type,
      required this.value,
      required this.isValid,
      this.message,
      this.productId,
      this.validFrom,
      this.validUntil,
      this.maxUses,
      this.usedCount,
      this.status = true});

  factory _$DiscountModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscountModelImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String type;
  @override
  final double value;
  @override
  final bool isValid;
  @override
  final String? message;
  @override
  final String? productId;
  @override
  final DateTime? validFrom;
  @override
  final DateTime? validUntil;
  @override
  final int? maxUses;
  @override
  final int? usedCount;
  @override
  @JsonKey()
  final bool status;

  @override
  String toString() {
    return 'DiscountModel(id: $id, code: $code, type: $type, value: $value, isValid: $isValid, message: $message, productId: $productId, validFrom: $validFrom, validUntil: $validUntil, maxUses: $maxUses, usedCount: $usedCount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscountModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.usedCount, usedCount) ||
                other.usedCount == usedCount) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, code, type, value, isValid,
      message, productId, validFrom, validUntil, maxUses, usedCount, status);

  /// Create a copy of DiscountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscountModelImplCopyWith<_$DiscountModelImpl> get copyWith =>
      __$$DiscountModelImplCopyWithImpl<_$DiscountModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscountModelImplToJson(
      this,
    );
  }
}

abstract class _DiscountModel implements DiscountModel {
  const factory _DiscountModel(
      {required final String id,
      required final String code,
      required final String type,
      required final double value,
      required final bool isValid,
      final String? message,
      final String? productId,
      final DateTime? validFrom,
      final DateTime? validUntil,
      final int? maxUses,
      final int? usedCount,
      final bool status}) = _$DiscountModelImpl;

  factory _DiscountModel.fromJson(Map<String, dynamic> json) =
      _$DiscountModelImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get type;
  @override
  double get value;
  @override
  bool get isValid;
  @override
  String? get message;
  @override
  String? get productId;
  @override
  DateTime? get validFrom;
  @override
  DateTime? get validUntil;
  @override
  int? get maxUses;
  @override
  int? get usedCount;
  @override
  bool get status;

  /// Create a copy of DiscountModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscountModelImplCopyWith<_$DiscountModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
