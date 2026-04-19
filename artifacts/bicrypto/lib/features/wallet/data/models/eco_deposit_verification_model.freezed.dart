// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eco_deposit_verification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EcoDepositVerificationModel _$EcoDepositVerificationModelFromJson(
    Map<String, dynamic> json) {
  return _EcoDepositVerificationModel.fromJson(json);
}

/// @nodoc
mixin _$EcoDepositVerificationModel {
  String get status => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  EcoTransactionModel? get transaction => throw _privateConstructorUsedError;
  EcoWalletModel? get wallet => throw _privateConstructorUsedError;
  Map<String, dynamic>? get trx => throw _privateConstructorUsedError;
  double? get balance => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  String? get chain => throw _privateConstructorUsedError;
  String? get method => throw _privateConstructorUsedError;

  /// Serializes this EcoDepositVerificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoDepositVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoDepositVerificationModelCopyWith<EcoDepositVerificationModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoDepositVerificationModelCopyWith<$Res> {
  factory $EcoDepositVerificationModelCopyWith(
          EcoDepositVerificationModel value,
          $Res Function(EcoDepositVerificationModel) then) =
      _$EcoDepositVerificationModelCopyWithImpl<$Res,
          EcoDepositVerificationModel>;
  @useResult
  $Res call(
      {String status,
      String message,
      EcoTransactionModel? transaction,
      EcoWalletModel? wallet,
      Map<String, dynamic>? trx,
      double? balance,
      String? currency,
      String? chain,
      String? method});

  $EcoTransactionModelCopyWith<$Res>? get transaction;
  $EcoWalletModelCopyWith<$Res>? get wallet;
}

/// @nodoc
class _$EcoDepositVerificationModelCopyWithImpl<$Res,
        $Val extends EcoDepositVerificationModel>
    implements $EcoDepositVerificationModelCopyWith<$Res> {
  _$EcoDepositVerificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoDepositVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? transaction = freezed,
    Object? wallet = freezed,
    Object? trx = freezed,
    Object? balance = freezed,
    Object? currency = freezed,
    Object? chain = freezed,
    Object? method = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as EcoTransactionModel?,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as EcoWalletModel?,
      trx: freezed == trx
          ? _value.trx
          : trx // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of EcoDepositVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EcoTransactionModelCopyWith<$Res>? get transaction {
    if (_value.transaction == null) {
      return null;
    }

    return $EcoTransactionModelCopyWith<$Res>(_value.transaction!, (value) {
      return _then(_value.copyWith(transaction: value) as $Val);
    });
  }

  /// Create a copy of EcoDepositVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EcoWalletModelCopyWith<$Res>? get wallet {
    if (_value.wallet == null) {
      return null;
    }

    return $EcoWalletModelCopyWith<$Res>(_value.wallet!, (value) {
      return _then(_value.copyWith(wallet: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EcoDepositVerificationModelImplCopyWith<$Res>
    implements $EcoDepositVerificationModelCopyWith<$Res> {
  factory _$$EcoDepositVerificationModelImplCopyWith(
          _$EcoDepositVerificationModelImpl value,
          $Res Function(_$EcoDepositVerificationModelImpl) then) =
      __$$EcoDepositVerificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String status,
      String message,
      EcoTransactionModel? transaction,
      EcoWalletModel? wallet,
      Map<String, dynamic>? trx,
      double? balance,
      String? currency,
      String? chain,
      String? method});

  @override
  $EcoTransactionModelCopyWith<$Res>? get transaction;
  @override
  $EcoWalletModelCopyWith<$Res>? get wallet;
}

/// @nodoc
class __$$EcoDepositVerificationModelImplCopyWithImpl<$Res>
    extends _$EcoDepositVerificationModelCopyWithImpl<$Res,
        _$EcoDepositVerificationModelImpl>
    implements _$$EcoDepositVerificationModelImplCopyWith<$Res> {
  __$$EcoDepositVerificationModelImplCopyWithImpl(
      _$EcoDepositVerificationModelImpl _value,
      $Res Function(_$EcoDepositVerificationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoDepositVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? transaction = freezed,
    Object? wallet = freezed,
    Object? trx = freezed,
    Object? balance = freezed,
    Object? currency = freezed,
    Object? chain = freezed,
    Object? method = freezed,
  }) {
    return _then(_$EcoDepositVerificationModelImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as EcoTransactionModel?,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as EcoWalletModel?,
      trx: freezed == trx
          ? _value._trx
          : trx // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoDepositVerificationModelImpl
    implements _EcoDepositVerificationModel {
  const _$EcoDepositVerificationModelImpl(
      {required this.status,
      required this.message,
      this.transaction,
      this.wallet,
      final Map<String, dynamic>? trx,
      this.balance,
      this.currency,
      this.chain,
      this.method})
      : _trx = trx;

  factory _$EcoDepositVerificationModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$EcoDepositVerificationModelImplFromJson(json);

  @override
  final String status;
  @override
  final String message;
  @override
  final EcoTransactionModel? transaction;
  @override
  final EcoWalletModel? wallet;
  final Map<String, dynamic>? _trx;
  @override
  Map<String, dynamic>? get trx {
    final value = _trx;
    if (value == null) return null;
    if (_trx is EqualUnmodifiableMapView) return _trx;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final double? balance;
  @override
  final String? currency;
  @override
  final String? chain;
  @override
  final String? method;

  @override
  String toString() {
    return 'EcoDepositVerificationModel(status: $status, message: $message, transaction: $transaction, wallet: $wallet, trx: $trx, balance: $balance, currency: $currency, chain: $chain, method: $method)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoDepositVerificationModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.wallet, wallet) || other.wallet == wallet) &&
            const DeepCollectionEquality().equals(other._trx, _trx) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.chain, chain) || other.chain == chain) &&
            (identical(other.method, method) || other.method == method));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      message,
      transaction,
      wallet,
      const DeepCollectionEquality().hash(_trx),
      balance,
      currency,
      chain,
      method);

  /// Create a copy of EcoDepositVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoDepositVerificationModelImplCopyWith<_$EcoDepositVerificationModelImpl>
      get copyWith => __$$EcoDepositVerificationModelImplCopyWithImpl<
          _$EcoDepositVerificationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoDepositVerificationModelImplToJson(
      this,
    );
  }
}

abstract class _EcoDepositVerificationModel
    implements EcoDepositVerificationModel {
  const factory _EcoDepositVerificationModel(
      {required final String status,
      required final String message,
      final EcoTransactionModel? transaction,
      final EcoWalletModel? wallet,
      final Map<String, dynamic>? trx,
      final double? balance,
      final String? currency,
      final String? chain,
      final String? method}) = _$EcoDepositVerificationModelImpl;

  factory _EcoDepositVerificationModel.fromJson(Map<String, dynamic> json) =
      _$EcoDepositVerificationModelImpl.fromJson;

  @override
  String get status;
  @override
  String get message;
  @override
  EcoTransactionModel? get transaction;
  @override
  EcoWalletModel? get wallet;
  @override
  Map<String, dynamic>? get trx;
  @override
  double? get balance;
  @override
  String? get currency;
  @override
  String? get chain;
  @override
  String? get method;

  /// Create a copy of EcoDepositVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoDepositVerificationModelImplCopyWith<_$EcoDepositVerificationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
