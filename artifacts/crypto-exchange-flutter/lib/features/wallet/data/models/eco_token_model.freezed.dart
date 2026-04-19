// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eco_token_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EcoTokenModel _$EcoTokenModelFromJson(Map<String, dynamic> json) {
  return _EcoTokenModel.fromJson(json);
}

/// @nodoc
mixin _$EcoTokenModel {
  String get name => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get chain => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  EcoLimitsModel? get limits => throw _privateConstructorUsedError;
  EcoFeeModel? get fee => throw _privateConstructorUsedError;
  String get contractType =>
      throw _privateConstructorUsedError; // PERMIT | NO_PERMIT | NATIVE
  String? get contract => throw _privateConstructorUsedError;
  int? get decimals => throw _privateConstructorUsedError;
  String? get network => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  int? get precision => throw _privateConstructorUsedError;
  bool get status => throw _privateConstructorUsedError;

  /// Serializes this EcoTokenModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoTokenModelCopyWith<EcoTokenModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoTokenModelCopyWith<$Res> {
  factory $EcoTokenModelCopyWith(
          EcoTokenModel value, $Res Function(EcoTokenModel) then) =
      _$EcoTokenModelCopyWithImpl<$Res, EcoTokenModel>;
  @useResult
  $Res call(
      {String name,
      String currency,
      String chain,
      String icon,
      EcoLimitsModel? limits,
      EcoFeeModel? fee,
      String contractType,
      String? contract,
      int? decimals,
      String? network,
      String? type,
      int? precision,
      bool status});

  $EcoLimitsModelCopyWith<$Res>? get limits;
  $EcoFeeModelCopyWith<$Res>? get fee;
}

/// @nodoc
class _$EcoTokenModelCopyWithImpl<$Res, $Val extends EcoTokenModel>
    implements $EcoTokenModelCopyWith<$Res> {
  _$EcoTokenModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? currency = null,
    Object? chain = null,
    Object? icon = null,
    Object? limits = freezed,
    Object? fee = freezed,
    Object? contractType = null,
    Object? contract = freezed,
    Object? decimals = freezed,
    Object? network = freezed,
    Object? type = freezed,
    Object? precision = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      chain: null == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      limits: freezed == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as EcoLimitsModel?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as EcoFeeModel?,
      contractType: null == contractType
          ? _value.contractType
          : contractType // ignore: cast_nullable_to_non_nullable
              as String,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as String?,
      decimals: freezed == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as int?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of EcoTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EcoLimitsModelCopyWith<$Res>? get limits {
    if (_value.limits == null) {
      return null;
    }

    return $EcoLimitsModelCopyWith<$Res>(_value.limits!, (value) {
      return _then(_value.copyWith(limits: value) as $Val);
    });
  }

  /// Create a copy of EcoTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EcoFeeModelCopyWith<$Res>? get fee {
    if (_value.fee == null) {
      return null;
    }

    return $EcoFeeModelCopyWith<$Res>(_value.fee!, (value) {
      return _then(_value.copyWith(fee: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EcoTokenModelImplCopyWith<$Res>
    implements $EcoTokenModelCopyWith<$Res> {
  factory _$$EcoTokenModelImplCopyWith(
          _$EcoTokenModelImpl value, $Res Function(_$EcoTokenModelImpl) then) =
      __$$EcoTokenModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String currency,
      String chain,
      String icon,
      EcoLimitsModel? limits,
      EcoFeeModel? fee,
      String contractType,
      String? contract,
      int? decimals,
      String? network,
      String? type,
      int? precision,
      bool status});

  @override
  $EcoLimitsModelCopyWith<$Res>? get limits;
  @override
  $EcoFeeModelCopyWith<$Res>? get fee;
}

/// @nodoc
class __$$EcoTokenModelImplCopyWithImpl<$Res>
    extends _$EcoTokenModelCopyWithImpl<$Res, _$EcoTokenModelImpl>
    implements _$$EcoTokenModelImplCopyWith<$Res> {
  __$$EcoTokenModelImplCopyWithImpl(
      _$EcoTokenModelImpl _value, $Res Function(_$EcoTokenModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? currency = null,
    Object? chain = null,
    Object? icon = null,
    Object? limits = freezed,
    Object? fee = freezed,
    Object? contractType = null,
    Object? contract = freezed,
    Object? decimals = freezed,
    Object? network = freezed,
    Object? type = freezed,
    Object? precision = freezed,
    Object? status = null,
  }) {
    return _then(_$EcoTokenModelImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      chain: null == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      limits: freezed == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as EcoLimitsModel?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as EcoFeeModel?,
      contractType: null == contractType
          ? _value.contractType
          : contractType // ignore: cast_nullable_to_non_nullable
              as String,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as String?,
      decimals: freezed == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as int?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
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
class _$EcoTokenModelImpl implements _EcoTokenModel {
  const _$EcoTokenModelImpl(
      {required this.name,
      required this.currency,
      required this.chain,
      required this.icon,
      this.limits,
      this.fee,
      required this.contractType,
      this.contract,
      this.decimals,
      this.network,
      this.type,
      this.precision,
      this.status = true});

  factory _$EcoTokenModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoTokenModelImplFromJson(json);

  @override
  final String name;
  @override
  final String currency;
  @override
  final String chain;
  @override
  final String icon;
  @override
  final EcoLimitsModel? limits;
  @override
  final EcoFeeModel? fee;
  @override
  final String contractType;
// PERMIT | NO_PERMIT | NATIVE
  @override
  final String? contract;
  @override
  final int? decimals;
  @override
  final String? network;
  @override
  final String? type;
  @override
  final int? precision;
  @override
  @JsonKey()
  final bool status;

  @override
  String toString() {
    return 'EcoTokenModel(name: $name, currency: $currency, chain: $chain, icon: $icon, limits: $limits, fee: $fee, contractType: $contractType, contract: $contract, decimals: $decimals, network: $network, type: $type, precision: $precision, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoTokenModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.chain, chain) || other.chain == chain) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.limits, limits) || other.limits == limits) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.contractType, contractType) ||
                other.contractType == contractType) &&
            (identical(other.contract, contract) ||
                other.contract == contract) &&
            (identical(other.decimals, decimals) ||
                other.decimals == decimals) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.precision, precision) ||
                other.precision == precision) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      currency,
      chain,
      icon,
      limits,
      fee,
      contractType,
      contract,
      decimals,
      network,
      type,
      precision,
      status);

  /// Create a copy of EcoTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoTokenModelImplCopyWith<_$EcoTokenModelImpl> get copyWith =>
      __$$EcoTokenModelImplCopyWithImpl<_$EcoTokenModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoTokenModelImplToJson(
      this,
    );
  }
}

abstract class _EcoTokenModel implements EcoTokenModel {
  const factory _EcoTokenModel(
      {required final String name,
      required final String currency,
      required final String chain,
      required final String icon,
      final EcoLimitsModel? limits,
      final EcoFeeModel? fee,
      required final String contractType,
      final String? contract,
      final int? decimals,
      final String? network,
      final String? type,
      final int? precision,
      final bool status}) = _$EcoTokenModelImpl;

  factory _EcoTokenModel.fromJson(Map<String, dynamic> json) =
      _$EcoTokenModelImpl.fromJson;

  @override
  String get name;
  @override
  String get currency;
  @override
  String get chain;
  @override
  String get icon;
  @override
  EcoLimitsModel? get limits;
  @override
  EcoFeeModel? get fee;
  @override
  String get contractType; // PERMIT | NO_PERMIT | NATIVE
  @override
  String? get contract;
  @override
  int? get decimals;
  @override
  String? get network;
  @override
  String? get type;
  @override
  int? get precision;
  @override
  bool get status;

  /// Create a copy of EcoTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoTokenModelImplCopyWith<_$EcoTokenModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EcoLimitsModel _$EcoLimitsModelFromJson(Map<String, dynamic> json) {
  return _EcoLimitsModel.fromJson(json);
}

/// @nodoc
mixin _$EcoLimitsModel {
  EcoDepositLimitsModel get deposit => throw _privateConstructorUsedError;
  EcoWithdrawLimitsModel? get withdraw => throw _privateConstructorUsedError;

  /// Serializes this EcoLimitsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoLimitsModelCopyWith<EcoLimitsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoLimitsModelCopyWith<$Res> {
  factory $EcoLimitsModelCopyWith(
          EcoLimitsModel value, $Res Function(EcoLimitsModel) then) =
      _$EcoLimitsModelCopyWithImpl<$Res, EcoLimitsModel>;
  @useResult
  $Res call({EcoDepositLimitsModel deposit, EcoWithdrawLimitsModel? withdraw});

  $EcoDepositLimitsModelCopyWith<$Res> get deposit;
  $EcoWithdrawLimitsModelCopyWith<$Res>? get withdraw;
}

/// @nodoc
class _$EcoLimitsModelCopyWithImpl<$Res, $Val extends EcoLimitsModel>
    implements $EcoLimitsModelCopyWith<$Res> {
  _$EcoLimitsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deposit = null,
    Object? withdraw = freezed,
  }) {
    return _then(_value.copyWith(
      deposit: null == deposit
          ? _value.deposit
          : deposit // ignore: cast_nullable_to_non_nullable
              as EcoDepositLimitsModel,
      withdraw: freezed == withdraw
          ? _value.withdraw
          : withdraw // ignore: cast_nullable_to_non_nullable
              as EcoWithdrawLimitsModel?,
    ) as $Val);
  }

  /// Create a copy of EcoLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EcoDepositLimitsModelCopyWith<$Res> get deposit {
    return $EcoDepositLimitsModelCopyWith<$Res>(_value.deposit, (value) {
      return _then(_value.copyWith(deposit: value) as $Val);
    });
  }

  /// Create a copy of EcoLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EcoWithdrawLimitsModelCopyWith<$Res>? get withdraw {
    if (_value.withdraw == null) {
      return null;
    }

    return $EcoWithdrawLimitsModelCopyWith<$Res>(_value.withdraw!, (value) {
      return _then(_value.copyWith(withdraw: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EcoLimitsModelImplCopyWith<$Res>
    implements $EcoLimitsModelCopyWith<$Res> {
  factory _$$EcoLimitsModelImplCopyWith(_$EcoLimitsModelImpl value,
          $Res Function(_$EcoLimitsModelImpl) then) =
      __$$EcoLimitsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({EcoDepositLimitsModel deposit, EcoWithdrawLimitsModel? withdraw});

  @override
  $EcoDepositLimitsModelCopyWith<$Res> get deposit;
  @override
  $EcoWithdrawLimitsModelCopyWith<$Res>? get withdraw;
}

/// @nodoc
class __$$EcoLimitsModelImplCopyWithImpl<$Res>
    extends _$EcoLimitsModelCopyWithImpl<$Res, _$EcoLimitsModelImpl>
    implements _$$EcoLimitsModelImplCopyWith<$Res> {
  __$$EcoLimitsModelImplCopyWithImpl(
      _$EcoLimitsModelImpl _value, $Res Function(_$EcoLimitsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deposit = null,
    Object? withdraw = freezed,
  }) {
    return _then(_$EcoLimitsModelImpl(
      deposit: null == deposit
          ? _value.deposit
          : deposit // ignore: cast_nullable_to_non_nullable
              as EcoDepositLimitsModel,
      withdraw: freezed == withdraw
          ? _value.withdraw
          : withdraw // ignore: cast_nullable_to_non_nullable
              as EcoWithdrawLimitsModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoLimitsModelImpl implements _EcoLimitsModel {
  const _$EcoLimitsModelImpl({required this.deposit, this.withdraw});

  factory _$EcoLimitsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoLimitsModelImplFromJson(json);

  @override
  final EcoDepositLimitsModel deposit;
  @override
  final EcoWithdrawLimitsModel? withdraw;

  @override
  String toString() {
    return 'EcoLimitsModel(deposit: $deposit, withdraw: $withdraw)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoLimitsModelImpl &&
            (identical(other.deposit, deposit) || other.deposit == deposit) &&
            (identical(other.withdraw, withdraw) ||
                other.withdraw == withdraw));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, deposit, withdraw);

  /// Create a copy of EcoLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoLimitsModelImplCopyWith<_$EcoLimitsModelImpl> get copyWith =>
      __$$EcoLimitsModelImplCopyWithImpl<_$EcoLimitsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoLimitsModelImplToJson(
      this,
    );
  }
}

abstract class _EcoLimitsModel implements EcoLimitsModel {
  const factory _EcoLimitsModel(
      {required final EcoDepositLimitsModel deposit,
      final EcoWithdrawLimitsModel? withdraw}) = _$EcoLimitsModelImpl;

  factory _EcoLimitsModel.fromJson(Map<String, dynamic> json) =
      _$EcoLimitsModelImpl.fromJson;

  @override
  EcoDepositLimitsModel get deposit;
  @override
  EcoWithdrawLimitsModel? get withdraw;

  /// Create a copy of EcoLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoLimitsModelImplCopyWith<_$EcoLimitsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EcoDepositLimitsModel _$EcoDepositLimitsModelFromJson(
    Map<String, dynamic> json) {
  return _EcoDepositLimitsModel.fromJson(json);
}

/// @nodoc
mixin _$EcoDepositLimitsModel {
  double get min => throw _privateConstructorUsedError;
  double get max => throw _privateConstructorUsedError;

  /// Serializes this EcoDepositLimitsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoDepositLimitsModelCopyWith<EcoDepositLimitsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoDepositLimitsModelCopyWith<$Res> {
  factory $EcoDepositLimitsModelCopyWith(EcoDepositLimitsModel value,
          $Res Function(EcoDepositLimitsModel) then) =
      _$EcoDepositLimitsModelCopyWithImpl<$Res, EcoDepositLimitsModel>;
  @useResult
  $Res call({double min, double max});
}

/// @nodoc
class _$EcoDepositLimitsModelCopyWithImpl<$Res,
        $Val extends EcoDepositLimitsModel>
    implements $EcoDepositLimitsModelCopyWith<$Res> {
  _$EcoDepositLimitsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
  }) {
    return _then(_value.copyWith(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EcoDepositLimitsModelImplCopyWith<$Res>
    implements $EcoDepositLimitsModelCopyWith<$Res> {
  factory _$$EcoDepositLimitsModelImplCopyWith(
          _$EcoDepositLimitsModelImpl value,
          $Res Function(_$EcoDepositLimitsModelImpl) then) =
      __$$EcoDepositLimitsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double min, double max});
}

/// @nodoc
class __$$EcoDepositLimitsModelImplCopyWithImpl<$Res>
    extends _$EcoDepositLimitsModelCopyWithImpl<$Res,
        _$EcoDepositLimitsModelImpl>
    implements _$$EcoDepositLimitsModelImplCopyWith<$Res> {
  __$$EcoDepositLimitsModelImplCopyWithImpl(_$EcoDepositLimitsModelImpl _value,
      $Res Function(_$EcoDepositLimitsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
  }) {
    return _then(_$EcoDepositLimitsModelImpl(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoDepositLimitsModelImpl implements _EcoDepositLimitsModel {
  const _$EcoDepositLimitsModelImpl({required this.min, required this.max});

  factory _$EcoDepositLimitsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoDepositLimitsModelImplFromJson(json);

  @override
  final double min;
  @override
  final double max;

  @override
  String toString() {
    return 'EcoDepositLimitsModel(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoDepositLimitsModelImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of EcoDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoDepositLimitsModelImplCopyWith<_$EcoDepositLimitsModelImpl>
      get copyWith => __$$EcoDepositLimitsModelImplCopyWithImpl<
          _$EcoDepositLimitsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoDepositLimitsModelImplToJson(
      this,
    );
  }
}

abstract class _EcoDepositLimitsModel implements EcoDepositLimitsModel {
  const factory _EcoDepositLimitsModel(
      {required final double min,
      required final double max}) = _$EcoDepositLimitsModelImpl;

  factory _EcoDepositLimitsModel.fromJson(Map<String, dynamic> json) =
      _$EcoDepositLimitsModelImpl.fromJson;

  @override
  double get min;
  @override
  double get max;

  /// Create a copy of EcoDepositLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoDepositLimitsModelImplCopyWith<_$EcoDepositLimitsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

EcoWithdrawLimitsModel _$EcoWithdrawLimitsModelFromJson(
    Map<String, dynamic> json) {
  return _EcoWithdrawLimitsModel.fromJson(json);
}

/// @nodoc
mixin _$EcoWithdrawLimitsModel {
  double get min => throw _privateConstructorUsedError;
  double get max => throw _privateConstructorUsedError;

  /// Serializes this EcoWithdrawLimitsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoWithdrawLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoWithdrawLimitsModelCopyWith<EcoWithdrawLimitsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoWithdrawLimitsModelCopyWith<$Res> {
  factory $EcoWithdrawLimitsModelCopyWith(EcoWithdrawLimitsModel value,
          $Res Function(EcoWithdrawLimitsModel) then) =
      _$EcoWithdrawLimitsModelCopyWithImpl<$Res, EcoWithdrawLimitsModel>;
  @useResult
  $Res call({double min, double max});
}

/// @nodoc
class _$EcoWithdrawLimitsModelCopyWithImpl<$Res,
        $Val extends EcoWithdrawLimitsModel>
    implements $EcoWithdrawLimitsModelCopyWith<$Res> {
  _$EcoWithdrawLimitsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoWithdrawLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
  }) {
    return _then(_value.copyWith(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EcoWithdrawLimitsModelImplCopyWith<$Res>
    implements $EcoWithdrawLimitsModelCopyWith<$Res> {
  factory _$$EcoWithdrawLimitsModelImplCopyWith(
          _$EcoWithdrawLimitsModelImpl value,
          $Res Function(_$EcoWithdrawLimitsModelImpl) then) =
      __$$EcoWithdrawLimitsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double min, double max});
}

/// @nodoc
class __$$EcoWithdrawLimitsModelImplCopyWithImpl<$Res>
    extends _$EcoWithdrawLimitsModelCopyWithImpl<$Res,
        _$EcoWithdrawLimitsModelImpl>
    implements _$$EcoWithdrawLimitsModelImplCopyWith<$Res> {
  __$$EcoWithdrawLimitsModelImplCopyWithImpl(
      _$EcoWithdrawLimitsModelImpl _value,
      $Res Function(_$EcoWithdrawLimitsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoWithdrawLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
  }) {
    return _then(_$EcoWithdrawLimitsModelImpl(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoWithdrawLimitsModelImpl implements _EcoWithdrawLimitsModel {
  const _$EcoWithdrawLimitsModelImpl({required this.min, required this.max});

  factory _$EcoWithdrawLimitsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoWithdrawLimitsModelImplFromJson(json);

  @override
  final double min;
  @override
  final double max;

  @override
  String toString() {
    return 'EcoWithdrawLimitsModel(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoWithdrawLimitsModelImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of EcoWithdrawLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoWithdrawLimitsModelImplCopyWith<_$EcoWithdrawLimitsModelImpl>
      get copyWith => __$$EcoWithdrawLimitsModelImplCopyWithImpl<
          _$EcoWithdrawLimitsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoWithdrawLimitsModelImplToJson(
      this,
    );
  }
}

abstract class _EcoWithdrawLimitsModel implements EcoWithdrawLimitsModel {
  const factory _EcoWithdrawLimitsModel(
      {required final double min,
      required final double max}) = _$EcoWithdrawLimitsModelImpl;

  factory _EcoWithdrawLimitsModel.fromJson(Map<String, dynamic> json) =
      _$EcoWithdrawLimitsModelImpl.fromJson;

  @override
  double get min;
  @override
  double get max;

  /// Create a copy of EcoWithdrawLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoWithdrawLimitsModelImplCopyWith<_$EcoWithdrawLimitsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

EcoFeeModel _$EcoFeeModelFromJson(Map<String, dynamic> json) {
  return _EcoFeeModel.fromJson(json);
}

/// @nodoc
mixin _$EcoFeeModel {
  double get min => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this EcoFeeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoFeeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoFeeModelCopyWith<EcoFeeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoFeeModelCopyWith<$Res> {
  factory $EcoFeeModelCopyWith(
          EcoFeeModel value, $Res Function(EcoFeeModel) then) =
      _$EcoFeeModelCopyWithImpl<$Res, EcoFeeModel>;
  @useResult
  $Res call({double min, double percentage});
}

/// @nodoc
class _$EcoFeeModelCopyWithImpl<$Res, $Val extends EcoFeeModel>
    implements $EcoFeeModelCopyWith<$Res> {
  _$EcoFeeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoFeeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EcoFeeModelImplCopyWith<$Res>
    implements $EcoFeeModelCopyWith<$Res> {
  factory _$$EcoFeeModelImplCopyWith(
          _$EcoFeeModelImpl value, $Res Function(_$EcoFeeModelImpl) then) =
      __$$EcoFeeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double min, double percentage});
}

/// @nodoc
class __$$EcoFeeModelImplCopyWithImpl<$Res>
    extends _$EcoFeeModelCopyWithImpl<$Res, _$EcoFeeModelImpl>
    implements _$$EcoFeeModelImplCopyWith<$Res> {
  __$$EcoFeeModelImplCopyWithImpl(
      _$EcoFeeModelImpl _value, $Res Function(_$EcoFeeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoFeeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? percentage = null,
  }) {
    return _then(_$EcoFeeModelImpl(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoFeeModelImpl implements _EcoFeeModel {
  const _$EcoFeeModelImpl({required this.min, required this.percentage});

  factory _$EcoFeeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoFeeModelImplFromJson(json);

  @override
  final double min;
  @override
  final double percentage;

  @override
  String toString() {
    return 'EcoFeeModel(min: $min, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoFeeModelImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, percentage);

  /// Create a copy of EcoFeeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoFeeModelImplCopyWith<_$EcoFeeModelImpl> get copyWith =>
      __$$EcoFeeModelImplCopyWithImpl<_$EcoFeeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoFeeModelImplToJson(
      this,
    );
  }
}

abstract class _EcoFeeModel implements EcoFeeModel {
  const factory _EcoFeeModel(
      {required final double min,
      required final double percentage}) = _$EcoFeeModelImpl;

  factory _EcoFeeModel.fromJson(Map<String, dynamic> json) =
      _$EcoFeeModelImpl.fromJson;

  @override
  double get min;
  @override
  double get percentage;

  /// Create a copy of EcoFeeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoFeeModelImplCopyWith<_$EcoFeeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
