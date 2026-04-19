// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MarketModel _$MarketModelFromJson(Map<String, dynamic> json) {
  return _MarketModel.fromJson(json);
}

/// @nodoc
mixin _$MarketModel {
  String get id => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get pair => throw _privateConstructorUsedError;
  bool get isTrending => throw _privateConstructorUsedError;
  bool get isHot => throw _privateConstructorUsedError;
  bool get status => throw _privateConstructorUsedError;
  bool get isEco => throw _privateConstructorUsedError;
  MarketMetadataModel? get metadata => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  /// Serializes this MarketModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketModelCopyWith<MarketModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketModelCopyWith<$Res> {
  factory $MarketModelCopyWith(
          MarketModel value, $Res Function(MarketModel) then) =
      _$MarketModelCopyWithImpl<$Res, MarketModel>;
  @useResult
  $Res call(
      {String id,
      String currency,
      String pair,
      bool isTrending,
      bool isHot,
      bool status,
      bool isEco,
      MarketMetadataModel? metadata,
      String? icon});

  $MarketMetadataModelCopyWith<$Res>? get metadata;
}

/// @nodoc
class _$MarketModelCopyWithImpl<$Res, $Val extends MarketModel>
    implements $MarketModelCopyWith<$Res> {
  _$MarketModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? currency = null,
    Object? pair = null,
    Object? isTrending = null,
    Object? isHot = null,
    Object? status = null,
    Object? isEco = null,
    Object? metadata = freezed,
    Object? icon = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      pair: null == pair
          ? _value.pair
          : pair // ignore: cast_nullable_to_non_nullable
              as String,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
      isHot: null == isHot
          ? _value.isHot
          : isHot // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      isEco: null == isEco
          ? _value.isEco
          : isEco // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MarketMetadataModel?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of MarketModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketMetadataModelCopyWith<$Res>? get metadata {
    if (_value.metadata == null) {
      return null;
    }

    return $MarketMetadataModelCopyWith<$Res>(_value.metadata!, (value) {
      return _then(_value.copyWith(metadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MarketModelImplCopyWith<$Res>
    implements $MarketModelCopyWith<$Res> {
  factory _$$MarketModelImplCopyWith(
          _$MarketModelImpl value, $Res Function(_$MarketModelImpl) then) =
      __$$MarketModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String currency,
      String pair,
      bool isTrending,
      bool isHot,
      bool status,
      bool isEco,
      MarketMetadataModel? metadata,
      String? icon});

  @override
  $MarketMetadataModelCopyWith<$Res>? get metadata;
}

/// @nodoc
class __$$MarketModelImplCopyWithImpl<$Res>
    extends _$MarketModelCopyWithImpl<$Res, _$MarketModelImpl>
    implements _$$MarketModelImplCopyWith<$Res> {
  __$$MarketModelImplCopyWithImpl(
      _$MarketModelImpl _value, $Res Function(_$MarketModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? currency = null,
    Object? pair = null,
    Object? isTrending = null,
    Object? isHot = null,
    Object? status = null,
    Object? isEco = null,
    Object? metadata = freezed,
    Object? icon = freezed,
  }) {
    return _then(_$MarketModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      pair: null == pair
          ? _value.pair
          : pair // ignore: cast_nullable_to_non_nullable
              as String,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
      isHot: null == isHot
          ? _value.isHot
          : isHot // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      isEco: null == isEco
          ? _value.isEco
          : isEco // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MarketMetadataModel?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketModelImpl implements _MarketModel {
  const _$MarketModelImpl(
      {required this.id,
      required this.currency,
      required this.pair,
      required this.isTrending,
      required this.isHot,
      required this.status,
      required this.isEco,
      this.metadata,
      this.icon});

  factory _$MarketModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketModelImplFromJson(json);

  @override
  final String id;
  @override
  final String currency;
  @override
  final String pair;
  @override
  final bool isTrending;
  @override
  final bool isHot;
  @override
  final bool status;
  @override
  final bool isEco;
  @override
  final MarketMetadataModel? metadata;
  @override
  final String? icon;

  @override
  String toString() {
    return 'MarketModel(id: $id, currency: $currency, pair: $pair, isTrending: $isTrending, isHot: $isHot, status: $status, isEco: $isEco, metadata: $metadata, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.pair, pair) || other.pair == pair) &&
            (identical(other.isTrending, isTrending) ||
                other.isTrending == isTrending) &&
            (identical(other.isHot, isHot) || other.isHot == isHot) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isEco, isEco) || other.isEco == isEco) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, currency, pair, isTrending,
      isHot, status, isEco, metadata, icon);

  /// Create a copy of MarketModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketModelImplCopyWith<_$MarketModelImpl> get copyWith =>
      __$$MarketModelImplCopyWithImpl<_$MarketModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketModelImplToJson(
      this,
    );
  }
}

abstract class _MarketModel implements MarketModel {
  const factory _MarketModel(
      {required final String id,
      required final String currency,
      required final String pair,
      required final bool isTrending,
      required final bool isHot,
      required final bool status,
      required final bool isEco,
      final MarketMetadataModel? metadata,
      final String? icon}) = _$MarketModelImpl;

  factory _MarketModel.fromJson(Map<String, dynamic> json) =
      _$MarketModelImpl.fromJson;

  @override
  String get id;
  @override
  String get currency;
  @override
  String get pair;
  @override
  bool get isTrending;
  @override
  bool get isHot;
  @override
  bool get status;
  @override
  bool get isEco;
  @override
  MarketMetadataModel? get metadata;
  @override
  String? get icon;

  /// Create a copy of MarketModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketModelImplCopyWith<_$MarketModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketMetadataModel _$MarketMetadataModelFromJson(Map<String, dynamic> json) {
  return _MarketMetadataModel.fromJson(json);
}

/// @nodoc
mixin _$MarketMetadataModel {
  double? get taker => throw _privateConstructorUsedError;
  double? get maker => throw _privateConstructorUsedError;
  MarketPrecisionModel get precision => throw _privateConstructorUsedError;
  MarketLimitsModel get limits => throw _privateConstructorUsedError;

  /// Serializes this MarketMetadataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketMetadataModelCopyWith<MarketMetadataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketMetadataModelCopyWith<$Res> {
  factory $MarketMetadataModelCopyWith(
          MarketMetadataModel value, $Res Function(MarketMetadataModel) then) =
      _$MarketMetadataModelCopyWithImpl<$Res, MarketMetadataModel>;
  @useResult
  $Res call(
      {double? taker,
      double? maker,
      MarketPrecisionModel precision,
      MarketLimitsModel limits});

  $MarketPrecisionModelCopyWith<$Res> get precision;
  $MarketLimitsModelCopyWith<$Res> get limits;
}

/// @nodoc
class _$MarketMetadataModelCopyWithImpl<$Res, $Val extends MarketMetadataModel>
    implements $MarketMetadataModelCopyWith<$Res> {
  _$MarketMetadataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taker = freezed,
    Object? maker = freezed,
    Object? precision = null,
    Object? limits = null,
  }) {
    return _then(_value.copyWith(
      taker: freezed == taker
          ? _value.taker
          : taker // ignore: cast_nullable_to_non_nullable
              as double?,
      maker: freezed == maker
          ? _value.maker
          : maker // ignore: cast_nullable_to_non_nullable
              as double?,
      precision: null == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as MarketPrecisionModel,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as MarketLimitsModel,
    ) as $Val);
  }

  /// Create a copy of MarketMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketPrecisionModelCopyWith<$Res> get precision {
    return $MarketPrecisionModelCopyWith<$Res>(_value.precision, (value) {
      return _then(_value.copyWith(precision: value) as $Val);
    });
  }

  /// Create a copy of MarketMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketLimitsModelCopyWith<$Res> get limits {
    return $MarketLimitsModelCopyWith<$Res>(_value.limits, (value) {
      return _then(_value.copyWith(limits: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MarketMetadataModelImplCopyWith<$Res>
    implements $MarketMetadataModelCopyWith<$Res> {
  factory _$$MarketMetadataModelImplCopyWith(_$MarketMetadataModelImpl value,
          $Res Function(_$MarketMetadataModelImpl) then) =
      __$$MarketMetadataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double? taker,
      double? maker,
      MarketPrecisionModel precision,
      MarketLimitsModel limits});

  @override
  $MarketPrecisionModelCopyWith<$Res> get precision;
  @override
  $MarketLimitsModelCopyWith<$Res> get limits;
}

/// @nodoc
class __$$MarketMetadataModelImplCopyWithImpl<$Res>
    extends _$MarketMetadataModelCopyWithImpl<$Res, _$MarketMetadataModelImpl>
    implements _$$MarketMetadataModelImplCopyWith<$Res> {
  __$$MarketMetadataModelImplCopyWithImpl(_$MarketMetadataModelImpl _value,
      $Res Function(_$MarketMetadataModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taker = freezed,
    Object? maker = freezed,
    Object? precision = null,
    Object? limits = null,
  }) {
    return _then(_$MarketMetadataModelImpl(
      taker: freezed == taker
          ? _value.taker
          : taker // ignore: cast_nullable_to_non_nullable
              as double?,
      maker: freezed == maker
          ? _value.maker
          : maker // ignore: cast_nullable_to_non_nullable
              as double?,
      precision: null == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as MarketPrecisionModel,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as MarketLimitsModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketMetadataModelImpl implements _MarketMetadataModel {
  const _$MarketMetadataModelImpl(
      {this.taker, this.maker, required this.precision, required this.limits});

  factory _$MarketMetadataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketMetadataModelImplFromJson(json);

  @override
  final double? taker;
  @override
  final double? maker;
  @override
  final MarketPrecisionModel precision;
  @override
  final MarketLimitsModel limits;

  @override
  String toString() {
    return 'MarketMetadataModel(taker: $taker, maker: $maker, precision: $precision, limits: $limits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketMetadataModelImpl &&
            (identical(other.taker, taker) || other.taker == taker) &&
            (identical(other.maker, maker) || other.maker == maker) &&
            (identical(other.precision, precision) ||
                other.precision == precision) &&
            (identical(other.limits, limits) || other.limits == limits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taker, maker, precision, limits);

  /// Create a copy of MarketMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketMetadataModelImplCopyWith<_$MarketMetadataModelImpl> get copyWith =>
      __$$MarketMetadataModelImplCopyWithImpl<_$MarketMetadataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketMetadataModelImplToJson(
      this,
    );
  }
}

abstract class _MarketMetadataModel implements MarketMetadataModel {
  const factory _MarketMetadataModel(
      {final double? taker,
      final double? maker,
      required final MarketPrecisionModel precision,
      required final MarketLimitsModel limits}) = _$MarketMetadataModelImpl;

  factory _MarketMetadataModel.fromJson(Map<String, dynamic> json) =
      _$MarketMetadataModelImpl.fromJson;

  @override
  double? get taker;
  @override
  double? get maker;
  @override
  MarketPrecisionModel get precision;
  @override
  MarketLimitsModel get limits;

  /// Create a copy of MarketMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketMetadataModelImplCopyWith<_$MarketMetadataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketPrecisionModel _$MarketPrecisionModelFromJson(Map<String, dynamic> json) {
  return _MarketPrecisionModel.fromJson(json);
}

/// @nodoc
mixin _$MarketPrecisionModel {
  int get price => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;

  /// Serializes this MarketPrecisionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketPrecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketPrecisionModelCopyWith<MarketPrecisionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketPrecisionModelCopyWith<$Res> {
  factory $MarketPrecisionModelCopyWith(MarketPrecisionModel value,
          $Res Function(MarketPrecisionModel) then) =
      _$MarketPrecisionModelCopyWithImpl<$Res, MarketPrecisionModel>;
  @useResult
  $Res call({int price, int amount});
}

/// @nodoc
class _$MarketPrecisionModelCopyWithImpl<$Res,
        $Val extends MarketPrecisionModel>
    implements $MarketPrecisionModelCopyWith<$Res> {
  _$MarketPrecisionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketPrecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? amount = null,
  }) {
    return _then(_value.copyWith(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MarketPrecisionModelImplCopyWith<$Res>
    implements $MarketPrecisionModelCopyWith<$Res> {
  factory _$$MarketPrecisionModelImplCopyWith(_$MarketPrecisionModelImpl value,
          $Res Function(_$MarketPrecisionModelImpl) then) =
      __$$MarketPrecisionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int price, int amount});
}

/// @nodoc
class __$$MarketPrecisionModelImplCopyWithImpl<$Res>
    extends _$MarketPrecisionModelCopyWithImpl<$Res, _$MarketPrecisionModelImpl>
    implements _$$MarketPrecisionModelImplCopyWith<$Res> {
  __$$MarketPrecisionModelImplCopyWithImpl(_$MarketPrecisionModelImpl _value,
      $Res Function(_$MarketPrecisionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketPrecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? amount = null,
  }) {
    return _then(_$MarketPrecisionModelImpl(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketPrecisionModelImpl implements _MarketPrecisionModel {
  const _$MarketPrecisionModelImpl({required this.price, required this.amount});

  factory _$MarketPrecisionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketPrecisionModelImplFromJson(json);

  @override
  final int price;
  @override
  final int amount;

  @override
  String toString() {
    return 'MarketPrecisionModel(price: $price, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketPrecisionModelImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, price, amount);

  /// Create a copy of MarketPrecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketPrecisionModelImplCopyWith<_$MarketPrecisionModelImpl>
      get copyWith =>
          __$$MarketPrecisionModelImplCopyWithImpl<_$MarketPrecisionModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketPrecisionModelImplToJson(
      this,
    );
  }
}

abstract class _MarketPrecisionModel implements MarketPrecisionModel {
  const factory _MarketPrecisionModel(
      {required final int price,
      required final int amount}) = _$MarketPrecisionModelImpl;

  factory _MarketPrecisionModel.fromJson(Map<String, dynamic> json) =
      _$MarketPrecisionModelImpl.fromJson;

  @override
  int get price;
  @override
  int get amount;

  /// Create a copy of MarketPrecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketPrecisionModelImplCopyWith<_$MarketPrecisionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MarketLimitsModel _$MarketLimitsModelFromJson(Map<String, dynamic> json) {
  return _MarketLimitsModel.fromJson(json);
}

/// @nodoc
mixin _$MarketLimitsModel {
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  MarketLimitModel? get amount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  MarketLimitModel? get price => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  MarketLimitModel? get cost => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
  Map<String, dynamic>? get leverage => throw _privateConstructorUsedError;

  /// Serializes this MarketLimitsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketLimitsModelCopyWith<MarketLimitsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketLimitsModelCopyWith<$Res> {
  factory $MarketLimitsModelCopyWith(
          MarketLimitsModel value, $Res Function(MarketLimitsModel) then) =
      _$MarketLimitsModelCopyWithImpl<$Res, MarketLimitsModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      MarketLimitModel? amount,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      MarketLimitModel? price,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      MarketLimitModel? cost,
      @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
      Map<String, dynamic>? leverage});

  $MarketLimitModelCopyWith<$Res>? get amount;
  $MarketLimitModelCopyWith<$Res>? get price;
  $MarketLimitModelCopyWith<$Res>? get cost;
}

/// @nodoc
class _$MarketLimitsModelCopyWithImpl<$Res, $Val extends MarketLimitsModel>
    implements $MarketLimitsModelCopyWith<$Res> {
  _$MarketLimitsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = freezed,
    Object? price = freezed,
    Object? cost = freezed,
    Object? leverage = freezed,
  }) {
    return _then(_value.copyWith(
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as MarketLimitModel?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as MarketLimitModel?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as MarketLimitModel?,
      leverage: freezed == leverage
          ? _value.leverage
          : leverage // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketLimitModelCopyWith<$Res>? get amount {
    if (_value.amount == null) {
      return null;
    }

    return $MarketLimitModelCopyWith<$Res>(_value.amount!, (value) {
      return _then(_value.copyWith(amount: value) as $Val);
    });
  }

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketLimitModelCopyWith<$Res>? get price {
    if (_value.price == null) {
      return null;
    }

    return $MarketLimitModelCopyWith<$Res>(_value.price!, (value) {
      return _then(_value.copyWith(price: value) as $Val);
    });
  }

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketLimitModelCopyWith<$Res>? get cost {
    if (_value.cost == null) {
      return null;
    }

    return $MarketLimitModelCopyWith<$Res>(_value.cost!, (value) {
      return _then(_value.copyWith(cost: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MarketLimitsModelImplCopyWith<$Res>
    implements $MarketLimitsModelCopyWith<$Res> {
  factory _$$MarketLimitsModelImplCopyWith(_$MarketLimitsModelImpl value,
          $Res Function(_$MarketLimitsModelImpl) then) =
      __$$MarketLimitsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      MarketLimitModel? amount,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      MarketLimitModel? price,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      MarketLimitModel? cost,
      @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
      Map<String, dynamic>? leverage});

  @override
  $MarketLimitModelCopyWith<$Res>? get amount;
  @override
  $MarketLimitModelCopyWith<$Res>? get price;
  @override
  $MarketLimitModelCopyWith<$Res>? get cost;
}

/// @nodoc
class __$$MarketLimitsModelImplCopyWithImpl<$Res>
    extends _$MarketLimitsModelCopyWithImpl<$Res, _$MarketLimitsModelImpl>
    implements _$$MarketLimitsModelImplCopyWith<$Res> {
  __$$MarketLimitsModelImplCopyWithImpl(_$MarketLimitsModelImpl _value,
      $Res Function(_$MarketLimitsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = freezed,
    Object? price = freezed,
    Object? cost = freezed,
    Object? leverage = freezed,
  }) {
    return _then(_$MarketLimitsModelImpl(
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as MarketLimitModel?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as MarketLimitModel?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as MarketLimitModel?,
      leverage: freezed == leverage
          ? _value._leverage
          : leverage // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketLimitsModelImpl implements _MarketLimitsModel {
  const _$MarketLimitsModelImpl(
      {@JsonKey(fromJson: _limitFromJson, toJson: _limitToJson) this.amount,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson) this.price,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson) this.cost,
      @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
      final Map<String, dynamic>? leverage})
      : _leverage = leverage;

  factory _$MarketLimitsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketLimitsModelImplFromJson(json);

  @override
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  final MarketLimitModel? amount;
  @override
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  final MarketLimitModel? price;
  @override
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  final MarketLimitModel? cost;
  final Map<String, dynamic>? _leverage;
  @override
  @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
  Map<String, dynamic>? get leverage {
    final value = _leverage;
    if (value == null) return null;
    if (_leverage is EqualUnmodifiableMapView) return _leverage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MarketLimitsModel(amount: $amount, price: $price, cost: $cost, leverage: $leverage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketLimitsModelImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            const DeepCollectionEquality().equals(other._leverage, _leverage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, amount, price, cost,
      const DeepCollectionEquality().hash(_leverage));

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketLimitsModelImplCopyWith<_$MarketLimitsModelImpl> get copyWith =>
      __$$MarketLimitsModelImplCopyWithImpl<_$MarketLimitsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketLimitsModelImplToJson(
      this,
    );
  }
}

abstract class _MarketLimitsModel implements MarketLimitsModel {
  const factory _MarketLimitsModel(
      {@JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      final MarketLimitModel? amount,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      final MarketLimitModel? price,
      @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
      final MarketLimitModel? cost,
      @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
      final Map<String, dynamic>? leverage}) = _$MarketLimitsModelImpl;

  factory _MarketLimitsModel.fromJson(Map<String, dynamic> json) =
      _$MarketLimitsModelImpl.fromJson;

  @override
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  MarketLimitModel? get amount;
  @override
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  MarketLimitModel? get price;
  @override
  @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
  MarketLimitModel? get cost;
  @override
  @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
  Map<String, dynamic>? get leverage;

  /// Create a copy of MarketLimitsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketLimitsModelImplCopyWith<_$MarketLimitsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketLimitModel _$MarketLimitModelFromJson(Map<String, dynamic> json) {
  return _MarketLimitModel.fromJson(json);
}

/// @nodoc
mixin _$MarketLimitModel {
  double get min => throw _privateConstructorUsedError;
  double? get max => throw _privateConstructorUsedError;

  /// Serializes this MarketLimitModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketLimitModelCopyWith<MarketLimitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketLimitModelCopyWith<$Res> {
  factory $MarketLimitModelCopyWith(
          MarketLimitModel value, $Res Function(MarketLimitModel) then) =
      _$MarketLimitModelCopyWithImpl<$Res, MarketLimitModel>;
  @useResult
  $Res call({double min, double? max});
}

/// @nodoc
class _$MarketLimitModelCopyWithImpl<$Res, $Val extends MarketLimitModel>
    implements $MarketLimitModelCopyWith<$Res> {
  _$MarketLimitModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketLimitModel
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
abstract class _$$MarketLimitModelImplCopyWith<$Res>
    implements $MarketLimitModelCopyWith<$Res> {
  factory _$$MarketLimitModelImplCopyWith(_$MarketLimitModelImpl value,
          $Res Function(_$MarketLimitModelImpl) then) =
      __$$MarketLimitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double min, double? max});
}

/// @nodoc
class __$$MarketLimitModelImplCopyWithImpl<$Res>
    extends _$MarketLimitModelCopyWithImpl<$Res, _$MarketLimitModelImpl>
    implements _$$MarketLimitModelImplCopyWith<$Res> {
  __$$MarketLimitModelImplCopyWithImpl(_$MarketLimitModelImpl _value,
      $Res Function(_$MarketLimitModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = freezed,
  }) {
    return _then(_$MarketLimitModelImpl(
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
class _$MarketLimitModelImpl implements _MarketLimitModel {
  const _$MarketLimitModelImpl({required this.min, this.max});

  factory _$MarketLimitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketLimitModelImplFromJson(json);

  @override
  final double min;
  @override
  final double? max;

  @override
  String toString() {
    return 'MarketLimitModel(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketLimitModelImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of MarketLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketLimitModelImplCopyWith<_$MarketLimitModelImpl> get copyWith =>
      __$$MarketLimitModelImplCopyWithImpl<_$MarketLimitModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketLimitModelImplToJson(
      this,
    );
  }
}

abstract class _MarketLimitModel implements MarketLimitModel {
  const factory _MarketLimitModel(
      {required final double min, final double? max}) = _$MarketLimitModelImpl;

  factory _MarketLimitModel.fromJson(Map<String, dynamic> json) =
      _$MarketLimitModelImpl.fromJson;

  @override
  double get min;
  @override
  double? get max;

  /// Create a copy of MarketLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketLimitModelImplCopyWith<_$MarketLimitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
