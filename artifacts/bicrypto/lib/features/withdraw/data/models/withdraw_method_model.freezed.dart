// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdraw_method_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WithdrawMethodModel _$WithdrawMethodModelFromJson(Map<String, dynamic> json) {
  return _WithdrawMethodModel.fromJson(json);
}

/// @nodoc
mixin _$WithdrawMethodModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get instructions => throw _privateConstructorUsedError;
  double? get fixedFee => throw _privateConstructorUsedError;
  double? get percentageFee => throw _privateConstructorUsedError;
  double? get minAmount => throw _privateConstructorUsedError;
  double? get maxAmount => throw _privateConstructorUsedError;
  String? get network => throw _privateConstructorUsedError;
  String? get customFields => throw _privateConstructorUsedError; // JSON string
  String? get image => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this WithdrawMethodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawMethodModelCopyWith<WithdrawMethodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawMethodModelCopyWith<$Res> {
  factory $WithdrawMethodModelCopyWith(
          WithdrawMethodModel value, $Res Function(WithdrawMethodModel) then) =
      _$WithdrawMethodModelCopyWithImpl<$Res, WithdrawMethodModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? instructions,
      double? fixedFee,
      double? percentageFee,
      double? minAmount,
      double? maxAmount,
      String? network,
      String? customFields,
      String? image,
      bool isActive});
}

/// @nodoc
class _$WithdrawMethodModelCopyWithImpl<$Res, $Val extends WithdrawMethodModel>
    implements $WithdrawMethodModelCopyWith<$Res> {
  _$WithdrawMethodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? instructions = freezed,
    Object? fixedFee = freezed,
    Object? percentageFee = freezed,
    Object? minAmount = freezed,
    Object? maxAmount = freezed,
    Object? network = freezed,
    Object? customFields = freezed,
    Object? image = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      fixedFee: freezed == fixedFee
          ? _value.fixedFee
          : fixedFee // ignore: cast_nullable_to_non_nullable
              as double?,
      percentageFee: freezed == percentageFee
          ? _value.percentageFee
          : percentageFee // ignore: cast_nullable_to_non_nullable
              as double?,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxAmount: freezed == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      customFields: freezed == customFields
          ? _value.customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WithdrawMethodModelImplCopyWith<$Res>
    implements $WithdrawMethodModelCopyWith<$Res> {
  factory _$$WithdrawMethodModelImplCopyWith(_$WithdrawMethodModelImpl value,
          $Res Function(_$WithdrawMethodModelImpl) then) =
      __$$WithdrawMethodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? instructions,
      double? fixedFee,
      double? percentageFee,
      double? minAmount,
      double? maxAmount,
      String? network,
      String? customFields,
      String? image,
      bool isActive});
}

/// @nodoc
class __$$WithdrawMethodModelImplCopyWithImpl<$Res>
    extends _$WithdrawMethodModelCopyWithImpl<$Res, _$WithdrawMethodModelImpl>
    implements _$$WithdrawMethodModelImplCopyWith<$Res> {
  __$$WithdrawMethodModelImplCopyWithImpl(_$WithdrawMethodModelImpl _value,
      $Res Function(_$WithdrawMethodModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WithdrawMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? instructions = freezed,
    Object? fixedFee = freezed,
    Object? percentageFee = freezed,
    Object? minAmount = freezed,
    Object? maxAmount = freezed,
    Object? network = freezed,
    Object? customFields = freezed,
    Object? image = freezed,
    Object? isActive = null,
  }) {
    return _then(_$WithdrawMethodModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      fixedFee: freezed == fixedFee
          ? _value.fixedFee
          : fixedFee // ignore: cast_nullable_to_non_nullable
              as double?,
      percentageFee: freezed == percentageFee
          ? _value.percentageFee
          : percentageFee // ignore: cast_nullable_to_non_nullable
              as double?,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxAmount: freezed == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      customFields: freezed == customFields
          ? _value.customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WithdrawMethodModelImpl extends _WithdrawMethodModel {
  const _$WithdrawMethodModelImpl(
      {required this.id,
      required this.title,
      this.instructions,
      this.fixedFee,
      this.percentageFee,
      this.minAmount,
      this.maxAmount,
      this.network,
      this.customFields,
      this.image,
      this.isActive = true})
      : super._();

  factory _$WithdrawMethodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WithdrawMethodModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? instructions;
  @override
  final double? fixedFee;
  @override
  final double? percentageFee;
  @override
  final double? minAmount;
  @override
  final double? maxAmount;
  @override
  final String? network;
  @override
  final String? customFields;
// JSON string
  @override
  final String? image;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'WithdrawMethodModel(id: $id, title: $title, instructions: $instructions, fixedFee: $fixedFee, percentageFee: $percentageFee, minAmount: $minAmount, maxAmount: $maxAmount, network: $network, customFields: $customFields, image: $image, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawMethodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.fixedFee, fixedFee) ||
                other.fixedFee == fixedFee) &&
            (identical(other.percentageFee, percentageFee) ||
                other.percentageFee == percentageFee) &&
            (identical(other.minAmount, minAmount) ||
                other.minAmount == minAmount) &&
            (identical(other.maxAmount, maxAmount) ||
                other.maxAmount == maxAmount) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.customFields, customFields) ||
                other.customFields == customFields) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      instructions,
      fixedFee,
      percentageFee,
      minAmount,
      maxAmount,
      network,
      customFields,
      image,
      isActive);

  /// Create a copy of WithdrawMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawMethodModelImplCopyWith<_$WithdrawMethodModelImpl> get copyWith =>
      __$$WithdrawMethodModelImplCopyWithImpl<_$WithdrawMethodModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WithdrawMethodModelImplToJson(
      this,
    );
  }
}

abstract class _WithdrawMethodModel extends WithdrawMethodModel {
  const factory _WithdrawMethodModel(
      {required final String id,
      required final String title,
      final String? instructions,
      final double? fixedFee,
      final double? percentageFee,
      final double? minAmount,
      final double? maxAmount,
      final String? network,
      final String? customFields,
      final String? image,
      final bool isActive}) = _$WithdrawMethodModelImpl;
  const _WithdrawMethodModel._() : super._();

  factory _WithdrawMethodModel.fromJson(Map<String, dynamic> json) =
      _$WithdrawMethodModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get instructions;
  @override
  double? get fixedFee;
  @override
  double? get percentageFee;
  @override
  double? get minAmount;
  @override
  double? get maxAmount;
  @override
  String? get network;
  @override
  String? get customFields; // JSON string
  @override
  String? get image;
  @override
  bool get isActive;

  /// Create a copy of WithdrawMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawMethodModelImplCopyWith<_$WithdrawMethodModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
