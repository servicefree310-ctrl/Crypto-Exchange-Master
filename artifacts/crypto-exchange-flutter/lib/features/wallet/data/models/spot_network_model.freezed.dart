// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spot_network_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpotNetworkModel _$SpotNetworkModelFromJson(Map<String, dynamic> json) {
  return _SpotNetworkModel.fromJson(json);
}

/// @nodoc
mixin _$SpotNetworkModel {
  String get id => throw _privateConstructorUsedError;
  String get chain => throw _privateConstructorUsedError;
  double? get fee =>
      throw _privateConstructorUsedError; // Made nullable to handle null from API
  double? get precision =>
      throw _privateConstructorUsedError; // Made nullable to handle null from API
  SpotLimitsModel get limits => throw _privateConstructorUsedError;

  /// Serializes this SpotNetworkModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpotNetworkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotNetworkModelCopyWith<SpotNetworkModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotNetworkModelCopyWith<$Res> {
  factory $SpotNetworkModelCopyWith(
          SpotNetworkModel value, $Res Function(SpotNetworkModel) then) =
      _$SpotNetworkModelCopyWithImpl<$Res, SpotNetworkModel>;
  @useResult
  $Res call(
      {String id,
      String chain,
      double? fee,
      double? precision,
      SpotLimitsModel limits});

  $SpotLimitsModelCopyWith<$Res> get limits;
}

/// @nodoc
class _$SpotNetworkModelCopyWithImpl<$Res, $Val extends SpotNetworkModel>
    implements $SpotNetworkModelCopyWith<$Res> {
  _$SpotNetworkModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotNetworkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chain = null,
    Object? fee = freezed,
    Object? precision = freezed,
    Object? limits = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chain: null == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as double?,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as SpotLimitsModel,
    ) as $Val);
  }

  /// Create a copy of SpotNetworkModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SpotLimitsModelCopyWith<$Res> get limits {
    return $SpotLimitsModelCopyWith<$Res>(_value.limits, (value) {
      return _then(_value.copyWith(limits: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SpotNetworkModelImplCopyWith<$Res>
    implements $SpotNetworkModelCopyWith<$Res> {
  factory _$$SpotNetworkModelImplCopyWith(_$SpotNetworkModelImpl value,
          $Res Function(_$SpotNetworkModelImpl) then) =
      __$$SpotNetworkModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String chain,
      double? fee,
      double? precision,
      SpotLimitsModel limits});

  @override
  $SpotLimitsModelCopyWith<$Res> get limits;
}

/// @nodoc
class __$$SpotNetworkModelImplCopyWithImpl<$Res>
    extends _$SpotNetworkModelCopyWithImpl<$Res, _$SpotNetworkModelImpl>
    implements _$$SpotNetworkModelImplCopyWith<$Res> {
  __$$SpotNetworkModelImplCopyWithImpl(_$SpotNetworkModelImpl _value,
      $Res Function(_$SpotNetworkModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotNetworkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chain = null,
    Object? fee = freezed,
    Object? precision = freezed,
    Object? limits = null,
  }) {
    return _then(_$SpotNetworkModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chain: null == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as double?,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as SpotLimitsModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpotNetworkModelImpl implements _SpotNetworkModel {
  const _$SpotNetworkModelImpl(
      {required this.id,
      required this.chain,
      this.fee,
      this.precision,
      required this.limits});

  factory _$SpotNetworkModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpotNetworkModelImplFromJson(json);

  @override
  final String id;
  @override
  final String chain;
  @override
  final double? fee;
// Made nullable to handle null from API
  @override
  final double? precision;
// Made nullable to handle null from API
  @override
  final SpotLimitsModel limits;

  @override
  String toString() {
    return 'SpotNetworkModel(id: $id, chain: $chain, fee: $fee, precision: $precision, limits: $limits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotNetworkModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chain, chain) || other.chain == chain) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.precision, precision) ||
                other.precision == precision) &&
            (identical(other.limits, limits) || other.limits == limits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, chain, fee, precision, limits);

  /// Create a copy of SpotNetworkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotNetworkModelImplCopyWith<_$SpotNetworkModelImpl> get copyWith =>
      __$$SpotNetworkModelImplCopyWithImpl<_$SpotNetworkModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpotNetworkModelImplToJson(
      this,
    );
  }
}

abstract class _SpotNetworkModel implements SpotNetworkModel {
  const factory _SpotNetworkModel(
      {required final String id,
      required final String chain,
      final double? fee,
      final double? precision,
      required final SpotLimitsModel limits}) = _$SpotNetworkModelImpl;

  factory _SpotNetworkModel.fromJson(Map<String, dynamic> json) =
      _$SpotNetworkModelImpl.fromJson;

  @override
  String get id;
  @override
  String get chain;
  @override
  double? get fee; // Made nullable to handle null from API
  @override
  double? get precision; // Made nullable to handle null from API
  @override
  SpotLimitsModel get limits;

  /// Create a copy of SpotNetworkModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotNetworkModelImplCopyWith<_$SpotNetworkModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpotLimitsModel _$SpotLimitsModelFromJson(Map<String, dynamic> json) {
  return _SpotLimitsModel.fromJson(json);
}

/// @nodoc
mixin _$SpotLimitsModel {
  SpotDepositLimitsModel get withdraw =>
      throw _privateConstructorUsedError; // Added withdraw limits
  SpotDepositLimitsModel get deposit => throw _privateConstructorUsedError;

  /// Serializes this SpotLimitsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpotLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotLimitsModelCopyWith<SpotLimitsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotLimitsModelCopyWith<$Res> {
  factory $SpotLimitsModelCopyWith(
          SpotLimitsModel value, $Res Function(SpotLimitsModel) then) =
      _$SpotLimitsModelCopyWithImpl<$Res, SpotLimitsModel>;
  @useResult
  $Res call({SpotDepositLimitsModel withdraw, SpotDepositLimitsModel deposit});

  $SpotDepositLimitsModelCopyWith<$Res> get withdraw;
  $SpotDepositLimitsModelCopyWith<$Res> get deposit;
}

/// @nodoc
class _$SpotLimitsModelCopyWithImpl<$Res, $Val extends SpotLimitsModel>
    implements $SpotLimitsModelCopyWith<$Res> {
  _$SpotLimitsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? withdraw = null,
    Object? deposit = null,
  }) {
    return _then(_value.copyWith(
      withdraw: null == withdraw
          ? _value.withdraw
          : withdraw // ignore: cast_nullable_to_non_nullable
              as SpotDepositLimitsModel,
      deposit: null == deposit
          ? _value.deposit
          : deposit // ignore: cast_nullable_to_non_nullable
              as SpotDepositLimitsModel,
    ) as $Val);
  }

  /// Create a copy of SpotLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SpotDepositLimitsModelCopyWith<$Res> get withdraw {
    return $SpotDepositLimitsModelCopyWith<$Res>(_value.withdraw, (value) {
      return _then(_value.copyWith(withdraw: value) as $Val);
    });
  }

  /// Create a copy of SpotLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SpotDepositLimitsModelCopyWith<$Res> get deposit {
    return $SpotDepositLimitsModelCopyWith<$Res>(_value.deposit, (value) {
      return _then(_value.copyWith(deposit: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SpotLimitsModelImplCopyWith<$Res>
    implements $SpotLimitsModelCopyWith<$Res> {
  factory _$$SpotLimitsModelImplCopyWith(_$SpotLimitsModelImpl value,
          $Res Function(_$SpotLimitsModelImpl) then) =
      __$$SpotLimitsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SpotDepositLimitsModel withdraw, SpotDepositLimitsModel deposit});

  @override
  $SpotDepositLimitsModelCopyWith<$Res> get withdraw;
  @override
  $SpotDepositLimitsModelCopyWith<$Res> get deposit;
}

/// @nodoc
class __$$SpotLimitsModelImplCopyWithImpl<$Res>
    extends _$SpotLimitsModelCopyWithImpl<$Res, _$SpotLimitsModelImpl>
    implements _$$SpotLimitsModelImplCopyWith<$Res> {
  __$$SpotLimitsModelImplCopyWithImpl(
      _$SpotLimitsModelImpl _value, $Res Function(_$SpotLimitsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? withdraw = null,
    Object? deposit = null,
  }) {
    return _then(_$SpotLimitsModelImpl(
      withdraw: null == withdraw
          ? _value.withdraw
          : withdraw // ignore: cast_nullable_to_non_nullable
              as SpotDepositLimitsModel,
      deposit: null == deposit
          ? _value.deposit
          : deposit // ignore: cast_nullable_to_non_nullable
              as SpotDepositLimitsModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpotLimitsModelImpl implements _SpotLimitsModel {
  const _$SpotLimitsModelImpl({required this.withdraw, required this.deposit});

  factory _$SpotLimitsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpotLimitsModelImplFromJson(json);

  @override
  final SpotDepositLimitsModel withdraw;
// Added withdraw limits
  @override
  final SpotDepositLimitsModel deposit;

  @override
  String toString() {
    return 'SpotLimitsModel(withdraw: $withdraw, deposit: $deposit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotLimitsModelImpl &&
            (identical(other.withdraw, withdraw) ||
                other.withdraw == withdraw) &&
            (identical(other.deposit, deposit) || other.deposit == deposit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, withdraw, deposit);

  /// Create a copy of SpotLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotLimitsModelImplCopyWith<_$SpotLimitsModelImpl> get copyWith =>
      __$$SpotLimitsModelImplCopyWithImpl<_$SpotLimitsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpotLimitsModelImplToJson(
      this,
    );
  }
}

abstract class _SpotLimitsModel implements SpotLimitsModel {
  const factory _SpotLimitsModel(
      {required final SpotDepositLimitsModel withdraw,
      required final SpotDepositLimitsModel deposit}) = _$SpotLimitsModelImpl;

  factory _SpotLimitsModel.fromJson(Map<String, dynamic> json) =
      _$SpotLimitsModelImpl.fromJson;

  @override
  SpotDepositLimitsModel get withdraw; // Added withdraw limits
  @override
  SpotDepositLimitsModel get deposit;

  /// Create a copy of SpotLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotLimitsModelImplCopyWith<_$SpotLimitsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpotDepositLimitsModel _$SpotDepositLimitsModelFromJson(
    Map<String, dynamic> json) {
  return _SpotDepositLimitsModel.fromJson(json);
}

/// @nodoc
mixin _$SpotDepositLimitsModel {
  double get min => throw _privateConstructorUsedError;
  double? get max => throw _privateConstructorUsedError;

  /// Serializes this SpotDepositLimitsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpotDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotDepositLimitsModelCopyWith<SpotDepositLimitsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotDepositLimitsModelCopyWith<$Res> {
  factory $SpotDepositLimitsModelCopyWith(SpotDepositLimitsModel value,
          $Res Function(SpotDepositLimitsModel) then) =
      _$SpotDepositLimitsModelCopyWithImpl<$Res, SpotDepositLimitsModel>;
  @useResult
  $Res call({double min, double? max});
}

/// @nodoc
class _$SpotDepositLimitsModelCopyWithImpl<$Res,
        $Val extends SpotDepositLimitsModel>
    implements $SpotDepositLimitsModelCopyWith<$Res> {
  _$SpotDepositLimitsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = freezed,
  }) {
    return _then(_value.copyWith(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: freezed == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpotDepositLimitsModelImplCopyWith<$Res>
    implements $SpotDepositLimitsModelCopyWith<$Res> {
  factory _$$SpotDepositLimitsModelImplCopyWith(
          _$SpotDepositLimitsModelImpl value,
          $Res Function(_$SpotDepositLimitsModelImpl) then) =
      __$$SpotDepositLimitsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double min, double? max});
}

/// @nodoc
class __$$SpotDepositLimitsModelImplCopyWithImpl<$Res>
    extends _$SpotDepositLimitsModelCopyWithImpl<$Res,
        _$SpotDepositLimitsModelImpl>
    implements _$$SpotDepositLimitsModelImplCopyWith<$Res> {
  __$$SpotDepositLimitsModelImplCopyWithImpl(
      _$SpotDepositLimitsModelImpl _value,
      $Res Function(_$SpotDepositLimitsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = freezed,
  }) {
    return _then(_$SpotDepositLimitsModelImpl(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: freezed == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpotDepositLimitsModelImpl implements _SpotDepositLimitsModel {
  const _$SpotDepositLimitsModelImpl({required this.min, this.max});

  factory _$SpotDepositLimitsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpotDepositLimitsModelImplFromJson(json);

  @override
  final double min;
  @override
  final double? max;

  @override
  String toString() {
    return 'SpotDepositLimitsModel(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotDepositLimitsModelImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of SpotDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotDepositLimitsModelImplCopyWith<_$SpotDepositLimitsModelImpl>
      get copyWith => __$$SpotDepositLimitsModelImplCopyWithImpl<
          _$SpotDepositLimitsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpotDepositLimitsModelImplToJson(
      this,
    );
  }
}

abstract class _SpotDepositLimitsModel implements SpotDepositLimitsModel {
  const factory _SpotDepositLimitsModel(
      {required final double min,
      final double? max}) = _$SpotDepositLimitsModelImpl;

  factory _SpotDepositLimitsModel.fromJson(Map<String, dynamic> json) =
      _$SpotDepositLimitsModelImpl.fromJson;

  @override
  double get min;
  @override
  double? get max;

  /// Create a copy of SpotDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotDepositLimitsModelImplCopyWith<_$SpotDepositLimitsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
