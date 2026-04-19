// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spot_deposit_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpotDepositTransactionModel _$SpotDepositTransactionModelFromJson(
    Map<String, dynamic> json) {
  return _SpotDepositTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$SpotDepositTransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get walletId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get chain => throw _privateConstructorUsedError;
  String get referenceId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SpotDepositTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpotDepositTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotDepositTransactionModelCopyWith<SpotDepositTransactionModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotDepositTransactionModelCopyWith<$Res> {
  factory $SpotDepositTransactionModelCopyWith(
          SpotDepositTransactionModel value,
          $Res Function(SpotDepositTransactionModel) then) =
      _$SpotDepositTransactionModelCopyWithImpl<$Res,
          SpotDepositTransactionModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String walletId,
      String type,
      double amount,
      String status,
      String currency,
      String chain,
      String referenceId,
      Map<String, dynamic>? metadata,
      String? description,
      DateTime createdAt});
}

/// @nodoc
class _$SpotDepositTransactionModelCopyWithImpl<$Res,
        $Val extends SpotDepositTransactionModel>
    implements $SpotDepositTransactionModelCopyWith<$Res> {
  _$SpotDepositTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotDepositTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? walletId = null,
    Object? type = null,
    Object? amount = null,
    Object? status = null,
    Object? currency = null,
    Object? chain = null,
    Object? referenceId = null,
    Object? metadata = freezed,
    Object? description = freezed,
    Object? createdAt = null,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      chain: null == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String,
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpotDepositTransactionModelImplCopyWith<$Res>
    implements $SpotDepositTransactionModelCopyWith<$Res> {
  factory _$$SpotDepositTransactionModelImplCopyWith(
          _$SpotDepositTransactionModelImpl value,
          $Res Function(_$SpotDepositTransactionModelImpl) then) =
      __$$SpotDepositTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String walletId,
      String type,
      double amount,
      String status,
      String currency,
      String chain,
      String referenceId,
      Map<String, dynamic>? metadata,
      String? description,
      DateTime createdAt});
}

/// @nodoc
class __$$SpotDepositTransactionModelImplCopyWithImpl<$Res>
    extends _$SpotDepositTransactionModelCopyWithImpl<$Res,
        _$SpotDepositTransactionModelImpl>
    implements _$$SpotDepositTransactionModelImplCopyWith<$Res> {
  __$$SpotDepositTransactionModelImplCopyWithImpl(
      _$SpotDepositTransactionModelImpl _value,
      $Res Function(_$SpotDepositTransactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotDepositTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? walletId = null,
    Object? type = null,
    Object? amount = null,
    Object? status = null,
    Object? currency = null,
    Object? chain = null,
    Object? referenceId = null,
    Object? metadata = freezed,
    Object? description = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$SpotDepositTransactionModelImpl(
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      chain: null == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String,
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpotDepositTransactionModelImpl
    implements _SpotDepositTransactionModel {
  const _$SpotDepositTransactionModelImpl(
      {required this.id,
      required this.userId,
      required this.walletId,
      required this.type,
      required this.amount,
      required this.status,
      required this.currency,
      required this.chain,
      required this.referenceId,
      final Map<String, dynamic>? metadata,
      this.description,
      required this.createdAt})
      : _metadata = metadata;

  factory _$SpotDepositTransactionModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SpotDepositTransactionModelImplFromJson(json);

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
  final String status;
  @override
  final String currency;
  @override
  final String chain;
  @override
  final String referenceId;
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
  final String? description;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SpotDepositTransactionModel(id: $id, userId: $userId, walletId: $walletId, type: $type, amount: $amount, status: $status, currency: $currency, chain: $chain, referenceId: $referenceId, metadata: $metadata, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotDepositTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.walletId, walletId) ||
                other.walletId == walletId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.chain, chain) || other.chain == chain) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
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
      status,
      currency,
      chain,
      referenceId,
      const DeepCollectionEquality().hash(_metadata),
      description,
      createdAt);

  /// Create a copy of SpotDepositTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotDepositTransactionModelImplCopyWith<_$SpotDepositTransactionModelImpl>
      get copyWith => __$$SpotDepositTransactionModelImplCopyWithImpl<
          _$SpotDepositTransactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpotDepositTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _SpotDepositTransactionModel
    implements SpotDepositTransactionModel {
  const factory _SpotDepositTransactionModel(
      {required final String id,
      required final String userId,
      required final String walletId,
      required final String type,
      required final double amount,
      required final String status,
      required final String currency,
      required final String chain,
      required final String referenceId,
      final Map<String, dynamic>? metadata,
      final String? description,
      required final DateTime createdAt}) = _$SpotDepositTransactionModelImpl;

  factory _SpotDepositTransactionModel.fromJson(Map<String, dynamic> json) =
      _$SpotDepositTransactionModelImpl.fromJson;

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
  String get status;
  @override
  String get currency;
  @override
  String get chain;
  @override
  String get referenceId;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get description;
  @override
  DateTime get createdAt;

  /// Create a copy of SpotDepositTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotDepositTransactionModelImplCopyWith<_$SpotDepositTransactionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
