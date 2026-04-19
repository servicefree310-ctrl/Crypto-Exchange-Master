// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eco_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EcoTransactionModel _$EcoTransactionModelFromJson(Map<String, dynamic> json) {
  return _EcoTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$EcoTransactionModel {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get fee => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get referenceId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this EcoTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoTransactionModelCopyWith<EcoTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoTransactionModelCopyWith<$Res> {
  factory $EcoTransactionModelCopyWith(
          EcoTransactionModel value, $Res Function(EcoTransactionModel) then) =
      _$EcoTransactionModelCopyWithImpl<$Res, EcoTransactionModel>;
  @useResult
  $Res call(
      {String id,
      double amount,
      double fee,
      String status,
      String referenceId,
      String? description,
      Map<String, dynamic>? metadata,
      DateTime createdAt});
}

/// @nodoc
class _$EcoTransactionModelCopyWithImpl<$Res, $Val extends EcoTransactionModel>
    implements $EcoTransactionModelCopyWith<$Res> {
  _$EcoTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? fee = null,
    Object? status = null,
    Object? referenceId = null,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EcoTransactionModelImplCopyWith<$Res>
    implements $EcoTransactionModelCopyWith<$Res> {
  factory _$$EcoTransactionModelImplCopyWith(_$EcoTransactionModelImpl value,
          $Res Function(_$EcoTransactionModelImpl) then) =
      __$$EcoTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      double fee,
      String status,
      String referenceId,
      String? description,
      Map<String, dynamic>? metadata,
      DateTime createdAt});
}

/// @nodoc
class __$$EcoTransactionModelImplCopyWithImpl<$Res>
    extends _$EcoTransactionModelCopyWithImpl<$Res, _$EcoTransactionModelImpl>
    implements _$$EcoTransactionModelImplCopyWith<$Res> {
  __$$EcoTransactionModelImplCopyWithImpl(_$EcoTransactionModelImpl _value,
      $Res Function(_$EcoTransactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? fee = null,
    Object? status = null,
    Object? referenceId = null,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$EcoTransactionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoTransactionModelImpl implements _EcoTransactionModel {
  const _$EcoTransactionModelImpl(
      {required this.id,
      required this.amount,
      required this.fee,
      required this.status,
      required this.referenceId,
      this.description,
      final Map<String, dynamic>? metadata,
      required this.createdAt})
      : _metadata = metadata;

  factory _$EcoTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final double amount;
  @override
  final double fee;
  @override
  final String status;
  @override
  final String referenceId;
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
  final DateTime createdAt;

  @override
  String toString() {
    return 'EcoTransactionModel(id: $id, amount: $amount, fee: $fee, status: $status, referenceId: $referenceId, description: $description, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      amount,
      fee,
      status,
      referenceId,
      description,
      const DeepCollectionEquality().hash(_metadata),
      createdAt);

  /// Create a copy of EcoTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoTransactionModelImplCopyWith<_$EcoTransactionModelImpl> get copyWith =>
      __$$EcoTransactionModelImplCopyWithImpl<_$EcoTransactionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _EcoTransactionModel implements EcoTransactionModel {
  const factory _EcoTransactionModel(
      {required final String id,
      required final double amount,
      required final double fee,
      required final String status,
      required final String referenceId,
      final String? description,
      final Map<String, dynamic>? metadata,
      required final DateTime createdAt}) = _$EcoTransactionModelImpl;

  factory _EcoTransactionModel.fromJson(Map<String, dynamic> json) =
      _$EcoTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  double get amount;
  @override
  double get fee;
  @override
  String get status;
  @override
  String get referenceId;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime get createdAt;

  /// Create a copy of EcoTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoTransactionModelImplCopyWith<_$EcoTransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
