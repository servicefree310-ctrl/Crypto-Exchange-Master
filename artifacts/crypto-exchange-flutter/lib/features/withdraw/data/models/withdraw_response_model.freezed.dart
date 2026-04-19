// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdraw_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WithdrawResponseModel _$WithdrawResponseModelFromJson(
    Map<String, dynamic> json) {
  return _WithdrawResponseModel.fromJson(json);
}

/// @nodoc
mixin _$WithdrawResponseModel {
  String get message => throw _privateConstructorUsedError;
  WithdrawTransactionModel? get transaction =>
      throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  String? get method => throw _privateConstructorUsedError;
  double? get balance => throw _privateConstructorUsedError;

  /// Serializes this WithdrawResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawResponseModelCopyWith<WithdrawResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawResponseModelCopyWith<$Res> {
  factory $WithdrawResponseModelCopyWith(WithdrawResponseModel value,
          $Res Function(WithdrawResponseModel) then) =
      _$WithdrawResponseModelCopyWithImpl<$Res, WithdrawResponseModel>;
  @useResult
  $Res call(
      {String message,
      WithdrawTransactionModel? transaction,
      String? currency,
      String? method,
      double? balance});

  $WithdrawTransactionModelCopyWith<$Res>? get transaction;
}

/// @nodoc
class _$WithdrawResponseModelCopyWithImpl<$Res,
        $Val extends WithdrawResponseModel>
    implements $WithdrawResponseModelCopyWith<$Res> {
  _$WithdrawResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? transaction = freezed,
    Object? currency = freezed,
    Object? method = freezed,
    Object? balance = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as WithdrawTransactionModel?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  /// Create a copy of WithdrawResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WithdrawTransactionModelCopyWith<$Res>? get transaction {
    if (_value.transaction == null) {
      return null;
    }

    return $WithdrawTransactionModelCopyWith<$Res>(_value.transaction!,
        (value) {
      return _then(_value.copyWith(transaction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WithdrawResponseModelImplCopyWith<$Res>
    implements $WithdrawResponseModelCopyWith<$Res> {
  factory _$$WithdrawResponseModelImplCopyWith(
          _$WithdrawResponseModelImpl value,
          $Res Function(_$WithdrawResponseModelImpl) then) =
      __$$WithdrawResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      WithdrawTransactionModel? transaction,
      String? currency,
      String? method,
      double? balance});

  @override
  $WithdrawTransactionModelCopyWith<$Res>? get transaction;
}

/// @nodoc
class __$$WithdrawResponseModelImplCopyWithImpl<$Res>
    extends _$WithdrawResponseModelCopyWithImpl<$Res,
        _$WithdrawResponseModelImpl>
    implements _$$WithdrawResponseModelImplCopyWith<$Res> {
  __$$WithdrawResponseModelImplCopyWithImpl(_$WithdrawResponseModelImpl _value,
      $Res Function(_$WithdrawResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WithdrawResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? transaction = freezed,
    Object? currency = freezed,
    Object? method = freezed,
    Object? balance = freezed,
  }) {
    return _then(_$WithdrawResponseModelImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as WithdrawTransactionModel?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WithdrawResponseModelImpl extends _WithdrawResponseModel {
  const _$WithdrawResponseModelImpl(
      {required this.message,
      this.transaction,
      this.currency,
      this.method,
      this.balance})
      : super._();

  factory _$WithdrawResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WithdrawResponseModelImplFromJson(json);

  @override
  final String message;
  @override
  final WithdrawTransactionModel? transaction;
  @override
  final String? currency;
  @override
  final String? method;
  @override
  final double? balance;

  @override
  String toString() {
    return 'WithdrawResponseModel(message: $message, transaction: $transaction, currency: $currency, method: $method, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawResponseModelImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.balance, balance) || other.balance == balance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, message, transaction, currency, method, balance);

  /// Create a copy of WithdrawResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawResponseModelImplCopyWith<_$WithdrawResponseModelImpl>
      get copyWith => __$$WithdrawResponseModelImplCopyWithImpl<
          _$WithdrawResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WithdrawResponseModelImplToJson(
      this,
    );
  }
}

abstract class _WithdrawResponseModel extends WithdrawResponseModel {
  const factory _WithdrawResponseModel(
      {required final String message,
      final WithdrawTransactionModel? transaction,
      final String? currency,
      final String? method,
      final double? balance}) = _$WithdrawResponseModelImpl;
  const _WithdrawResponseModel._() : super._();

  factory _WithdrawResponseModel.fromJson(Map<String, dynamic> json) =
      _$WithdrawResponseModelImpl.fromJson;

  @override
  String get message;
  @override
  WithdrawTransactionModel? get transaction;
  @override
  String? get currency;
  @override
  String? get method;
  @override
  double? get balance;

  /// Create a copy of WithdrawResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawResponseModelImplCopyWith<_$WithdrawResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WithdrawTransactionModel _$WithdrawTransactionModelFromJson(
    Map<String, dynamic> json) {
  return _WithdrawTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$WithdrawTransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get walletId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get fee => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WithdrawTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawTransactionModelCopyWith<WithdrawTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawTransactionModelCopyWith<$Res> {
  factory $WithdrawTransactionModelCopyWith(WithdrawTransactionModel value,
          $Res Function(WithdrawTransactionModel) then) =
      _$WithdrawTransactionModelCopyWithImpl<$Res, WithdrawTransactionModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String walletId,
      String type,
      double amount,
      double fee,
      String status,
      String? description,
      Map<String, dynamic>? metadata,
      String? referenceId,
      String createdAt,
      String? updatedAt});
}

/// @nodoc
class _$WithdrawTransactionModelCopyWithImpl<$Res,
        $Val extends WithdrawTransactionModel>
    implements $WithdrawTransactionModelCopyWith<$Res> {
  _$WithdrawTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? walletId = null,
    Object? type = null,
    Object? amount = null,
    Object? fee = null,
    Object? status = null,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? referenceId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      walletId: null == walletId
          ? _value.walletId
          : walletId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      fee: null == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WithdrawTransactionModelImplCopyWith<$Res>
    implements $WithdrawTransactionModelCopyWith<$Res> {
  factory _$$WithdrawTransactionModelImplCopyWith(
          _$WithdrawTransactionModelImpl value,
          $Res Function(_$WithdrawTransactionModelImpl) then) =
      __$$WithdrawTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String walletId,
      String type,
      double amount,
      double fee,
      String status,
      String? description,
      Map<String, dynamic>? metadata,
      String? referenceId,
      String createdAt,
      String? updatedAt});
}

/// @nodoc
class __$$WithdrawTransactionModelImplCopyWithImpl<$Res>
    extends _$WithdrawTransactionModelCopyWithImpl<$Res,
        _$WithdrawTransactionModelImpl>
    implements _$$WithdrawTransactionModelImplCopyWith<$Res> {
  __$$WithdrawTransactionModelImplCopyWithImpl(
      _$WithdrawTransactionModelImpl _value,
      $Res Function(_$WithdrawTransactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WithdrawTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? walletId = null,
    Object? type = null,
    Object? amount = null,
    Object? fee = null,
    Object? status = null,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? referenceId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WithdrawTransactionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      walletId: null == walletId
          ? _value.walletId
          : walletId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      fee: null == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WithdrawTransactionModelImpl extends _WithdrawTransactionModel {
  const _$WithdrawTransactionModelImpl(
      {required this.id,
      required this.userId,
      required this.walletId,
      required this.type,
      required this.amount,
      required this.fee,
      required this.status,
      this.description,
      final Map<String, dynamic>? metadata,
      this.referenceId,
      required this.createdAt,
      this.updatedAt})
      : _metadata = metadata,
        super._();

  factory _$WithdrawTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WithdrawTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String walletId;
  @override
  final String type;
  @override
  final double amount;
  @override
  final double fee;
  @override
  final String status;
  @override
  final String? description;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? referenceId;
  @override
  final String createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'WithdrawTransactionModel(id: $id, userId: $userId, walletId: $walletId, type: $type, amount: $amount, fee: $fee, status: $status, description: $description, metadata: $metadata, referenceId: $referenceId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.walletId, walletId) ||
                other.walletId == walletId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      walletId,
      type,
      amount,
      fee,
      status,
      description,
      const DeepCollectionEquality().hash(_metadata),
      referenceId,
      createdAt,
      updatedAt);

  /// Create a copy of WithdrawTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawTransactionModelImplCopyWith<_$WithdrawTransactionModelImpl>
      get copyWith => __$$WithdrawTransactionModelImplCopyWithImpl<
          _$WithdrawTransactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WithdrawTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _WithdrawTransactionModel extends WithdrawTransactionModel {
  const factory _WithdrawTransactionModel(
      {required final String id,
      required final String userId,
      required final String walletId,
      required final String type,
      required final double amount,
      required final double fee,
      required final String status,
      final String? description,
      final Map<String, dynamic>? metadata,
      final String? referenceId,
      required final String createdAt,
      final String? updatedAt}) = _$WithdrawTransactionModelImpl;
  const _WithdrawTransactionModel._() : super._();

  factory _WithdrawTransactionModel.fromJson(Map<String, dynamic> json) =
      _$WithdrawTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get walletId;
  @override
  String get type;
  @override
  double get amount;
  @override
  double get fee;
  @override
  String get status;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get referenceId;
  @override
  String get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of WithdrawTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawTransactionModelImplCopyWith<_$WithdrawTransactionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
