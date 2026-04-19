// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_market_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

P2PMarketStatsModel _$P2PMarketStatsModelFromJson(Map<String, dynamic> json) {
  return _P2PMarketStatsModel.fromJson(json);
}

/// @nodoc
mixin _$P2PMarketStatsModel {
  @JsonKey(name: 'totalTrades')
  int get totalTrades => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalVolume')
  double get totalVolume => throw _privateConstructorUsedError;
  @JsonKey(name: 'avgTradeSize')
  double get avgTradeSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'activeTrades')
  int get activeTrades => throw _privateConstructorUsedError;
  @JsonKey(name: 'last24hTrades')
  int get last24hTrades => throw _privateConstructorUsedError;
  @JsonKey(name: 'last24hVolume')
  double get last24hVolume => throw _privateConstructorUsedError;
  @JsonKey(name: 'topCurrencies')
  List<String> get topCurrencies => throw _privateConstructorUsedError;

  /// Serializes this P2PMarketStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PMarketStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PMarketStatsModelCopyWith<P2PMarketStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PMarketStatsModelCopyWith<$Res> {
  factory $P2PMarketStatsModelCopyWith(
          P2PMarketStatsModel value, $Res Function(P2PMarketStatsModel) then) =
      _$P2PMarketStatsModelCopyWithImpl<$Res, P2PMarketStatsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'totalTrades') int totalTrades,
      @JsonKey(name: 'totalVolume') double totalVolume,
      @JsonKey(name: 'avgTradeSize') double avgTradeSize,
      @JsonKey(name: 'activeTrades') int activeTrades,
      @JsonKey(name: 'last24hTrades') int last24hTrades,
      @JsonKey(name: 'last24hVolume') double last24hVolume,
      @JsonKey(name: 'topCurrencies') List<String> topCurrencies});
}

/// @nodoc
class _$P2PMarketStatsModelCopyWithImpl<$Res, $Val extends P2PMarketStatsModel>
    implements $P2PMarketStatsModelCopyWith<$Res> {
  _$P2PMarketStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PMarketStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTrades = null,
    Object? totalVolume = null,
    Object? avgTradeSize = null,
    Object? activeTrades = null,
    Object? last24hTrades = null,
    Object? last24hVolume = null,
    Object? topCurrencies = null,
  }) {
    return _then(_value.copyWith(
      totalTrades: null == totalTrades
          ? _value.totalTrades
          : totalTrades // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as double,
      avgTradeSize: null == avgTradeSize
          ? _value.avgTradeSize
          : avgTradeSize // ignore: cast_nullable_to_non_nullable
              as double,
      activeTrades: null == activeTrades
          ? _value.activeTrades
          : activeTrades // ignore: cast_nullable_to_non_nullable
              as int,
      last24hTrades: null == last24hTrades
          ? _value.last24hTrades
          : last24hTrades // ignore: cast_nullable_to_non_nullable
              as int,
      last24hVolume: null == last24hVolume
          ? _value.last24hVolume
          : last24hVolume // ignore: cast_nullable_to_non_nullable
              as double,
      topCurrencies: null == topCurrencies
          ? _value.topCurrencies
          : topCurrencies // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2PMarketStatsModelImplCopyWith<$Res>
    implements $P2PMarketStatsModelCopyWith<$Res> {
  factory _$$P2PMarketStatsModelImplCopyWith(_$P2PMarketStatsModelImpl value,
          $Res Function(_$P2PMarketStatsModelImpl) then) =
      __$$P2PMarketStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'totalTrades') int totalTrades,
      @JsonKey(name: 'totalVolume') double totalVolume,
      @JsonKey(name: 'avgTradeSize') double avgTradeSize,
      @JsonKey(name: 'activeTrades') int activeTrades,
      @JsonKey(name: 'last24hTrades') int last24hTrades,
      @JsonKey(name: 'last24hVolume') double last24hVolume,
      @JsonKey(name: 'topCurrencies') List<String> topCurrencies});
}

/// @nodoc
class __$$P2PMarketStatsModelImplCopyWithImpl<$Res>
    extends _$P2PMarketStatsModelCopyWithImpl<$Res, _$P2PMarketStatsModelImpl>
    implements _$$P2PMarketStatsModelImplCopyWith<$Res> {
  __$$P2PMarketStatsModelImplCopyWithImpl(_$P2PMarketStatsModelImpl _value,
      $Res Function(_$P2PMarketStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PMarketStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTrades = null,
    Object? totalVolume = null,
    Object? avgTradeSize = null,
    Object? activeTrades = null,
    Object? last24hTrades = null,
    Object? last24hVolume = null,
    Object? topCurrencies = null,
  }) {
    return _then(_$P2PMarketStatsModelImpl(
      totalTrades: null == totalTrades
          ? _value.totalTrades
          : totalTrades // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as double,
      avgTradeSize: null == avgTradeSize
          ? _value.avgTradeSize
          : avgTradeSize // ignore: cast_nullable_to_non_nullable
              as double,
      activeTrades: null == activeTrades
          ? _value.activeTrades
          : activeTrades // ignore: cast_nullable_to_non_nullable
              as int,
      last24hTrades: null == last24hTrades
          ? _value.last24hTrades
          : last24hTrades // ignore: cast_nullable_to_non_nullable
              as int,
      last24hVolume: null == last24hVolume
          ? _value.last24hVolume
          : last24hVolume // ignore: cast_nullable_to_non_nullable
              as double,
      topCurrencies: null == topCurrencies
          ? _value._topCurrencies
          : topCurrencies // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PMarketStatsModelImpl implements _P2PMarketStatsModel {
  const _$P2PMarketStatsModelImpl(
      {@JsonKey(name: 'totalTrades') required this.totalTrades,
      @JsonKey(name: 'totalVolume') required this.totalVolume,
      @JsonKey(name: 'avgTradeSize') required this.avgTradeSize,
      @JsonKey(name: 'activeTrades') required this.activeTrades,
      @JsonKey(name: 'last24hTrades') required this.last24hTrades,
      @JsonKey(name: 'last24hVolume') required this.last24hVolume,
      @JsonKey(name: 'topCurrencies')
      required final List<String> topCurrencies})
      : _topCurrencies = topCurrencies;

  factory _$P2PMarketStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PMarketStatsModelImplFromJson(json);

  @override
  @JsonKey(name: 'totalTrades')
  final int totalTrades;
  @override
  @JsonKey(name: 'totalVolume')
  final double totalVolume;
  @override
  @JsonKey(name: 'avgTradeSize')
  final double avgTradeSize;
  @override
  @JsonKey(name: 'activeTrades')
  final int activeTrades;
  @override
  @JsonKey(name: 'last24hTrades')
  final int last24hTrades;
  @override
  @JsonKey(name: 'last24hVolume')
  final double last24hVolume;
  final List<String> _topCurrencies;
  @override
  @JsonKey(name: 'topCurrencies')
  List<String> get topCurrencies {
    if (_topCurrencies is EqualUnmodifiableListView) return _topCurrencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topCurrencies);
  }

  @override
  String toString() {
    return 'P2PMarketStatsModel(totalTrades: $totalTrades, totalVolume: $totalVolume, avgTradeSize: $avgTradeSize, activeTrades: $activeTrades, last24hTrades: $last24hTrades, last24hVolume: $last24hVolume, topCurrencies: $topCurrencies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PMarketStatsModelImpl &&
            (identical(other.totalTrades, totalTrades) ||
                other.totalTrades == totalTrades) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.avgTradeSize, avgTradeSize) ||
                other.avgTradeSize == avgTradeSize) &&
            (identical(other.activeTrades, activeTrades) ||
                other.activeTrades == activeTrades) &&
            (identical(other.last24hTrades, last24hTrades) ||
                other.last24hTrades == last24hTrades) &&
            (identical(other.last24hVolume, last24hVolume) ||
                other.last24hVolume == last24hVolume) &&
            const DeepCollectionEquality()
                .equals(other._topCurrencies, _topCurrencies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalTrades,
      totalVolume,
      avgTradeSize,
      activeTrades,
      last24hTrades,
      last24hVolume,
      const DeepCollectionEquality().hash(_topCurrencies));

  /// Create a copy of P2PMarketStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PMarketStatsModelImplCopyWith<_$P2PMarketStatsModelImpl> get copyWith =>
      __$$P2PMarketStatsModelImplCopyWithImpl<_$P2PMarketStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PMarketStatsModelImplToJson(
      this,
    );
  }
}

abstract class _P2PMarketStatsModel implements P2PMarketStatsModel {
  const factory _P2PMarketStatsModel(
      {@JsonKey(name: 'totalTrades') required final int totalTrades,
      @JsonKey(name: 'totalVolume') required final double totalVolume,
      @JsonKey(name: 'avgTradeSize') required final double avgTradeSize,
      @JsonKey(name: 'activeTrades') required final int activeTrades,
      @JsonKey(name: 'last24hTrades') required final int last24hTrades,
      @JsonKey(name: 'last24hVolume') required final double last24hVolume,
      @JsonKey(name: 'topCurrencies')
      required final List<String> topCurrencies}) = _$P2PMarketStatsModelImpl;

  factory _P2PMarketStatsModel.fromJson(Map<String, dynamic> json) =
      _$P2PMarketStatsModelImpl.fromJson;

  @override
  @JsonKey(name: 'totalTrades')
  int get totalTrades;
  @override
  @JsonKey(name: 'totalVolume')
  double get totalVolume;
  @override
  @JsonKey(name: 'avgTradeSize')
  double get avgTradeSize;
  @override
  @JsonKey(name: 'activeTrades')
  int get activeTrades;
  @override
  @JsonKey(name: 'last24hTrades')
  int get last24hTrades;
  @override
  @JsonKey(name: 'last24hVolume')
  double get last24hVolume;
  @override
  @JsonKey(name: 'topCurrencies')
  List<String> get topCurrencies;

  /// Create a copy of P2PMarketStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PMarketStatsModelImplCopyWith<_$P2PMarketStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

P2PTopCryptoModel _$P2PTopCryptoModelFromJson(Map<String, dynamic> json) {
  return _P2PTopCryptoModel.fromJson(json);
}

/// @nodoc
mixin _$P2PTopCryptoModel {
  String get symbol => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'volume24h')
  double get volume24h => throw _privateConstructorUsedError;
  @JsonKey(name: 'tradeCount')
  int get tradeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'avgPrice')
  double get avgPrice => throw _privateConstructorUsedError;

  /// Serializes this P2PTopCryptoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PTopCryptoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PTopCryptoModelCopyWith<P2PTopCryptoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PTopCryptoModelCopyWith<$Res> {
  factory $P2PTopCryptoModelCopyWith(
          P2PTopCryptoModel value, $Res Function(P2PTopCryptoModel) then) =
      _$P2PTopCryptoModelCopyWithImpl<$Res, P2PTopCryptoModel>;
  @useResult
  $Res call(
      {String symbol,
      String name,
      @JsonKey(name: 'volume24h') double volume24h,
      @JsonKey(name: 'tradeCount') int tradeCount,
      @JsonKey(name: 'avgPrice') double avgPrice});
}

/// @nodoc
class _$P2PTopCryptoModelCopyWithImpl<$Res, $Val extends P2PTopCryptoModel>
    implements $P2PTopCryptoModelCopyWith<$Res> {
  _$P2PTopCryptoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PTopCryptoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? volume24h = null,
    Object? tradeCount = null,
    Object? avgPrice = null,
  }) {
    return _then(_value.copyWith(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      volume24h: null == volume24h
          ? _value.volume24h
          : volume24h // ignore: cast_nullable_to_non_nullable
              as double,
      tradeCount: null == tradeCount
          ? _value.tradeCount
          : tradeCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgPrice: null == avgPrice
          ? _value.avgPrice
          : avgPrice // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2PTopCryptoModelImplCopyWith<$Res>
    implements $P2PTopCryptoModelCopyWith<$Res> {
  factory _$$P2PTopCryptoModelImplCopyWith(_$P2PTopCryptoModelImpl value,
          $Res Function(_$P2PTopCryptoModelImpl) then) =
      __$$P2PTopCryptoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String symbol,
      String name,
      @JsonKey(name: 'volume24h') double volume24h,
      @JsonKey(name: 'tradeCount') int tradeCount,
      @JsonKey(name: 'avgPrice') double avgPrice});
}

/// @nodoc
class __$$P2PTopCryptoModelImplCopyWithImpl<$Res>
    extends _$P2PTopCryptoModelCopyWithImpl<$Res, _$P2PTopCryptoModelImpl>
    implements _$$P2PTopCryptoModelImplCopyWith<$Res> {
  __$$P2PTopCryptoModelImplCopyWithImpl(_$P2PTopCryptoModelImpl _value,
      $Res Function(_$P2PTopCryptoModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PTopCryptoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? volume24h = null,
    Object? tradeCount = null,
    Object? avgPrice = null,
  }) {
    return _then(_$P2PTopCryptoModelImpl(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      volume24h: null == volume24h
          ? _value.volume24h
          : volume24h // ignore: cast_nullable_to_non_nullable
              as double,
      tradeCount: null == tradeCount
          ? _value.tradeCount
          : tradeCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgPrice: null == avgPrice
          ? _value.avgPrice
          : avgPrice // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PTopCryptoModelImpl implements _P2PTopCryptoModel {
  const _$P2PTopCryptoModelImpl(
      {required this.symbol,
      required this.name,
      @JsonKey(name: 'volume24h') required this.volume24h,
      @JsonKey(name: 'tradeCount') required this.tradeCount,
      @JsonKey(name: 'avgPrice') required this.avgPrice});

  factory _$P2PTopCryptoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PTopCryptoModelImplFromJson(json);

  @override
  final String symbol;
  @override
  final String name;
  @override
  @JsonKey(name: 'volume24h')
  final double volume24h;
  @override
  @JsonKey(name: 'tradeCount')
  final int tradeCount;
  @override
  @JsonKey(name: 'avgPrice')
  final double avgPrice;

  @override
  String toString() {
    return 'P2PTopCryptoModel(symbol: $symbol, name: $name, volume24h: $volume24h, tradeCount: $tradeCount, avgPrice: $avgPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PTopCryptoModelImpl &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.volume24h, volume24h) ||
                other.volume24h == volume24h) &&
            (identical(other.tradeCount, tradeCount) ||
                other.tradeCount == tradeCount) &&
            (identical(other.avgPrice, avgPrice) ||
                other.avgPrice == avgPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, symbol, name, volume24h, tradeCount, avgPrice);

  /// Create a copy of P2PTopCryptoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PTopCryptoModelImplCopyWith<_$P2PTopCryptoModelImpl> get copyWith =>
      __$$P2PTopCryptoModelImplCopyWithImpl<_$P2PTopCryptoModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PTopCryptoModelImplToJson(
      this,
    );
  }
}

abstract class _P2PTopCryptoModel implements P2PTopCryptoModel {
  const factory _P2PTopCryptoModel(
          {required final String symbol,
          required final String name,
          @JsonKey(name: 'volume24h') required final double volume24h,
          @JsonKey(name: 'tradeCount') required final int tradeCount,
          @JsonKey(name: 'avgPrice') required final double avgPrice}) =
      _$P2PTopCryptoModelImpl;

  factory _P2PTopCryptoModel.fromJson(Map<String, dynamic> json) =
      _$P2PTopCryptoModelImpl.fromJson;

  @override
  String get symbol;
  @override
  String get name;
  @override
  @JsonKey(name: 'volume24h')
  double get volume24h;
  @override
  @JsonKey(name: 'tradeCount')
  int get tradeCount;
  @override
  @JsonKey(name: 'avgPrice')
  double get avgPrice;

  /// Create a copy of P2PTopCryptoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PTopCryptoModelImplCopyWith<_$P2PTopCryptoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

P2PMarketHighlightModel _$P2PMarketHighlightModelFromJson(
    Map<String, dynamic> json) {
  return _P2PMarketHighlightModel.fromJson(json);
}

/// @nodoc
mixin _$P2PMarketHighlightModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'paymentMethod')
  String get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'country')
  String get country => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  int? get views => throw _privateConstructorUsedError;
  double? get matchScore => throw _privateConstructorUsedError;

  /// Serializes this P2PMarketHighlightModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PMarketHighlightModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PMarketHighlightModelCopyWith<P2PMarketHighlightModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PMarketHighlightModelCopyWith<$Res> {
  factory $P2PMarketHighlightModelCopyWith(P2PMarketHighlightModel value,
          $Res Function(P2PMarketHighlightModel) then) =
      _$P2PMarketHighlightModelCopyWithImpl<$Res, P2PMarketHighlightModel>;
  @useResult
  $Res call(
      {String id,
      String type,
      String currency,
      double price,
      double amount,
      @JsonKey(name: 'paymentMethod') String paymentMethod,
      @JsonKey(name: 'country') String country,
      DateTime? createdAt,
      int? views,
      double? matchScore});
}

/// @nodoc
class _$P2PMarketHighlightModelCopyWithImpl<$Res,
        $Val extends P2PMarketHighlightModel>
    implements $P2PMarketHighlightModelCopyWith<$Res> {
  _$P2PMarketHighlightModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PMarketHighlightModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? currency = null,
    Object? price = null,
    Object? amount = null,
    Object? paymentMethod = null,
    Object? country = null,
    Object? createdAt = freezed,
    Object? views = freezed,
    Object? matchScore = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      views: freezed == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int?,
      matchScore: freezed == matchScore
          ? _value.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2PMarketHighlightModelImplCopyWith<$Res>
    implements $P2PMarketHighlightModelCopyWith<$Res> {
  factory _$$P2PMarketHighlightModelImplCopyWith(
          _$P2PMarketHighlightModelImpl value,
          $Res Function(_$P2PMarketHighlightModelImpl) then) =
      __$$P2PMarketHighlightModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String currency,
      double price,
      double amount,
      @JsonKey(name: 'paymentMethod') String paymentMethod,
      @JsonKey(name: 'country') String country,
      DateTime? createdAt,
      int? views,
      double? matchScore});
}

/// @nodoc
class __$$P2PMarketHighlightModelImplCopyWithImpl<$Res>
    extends _$P2PMarketHighlightModelCopyWithImpl<$Res,
        _$P2PMarketHighlightModelImpl>
    implements _$$P2PMarketHighlightModelImplCopyWith<$Res> {
  __$$P2PMarketHighlightModelImplCopyWithImpl(
      _$P2PMarketHighlightModelImpl _value,
      $Res Function(_$P2PMarketHighlightModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PMarketHighlightModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? currency = null,
    Object? price = null,
    Object? amount = null,
    Object? paymentMethod = null,
    Object? country = null,
    Object? createdAt = freezed,
    Object? views = freezed,
    Object? matchScore = freezed,
  }) {
    return _then(_$P2PMarketHighlightModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      views: freezed == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int?,
      matchScore: freezed == matchScore
          ? _value.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PMarketHighlightModelImpl implements _P2PMarketHighlightModel {
  const _$P2PMarketHighlightModelImpl(
      {required this.id,
      required this.type,
      required this.currency,
      required this.price,
      required this.amount,
      @JsonKey(name: 'paymentMethod') required this.paymentMethod,
      @JsonKey(name: 'country') required this.country,
      this.createdAt,
      this.views,
      this.matchScore});

  factory _$P2PMarketHighlightModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PMarketHighlightModelImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String currency;
  @override
  final double price;
  @override
  final double amount;
  @override
  @JsonKey(name: 'paymentMethod')
  final String paymentMethod;
  @override
  @JsonKey(name: 'country')
  final String country;
  @override
  final DateTime? createdAt;
  @override
  final int? views;
  @override
  final double? matchScore;

  @override
  String toString() {
    return 'P2PMarketHighlightModel(id: $id, type: $type, currency: $currency, price: $price, amount: $amount, paymentMethod: $paymentMethod, country: $country, createdAt: $createdAt, views: $views, matchScore: $matchScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PMarketHighlightModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, currency, price,
      amount, paymentMethod, country, createdAt, views, matchScore);

  /// Create a copy of P2PMarketHighlightModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PMarketHighlightModelImplCopyWith<_$P2PMarketHighlightModelImpl>
      get copyWith => __$$P2PMarketHighlightModelImplCopyWithImpl<
          _$P2PMarketHighlightModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PMarketHighlightModelImplToJson(
      this,
    );
  }
}

abstract class _P2PMarketHighlightModel implements P2PMarketHighlightModel {
  const factory _P2PMarketHighlightModel(
      {required final String id,
      required final String type,
      required final String currency,
      required final double price,
      required final double amount,
      @JsonKey(name: 'paymentMethod') required final String paymentMethod,
      @JsonKey(name: 'country') required final String country,
      final DateTime? createdAt,
      final int? views,
      final double? matchScore}) = _$P2PMarketHighlightModelImpl;

  factory _P2PMarketHighlightModel.fromJson(Map<String, dynamic> json) =
      _$P2PMarketHighlightModelImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get currency;
  @override
  double get price;
  @override
  double get amount;
  @override
  @JsonKey(name: 'paymentMethod')
  String get paymentMethod;
  @override
  @JsonKey(name: 'country')
  String get country;
  @override
  DateTime? get createdAt;
  @override
  int? get views;
  @override
  double? get matchScore;

  /// Create a copy of P2PMarketHighlightModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PMarketHighlightModelImplCopyWith<_$P2PMarketHighlightModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
