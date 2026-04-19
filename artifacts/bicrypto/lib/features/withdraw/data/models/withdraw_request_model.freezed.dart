// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdraw_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WithdrawRequestModel _$WithdrawRequestModelFromJson(Map<String, dynamic> json) {
  return _WithdrawRequestModel.fromJson(json);
}

/// @nodoc
mixin _$WithdrawRequestModel {
  String get walletType => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get methodId => throw _privateConstructorUsedError;
  String? get toAddress => throw _privateConstructorUsedError;
  String? get chain => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customFields => throw _privateConstructorUsedError;

  /// Serializes this WithdrawRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawRequestModelCopyWith<WithdrawRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawRequestModelCopyWith<$Res> {
  factory $WithdrawRequestModelCopyWith(WithdrawRequestModel value,
          $Res Function(WithdrawRequestModel) then) =
      _$WithdrawRequestModelCopyWithImpl<$Res, WithdrawRequestModel>;
  @useResult
  $Res call(
      {String walletType,
      String currency,
      double amount,
      String? methodId,
      String? toAddress,
      String? chain,
      String? memo,
      Map<String, dynamic>? customFields});
}

/// @nodoc
class _$WithdrawRequestModelCopyWithImpl<$Res,
        $Val extends WithdrawRequestModel>
    implements $WithdrawRequestModelCopyWith<$Res> {
  _$WithdrawRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? walletType = null,
    Object? currency = null,
    Object? amount = null,
    Object? methodId = freezed,
    Object? toAddress = freezed,
    Object? chain = freezed,
    Object? memo = freezed,
    Object? customFields = freezed,
  }) {
    return _then(_value.copyWith(
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      methodId: freezed == methodId
          ? _value.methodId
          : methodId // ignore: cast_nullable_to_non_nullable
              as String?,
      toAddress: freezed == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      customFields: freezed == customFields
          ? _value.customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WithdrawRequestModelImplCopyWith<$Res>
    implements $WithdrawRequestModelCopyWith<$Res> {
  factory _$$WithdrawRequestModelImplCopyWith(_$WithdrawRequestModelImpl value,
          $Res Function(_$WithdrawRequestModelImpl) then) =
      __$$WithdrawRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String walletType,
      String currency,
      double amount,
      String? methodId,
      String? toAddress,
      String? chain,
      String? memo,
      Map<String, dynamic>? customFields});
}

/// @nodoc
class __$$WithdrawRequestModelImplCopyWithImpl<$Res>
    extends _$WithdrawRequestModelCopyWithImpl<$Res, _$WithdrawRequestModelImpl>
    implements _$$WithdrawRequestModelImplCopyWith<$Res> {
  __$$WithdrawRequestModelImplCopyWithImpl(_$WithdrawRequestModelImpl _value,
      $Res Function(_$WithdrawRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WithdrawRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? walletType = null,
    Object? currency = null,
    Object? amount = null,
    Object? methodId = freezed,
    Object? toAddress = freezed,
    Object? chain = freezed,
    Object? memo = freezed,
    Object? customFields = freezed,
  }) {
    return _then(_$WithdrawRequestModelImpl(
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      methodId: freezed == methodId
          ? _value.methodId
          : methodId // ignore: cast_nullable_to_non_nullable
              as String?,
      toAddress: freezed == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      customFields: freezed == customFields
          ? _value._customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WithdrawRequestModelImpl extends _WithdrawRequestModel {
  const _$WithdrawRequestModelImpl(
      {required this.walletType,
      required this.currency,
      required this.amount,
      this.methodId,
      this.toAddress,
      this.chain,
      this.memo,
      final Map<String, dynamic>? customFields})
      : _customFields = customFields,
        super._();

  factory _$WithdrawRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WithdrawRequestModelImplFromJson(json);

  @override
  final String walletType;
  @override
  final String currency;
  @override
  final double amount;
  @override
  final String? methodId;
  @override
  final String? toAddress;
  @override
  final String? chain;
  @override
  final String? memo;
  final Map<String, dynamic>? _customFields;
  @override
  Map<String, dynamic>? get customFields {
    final value = _customFields;
    if (value == null) return null;
    if (_customFields is EqualUnmodifiableMapView) return _customFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'WithdrawRequestModel(walletType: $walletType, currency: $currency, amount: $amount, methodId: $methodId, toAddress: $toAddress, chain: $chain, memo: $memo, customFields: $customFields)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawRequestModelImpl &&
            (identical(other.walletType, walletType) ||
                other.walletType == walletType) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.methodId, methodId) ||
                other.methodId == methodId) &&
            (identical(other.toAddress, toAddress) ||
                other.toAddress == toAddress) &&
            (identical(other.chain, chain) || other.chain == chain) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            const DeepCollectionEquality()
                .equals(other._customFields, _customFields));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      walletType,
      currency,
      amount,
      methodId,
      toAddress,
      chain,
      memo,
      const DeepCollectionEquality().hash(_customFields));

  /// Create a copy of WithdrawRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawRequestModelImplCopyWith<_$WithdrawRequestModelImpl>
      get copyWith =>
          __$$WithdrawRequestModelImplCopyWithImpl<_$WithdrawRequestModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WithdrawRequestModelImplToJson(
      this,
    );
  }
}

abstract class _WithdrawRequestModel extends WithdrawRequestModel {
  const factory _WithdrawRequestModel(
      {required final String walletType,
      required final String currency,
      required final double amount,
      final String? methodId,
      final String? toAddress,
      final String? chain,
      final String? memo,
      final Map<String, dynamic>? customFields}) = _$WithdrawRequestModelImpl;
  const _WithdrawRequestModel._() : super._();

  factory _WithdrawRequestModel.fromJson(Map<String, dynamic> json) =
      _$WithdrawRequestModelImpl.fromJson;

  @override
  String get walletType;
  @override
  String get currency;
  @override
  double get amount;
  @override
  String? get methodId;
  @override
  String? get toAddress;
  @override
  String? get chain;
  @override
  String? get memo;
  @override
  Map<String, dynamic>? get customFields;

  /// Create a copy of WithdrawRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawRequestModelImplCopyWith<_$WithdrawRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
