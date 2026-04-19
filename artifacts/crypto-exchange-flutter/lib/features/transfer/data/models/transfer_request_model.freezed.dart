// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransferRequestModel _$TransferRequestModelFromJson(Map<String, dynamic> json) {
  return _TransferRequestModel.fromJson(json);
}

/// @nodoc
mixin _$TransferRequestModel {
  String get fromType =>
      throw _privateConstructorUsedError; // FIAT, SPOT, ECO, FUTURES
  String get fromCurrency =>
      throw _privateConstructorUsedError; // BTC, ETH, USD, etc.
  double get amount => throw _privateConstructorUsedError;
  String get transferType =>
      throw _privateConstructorUsedError; // "wallet" or "client"
// For wallet transfers
  String? get toType =>
      throw _privateConstructorUsedError; // Target wallet type
  String? get toCurrency =>
      throw _privateConstructorUsedError; // Target currency
// For client transfers
  String? get clientId => throw _privateConstructorUsedError;

  /// Serializes this TransferRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransferRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransferRequestModelCopyWith<TransferRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferRequestModelCopyWith<$Res> {
  factory $TransferRequestModelCopyWith(TransferRequestModel value,
          $Res Function(TransferRequestModel) then) =
      _$TransferRequestModelCopyWithImpl<$Res, TransferRequestModel>;
  @useResult
  $Res call(
      {String fromType,
      String fromCurrency,
      double amount,
      String transferType,
      String? toType,
      String? toCurrency,
      String? clientId});
}

/// @nodoc
class _$TransferRequestModelCopyWithImpl<$Res,
        $Val extends TransferRequestModel>
    implements $TransferRequestModelCopyWith<$Res> {
  _$TransferRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransferRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromType = null,
    Object? fromCurrency = null,
    Object? amount = null,
    Object? transferType = null,
    Object? toType = freezed,
    Object? toCurrency = freezed,
    Object? clientId = freezed,
  }) {
    return _then(_value.copyWith(
      fromType: null == fromType
          ? _value.fromType
          : fromType // ignore: cast_nullable_to_non_nullable
              as String,
      fromCurrency: null == fromCurrency
          ? _value.fromCurrency
          : fromCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      transferType: null == transferType
          ? _value.transferType
          : transferType // ignore: cast_nullable_to_non_nullable
              as String,
      toType: freezed == toType
          ? _value.toType
          : toType // ignore: cast_nullable_to_non_nullable
              as String?,
      toCurrency: freezed == toCurrency
          ? _value.toCurrency
          : toCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferRequestModelImplCopyWith<$Res>
    implements $TransferRequestModelCopyWith<$Res> {
  factory _$$TransferRequestModelImplCopyWith(_$TransferRequestModelImpl value,
          $Res Function(_$TransferRequestModelImpl) then) =
      __$$TransferRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fromType,
      String fromCurrency,
      double amount,
      String transferType,
      String? toType,
      String? toCurrency,
      String? clientId});
}

/// @nodoc
class __$$TransferRequestModelImplCopyWithImpl<$Res>
    extends _$TransferRequestModelCopyWithImpl<$Res, _$TransferRequestModelImpl>
    implements _$$TransferRequestModelImplCopyWith<$Res> {
  __$$TransferRequestModelImplCopyWithImpl(_$TransferRequestModelImpl _value,
      $Res Function(_$TransferRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransferRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromType = null,
    Object? fromCurrency = null,
    Object? amount = null,
    Object? transferType = null,
    Object? toType = freezed,
    Object? toCurrency = freezed,
    Object? clientId = freezed,
  }) {
    return _then(_$TransferRequestModelImpl(
      fromType: null == fromType
          ? _value.fromType
          : fromType // ignore: cast_nullable_to_non_nullable
              as String,
      fromCurrency: null == fromCurrency
          ? _value.fromCurrency
          : fromCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      transferType: null == transferType
          ? _value.transferType
          : transferType // ignore: cast_nullable_to_non_nullable
              as String,
      toType: freezed == toType
          ? _value.toType
          : toType // ignore: cast_nullable_to_non_nullable
              as String?,
      toCurrency: freezed == toCurrency
          ? _value.toCurrency
          : toCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferRequestModelImpl implements _TransferRequestModel {
  const _$TransferRequestModelImpl(
      {required this.fromType,
      required this.fromCurrency,
      required this.amount,
      required this.transferType,
      this.toType,
      this.toCurrency,
      this.clientId});

  factory _$TransferRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferRequestModelImplFromJson(json);

  @override
  final String fromType;
// FIAT, SPOT, ECO, FUTURES
  @override
  final String fromCurrency;
// BTC, ETH, USD, etc.
  @override
  final double amount;
  @override
  final String transferType;
// "wallet" or "client"
// For wallet transfers
  @override
  final String? toType;
// Target wallet type
  @override
  final String? toCurrency;
// Target currency
// For client transfers
  @override
  final String? clientId;

  @override
  String toString() {
    return 'TransferRequestModel(fromType: $fromType, fromCurrency: $fromCurrency, amount: $amount, transferType: $transferType, toType: $toType, toCurrency: $toCurrency, clientId: $clientId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferRequestModelImpl &&
            (identical(other.fromType, fromType) ||
                other.fromType == fromType) &&
            (identical(other.fromCurrency, fromCurrency) ||
                other.fromCurrency == fromCurrency) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.transferType, transferType) ||
                other.transferType == transferType) &&
            (identical(other.toType, toType) || other.toType == toType) &&
            (identical(other.toCurrency, toCurrency) ||
                other.toCurrency == toCurrency) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fromType, fromCurrency, amount,
      transferType, toType, toCurrency, clientId);

  /// Create a copy of TransferRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferRequestModelImplCopyWith<_$TransferRequestModelImpl>
      get copyWith =>
          __$$TransferRequestModelImplCopyWithImpl<_$TransferRequestModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferRequestModelImplToJson(
      this,
    );
  }
}

abstract class _TransferRequestModel implements TransferRequestModel {
  const factory _TransferRequestModel(
      {required final String fromType,
      required final String fromCurrency,
      required final double amount,
      required final String transferType,
      final String? toType,
      final String? toCurrency,
      final String? clientId}) = _$TransferRequestModelImpl;

  factory _TransferRequestModel.fromJson(Map<String, dynamic> json) =
      _$TransferRequestModelImpl.fromJson;

  @override
  String get fromType; // FIAT, SPOT, ECO, FUTURES
  @override
  String get fromCurrency; // BTC, ETH, USD, etc.
  @override
  double get amount;
  @override
  String get transferType; // "wallet" or "client"
// For wallet transfers
  @override
  String? get toType; // Target wallet type
  @override
  String? get toCurrency; // Target currency
// For client transfers
  @override
  String? get clientId;

  /// Create a copy of TransferRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransferRequestModelImplCopyWith<_$TransferRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
