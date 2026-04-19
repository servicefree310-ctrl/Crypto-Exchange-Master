// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransferResponseModel _$TransferResponseModelFromJson(
    Map<String, dynamic> json) {
  return _TransferResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TransferResponseModel {
  String get message => throw _privateConstructorUsedError;
  TransferTransactionModel get fromTransfer =>
      throw _privateConstructorUsedError;
  TransferTransactionModel get toTransfer => throw _privateConstructorUsedError;
  String get fromType => throw _privateConstructorUsedError;
  String get toType => throw _privateConstructorUsedError;
  String get fromCurrency => throw _privateConstructorUsedError;
  String get toCurrency => throw _privateConstructorUsedError;

  /// Serializes this TransferResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransferResponseModelCopyWith<TransferResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferResponseModelCopyWith<$Res> {
  factory $TransferResponseModelCopyWith(TransferResponseModel value,
          $Res Function(TransferResponseModel) then) =
      _$TransferResponseModelCopyWithImpl<$Res, TransferResponseModel>;
  @useResult
  $Res call(
      {String message,
      TransferTransactionModel fromTransfer,
      TransferTransactionModel toTransfer,
      String fromType,
      String toType,
      String fromCurrency,
      String toCurrency});

  $TransferTransactionModelCopyWith<$Res> get fromTransfer;
  $TransferTransactionModelCopyWith<$Res> get toTransfer;
}

/// @nodoc
class _$TransferResponseModelCopyWithImpl<$Res,
        $Val extends TransferResponseModel>
    implements $TransferResponseModelCopyWith<$Res> {
  _$TransferResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? fromTransfer = null,
    Object? toTransfer = null,
    Object? fromType = null,
    Object? toType = null,
    Object? fromCurrency = null,
    Object? toCurrency = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      fromTransfer: null == fromTransfer
          ? _value.fromTransfer
          : fromTransfer // ignore: cast_nullable_to_non_nullable
              as TransferTransactionModel,
      toTransfer: null == toTransfer
          ? _value.toTransfer
          : toTransfer // ignore: cast_nullable_to_non_nullable
              as TransferTransactionModel,
      fromType: null == fromType
          ? _value.fromType
          : fromType // ignore: cast_nullable_to_non_nullable
              as String,
      toType: null == toType
          ? _value.toType
          : toType // ignore: cast_nullable_to_non_nullable
              as String,
      fromCurrency: null == fromCurrency
          ? _value.fromCurrency
          : fromCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      toCurrency: null == toCurrency
          ? _value.toCurrency
          : toCurrency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of TransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TransferTransactionModelCopyWith<$Res> get fromTransfer {
    return $TransferTransactionModelCopyWith<$Res>(_value.fromTransfer,
        (value) {
      return _then(_value.copyWith(fromTransfer: value) as $Val);
    });
  }

  /// Create a copy of TransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TransferTransactionModelCopyWith<$Res> get toTransfer {
    return $TransferTransactionModelCopyWith<$Res>(_value.toTransfer, (value) {
      return _then(_value.copyWith(toTransfer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TransferResponseModelImplCopyWith<$Res>
    implements $TransferResponseModelCopyWith<$Res> {
  factory _$$TransferResponseModelImplCopyWith(
          _$TransferResponseModelImpl value,
          $Res Function(_$TransferResponseModelImpl) then) =
      __$$TransferResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      TransferTransactionModel fromTransfer,
      TransferTransactionModel toTransfer,
      String fromType,
      String toType,
      String fromCurrency,
      String toCurrency});

  @override
  $TransferTransactionModelCopyWith<$Res> get fromTransfer;
  @override
  $TransferTransactionModelCopyWith<$Res> get toTransfer;
}

/// @nodoc
class __$$TransferResponseModelImplCopyWithImpl<$Res>
    extends _$TransferResponseModelCopyWithImpl<$Res,
        _$TransferResponseModelImpl>
    implements _$$TransferResponseModelImplCopyWith<$Res> {
  __$$TransferResponseModelImplCopyWithImpl(_$TransferResponseModelImpl _value,
      $Res Function(_$TransferResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? fromTransfer = null,
    Object? toTransfer = null,
    Object? fromType = null,
    Object? toType = null,
    Object? fromCurrency = null,
    Object? toCurrency = null,
  }) {
    return _then(_$TransferResponseModelImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      fromTransfer: null == fromTransfer
          ? _value.fromTransfer
          : fromTransfer // ignore: cast_nullable_to_non_nullable
              as TransferTransactionModel,
      toTransfer: null == toTransfer
          ? _value.toTransfer
          : toTransfer // ignore: cast_nullable_to_non_nullable
              as TransferTransactionModel,
      fromType: null == fromType
          ? _value.fromType
          : fromType // ignore: cast_nullable_to_non_nullable
              as String,
      toType: null == toType
          ? _value.toType
          : toType // ignore: cast_nullable_to_non_nullable
              as String,
      fromCurrency: null == fromCurrency
          ? _value.fromCurrency
          : fromCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      toCurrency: null == toCurrency
          ? _value.toCurrency
          : toCurrency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferResponseModelImpl implements _TransferResponseModel {
  const _$TransferResponseModelImpl(
      {required this.message,
      required this.fromTransfer,
      required this.toTransfer,
      required this.fromType,
      required this.toType,
      required this.fromCurrency,
      required this.toCurrency});

  factory _$TransferResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferResponseModelImplFromJson(json);

  @override
  final String message;
  @override
  final TransferTransactionModel fromTransfer;
  @override
  final TransferTransactionModel toTransfer;
  @override
  final String fromType;
  @override
  final String toType;
  @override
  final String fromCurrency;
  @override
  final String toCurrency;

  @override
  String toString() {
    return 'TransferResponseModel(message: $message, fromTransfer: $fromTransfer, toTransfer: $toTransfer, fromType: $fromType, toType: $toType, fromCurrency: $fromCurrency, toCurrency: $toCurrency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferResponseModelImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.fromTransfer, fromTransfer) ||
                other.fromTransfer == fromTransfer) &&
            (identical(other.toTransfer, toTransfer) ||
                other.toTransfer == toTransfer) &&
            (identical(other.fromType, fromType) ||
                other.fromType == fromType) &&
            (identical(other.toType, toType) || other.toType == toType) &&
            (identical(other.fromCurrency, fromCurrency) ||
                other.fromCurrency == fromCurrency) &&
            (identical(other.toCurrency, toCurrency) ||
                other.toCurrency == toCurrency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, fromTransfer,
      toTransfer, fromType, toType, fromCurrency, toCurrency);

  /// Create a copy of TransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferResponseModelImplCopyWith<_$TransferResponseModelImpl>
      get copyWith => __$$TransferResponseModelImplCopyWithImpl<
          _$TransferResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferResponseModelImplToJson(
      this,
    );
  }
}

abstract class _TransferResponseModel implements TransferResponseModel {
  const factory _TransferResponseModel(
      {required final String message,
      required final TransferTransactionModel fromTransfer,
      required final TransferTransactionModel toTransfer,
      required final String fromType,
      required final String toType,
      required final String fromCurrency,
      required final String toCurrency}) = _$TransferResponseModelImpl;

  factory _TransferResponseModel.fromJson(Map<String, dynamic> json) =
      _$TransferResponseModelImpl.fromJson;

  @override
  String get message;
  @override
  TransferTransactionModel get fromTransfer;
  @override
  TransferTransactionModel get toTransfer;
  @override
  String get fromType;
  @override
  String get toType;
  @override
  String get fromCurrency;
  @override
  String get toCurrency;

  /// Create a copy of TransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransferResponseModelImplCopyWith<_$TransferResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TransferTransactionModel _$TransferTransactionModelFromJson(
    Map<String, dynamic> json) {
  return _TransferTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$TransferTransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get walletId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get fee => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get metadata => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TransferTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransferTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransferTransactionModelCopyWith<TransferTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferTransactionModelCopyWith<$Res> {
  factory $TransferTransactionModelCopyWith(TransferTransactionModel value,
          $Res Function(TransferTransactionModel) then) =
      _$TransferTransactionModelCopyWithImpl<$Res, TransferTransactionModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String walletId,
      String type,
      double amount,
      double fee,
      String status,
      String description,
      String? metadata,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$TransferTransactionModelCopyWithImpl<$Res,
        $Val extends TransferTransactionModel>
    implements $TransferTransactionModelCopyWith<$Res> {
  _$TransferTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransferTransactionModel
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
    Object? description = null,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferTransactionModelImplCopyWith<$Res>
    implements $TransferTransactionModelCopyWith<$Res> {
  factory _$$TransferTransactionModelImplCopyWith(
          _$TransferTransactionModelImpl value,
          $Res Function(_$TransferTransactionModelImpl) then) =
      __$$TransferTransactionModelImplCopyWithImpl<$Res>;
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
      String description,
      String? metadata,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$TransferTransactionModelImplCopyWithImpl<$Res>
    extends _$TransferTransactionModelCopyWithImpl<$Res,
        _$TransferTransactionModelImpl>
    implements _$$TransferTransactionModelImplCopyWith<$Res> {
  __$$TransferTransactionModelImplCopyWithImpl(
      _$TransferTransactionModelImpl _value,
      $Res Function(_$TransferTransactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransferTransactionModel
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
    Object? description = null,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TransferTransactionModelImpl(
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferTransactionModelImpl implements _TransferTransactionModel {
  const _$TransferTransactionModelImpl(
      {required this.id,
      required this.userId,
      required this.walletId,
      required this.type,
      required this.amount,
      required this.fee,
      required this.status,
      required this.description,
      required this.metadata,
      required this.createdAt,
      required this.updatedAt});

  factory _$TransferTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferTransactionModelImplFromJson(json);

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
  final String description;
  @override
  final String? metadata;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'TransferTransactionModel(id: $id, userId: $userId, walletId: $walletId, type: $type, amount: $amount, fee: $fee, status: $status, description: $description, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferTransactionModelImpl &&
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
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, walletId, type,
      amount, fee, status, description, metadata, createdAt, updatedAt);

  /// Create a copy of TransferTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferTransactionModelImplCopyWith<_$TransferTransactionModelImpl>
      get copyWith => __$$TransferTransactionModelImplCopyWithImpl<
          _$TransferTransactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _TransferTransactionModel implements TransferTransactionModel {
  const factory _TransferTransactionModel(
      {required final String id,
      required final String userId,
      required final String walletId,
      required final String type,
      required final double amount,
      required final double fee,
      required final String status,
      required final String description,
      required final String? metadata,
      required final String createdAt,
      required final String updatedAt}) = _$TransferTransactionModelImpl;

  factory _TransferTransactionModel.fromJson(Map<String, dynamic> json) =
      _$TransferTransactionModelImpl.fromJson;

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
  String get description;
  @override
  String? get metadata;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of TransferTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransferTransactionModelImplCopyWith<_$TransferTransactionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
