// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_offer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

P2POfferModel _$P2POfferModelFromJson(Map<String, dynamic> json) {
  return _P2POfferModel.fromJson(json);
}

/// @nodoc
mixin _$P2POfferModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get walletType => throw _privateConstructorUsedError;
  Map<String, dynamic> get amountConfig => throw _privateConstructorUsedError;
  Map<String, dynamic> get priceConfig => throw _privateConstructorUsedError;
  Map<String, dynamic> get tradeSettings => throw _privateConstructorUsedError;
  Map<String, dynamic>? get locationSettings =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get userRequirements =>
      throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  List<String>? get systemTags => throw _privateConstructorUsedError;
  String? get adminNotes => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  String? get deletedAt =>
      throw _privateConstructorUsedError; // Associated models
  P2PUserModel? get user => throw _privateConstructorUsedError;
  List<P2PPaymentMethodModel>? get paymentMethods =>
      throw _privateConstructorUsedError;
  P2POfferFlagModel? get flag => throw _privateConstructorUsedError;
  List<P2PTradeModel>? get trades => throw _privateConstructorUsedError;

  /// Serializes this P2POfferModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2POfferModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2POfferModelCopyWith<P2POfferModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2POfferModelCopyWith<$Res> {
  factory $P2POfferModelCopyWith(
          P2POfferModel value, $Res Function(P2POfferModel) then) =
      _$P2POfferModelCopyWithImpl<$Res, P2POfferModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String type,
      String currency,
      String walletType,
      Map<String, dynamic> amountConfig,
      Map<String, dynamic> priceConfig,
      Map<String, dynamic> tradeSettings,
      Map<String, dynamic>? locationSettings,
      Map<String, dynamic>? userRequirements,
      String status,
      int views,
      List<String>? systemTags,
      String? adminNotes,
      String createdAt,
      String updatedAt,
      String? deletedAt,
      P2PUserModel? user,
      List<P2PPaymentMethodModel>? paymentMethods,
      P2POfferFlagModel? flag,
      List<P2PTradeModel>? trades});

  $P2PUserModelCopyWith<$Res>? get user;
  $P2POfferFlagModelCopyWith<$Res>? get flag;
}

/// @nodoc
class _$P2POfferModelCopyWithImpl<$Res, $Val extends P2POfferModel>
    implements $P2POfferModelCopyWith<$Res> {
  _$P2POfferModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2POfferModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? currency = null,
    Object? walletType = null,
    Object? amountConfig = null,
    Object? priceConfig = null,
    Object? tradeSettings = null,
    Object? locationSettings = freezed,
    Object? userRequirements = freezed,
    Object? status = null,
    Object? views = null,
    Object? systemTags = freezed,
    Object? adminNotes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? user = freezed,
    Object? paymentMethods = freezed,
    Object? flag = freezed,
    Object? trades = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as String,
      amountConfig: null == amountConfig
          ? _value.amountConfig
          : amountConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priceConfig: null == priceConfig
          ? _value.priceConfig
          : priceConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      tradeSettings: null == tradeSettings
          ? _value.tradeSettings
          : tradeSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      locationSettings: freezed == locationSettings
          ? _value.locationSettings
          : locationSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      userRequirements: freezed == userRequirements
          ? _value.userRequirements
          : userRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      systemTags: freezed == systemTags
          ? _value.systemTags
          : systemTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as P2PUserModel?,
      paymentMethods: freezed == paymentMethods
          ? _value.paymentMethods
          : paymentMethods // ignore: cast_nullable_to_non_nullable
              as List<P2PPaymentMethodModel>?,
      flag: freezed == flag
          ? _value.flag
          : flag // ignore: cast_nullable_to_non_nullable
              as P2POfferFlagModel?,
      trades: freezed == trades
          ? _value.trades
          : trades // ignore: cast_nullable_to_non_nullable
              as List<P2PTradeModel>?,
    ) as $Val);
  }

  /// Create a copy of P2POfferModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $P2PUserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $P2PUserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of P2POfferModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $P2POfferFlagModelCopyWith<$Res>? get flag {
    if (_value.flag == null) {
      return null;
    }

    return $P2POfferFlagModelCopyWith<$Res>(_value.flag!, (value) {
      return _then(_value.copyWith(flag: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$P2POfferModelImplCopyWith<$Res>
    implements $P2POfferModelCopyWith<$Res> {
  factory _$$P2POfferModelImplCopyWith(
          _$P2POfferModelImpl value, $Res Function(_$P2POfferModelImpl) then) =
      __$$P2POfferModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String type,
      String currency,
      String walletType,
      Map<String, dynamic> amountConfig,
      Map<String, dynamic> priceConfig,
      Map<String, dynamic> tradeSettings,
      Map<String, dynamic>? locationSettings,
      Map<String, dynamic>? userRequirements,
      String status,
      int views,
      List<String>? systemTags,
      String? adminNotes,
      String createdAt,
      String updatedAt,
      String? deletedAt,
      P2PUserModel? user,
      List<P2PPaymentMethodModel>? paymentMethods,
      P2POfferFlagModel? flag,
      List<P2PTradeModel>? trades});

  @override
  $P2PUserModelCopyWith<$Res>? get user;
  @override
  $P2POfferFlagModelCopyWith<$Res>? get flag;
}

/// @nodoc
class __$$P2POfferModelImplCopyWithImpl<$Res>
    extends _$P2POfferModelCopyWithImpl<$Res, _$P2POfferModelImpl>
    implements _$$P2POfferModelImplCopyWith<$Res> {
  __$$P2POfferModelImplCopyWithImpl(
      _$P2POfferModelImpl _value, $Res Function(_$P2POfferModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2POfferModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? currency = null,
    Object? walletType = null,
    Object? amountConfig = null,
    Object? priceConfig = null,
    Object? tradeSettings = null,
    Object? locationSettings = freezed,
    Object? userRequirements = freezed,
    Object? status = null,
    Object? views = null,
    Object? systemTags = freezed,
    Object? adminNotes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? user = freezed,
    Object? paymentMethods = freezed,
    Object? flag = freezed,
    Object? trades = freezed,
  }) {
    return _then(_$P2POfferModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as String,
      amountConfig: null == amountConfig
          ? _value._amountConfig
          : amountConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priceConfig: null == priceConfig
          ? _value._priceConfig
          : priceConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      tradeSettings: null == tradeSettings
          ? _value._tradeSettings
          : tradeSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      locationSettings: freezed == locationSettings
          ? _value._locationSettings
          : locationSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      userRequirements: freezed == userRequirements
          ? _value._userRequirements
          : userRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      systemTags: freezed == systemTags
          ? _value._systemTags
          : systemTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as P2PUserModel?,
      paymentMethods: freezed == paymentMethods
          ? _value._paymentMethods
          : paymentMethods // ignore: cast_nullable_to_non_nullable
              as List<P2PPaymentMethodModel>?,
      flag: freezed == flag
          ? _value.flag
          : flag // ignore: cast_nullable_to_non_nullable
              as P2POfferFlagModel?,
      trades: freezed == trades
          ? _value._trades
          : trades // ignore: cast_nullable_to_non_nullable
              as List<P2PTradeModel>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2POfferModelImpl implements _P2POfferModel {
  const _$P2POfferModelImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.currency,
      required this.walletType,
      required final Map<String, dynamic> amountConfig,
      required final Map<String, dynamic> priceConfig,
      required final Map<String, dynamic> tradeSettings,
      final Map<String, dynamic>? locationSettings,
      final Map<String, dynamic>? userRequirements,
      required this.status,
      required this.views,
      final List<String>? systemTags,
      this.adminNotes,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.user,
      final List<P2PPaymentMethodModel>? paymentMethods,
      this.flag,
      final List<P2PTradeModel>? trades})
      : _amountConfig = amountConfig,
        _priceConfig = priceConfig,
        _tradeSettings = tradeSettings,
        _locationSettings = locationSettings,
        _userRequirements = userRequirements,
        _systemTags = systemTags,
        _paymentMethods = paymentMethods,
        _trades = trades;

  factory _$P2POfferModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2POfferModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String type;
  @override
  final String currency;
  @override
  final String walletType;
  final Map<String, dynamic> _amountConfig;
  @override
  Map<String, dynamic> get amountConfig {
    if (_amountConfig is EqualUnmodifiableMapView) return _amountConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_amountConfig);
  }

  final Map<String, dynamic> _priceConfig;
  @override
  Map<String, dynamic> get priceConfig {
    if (_priceConfig is EqualUnmodifiableMapView) return _priceConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_priceConfig);
  }

  final Map<String, dynamic> _tradeSettings;
  @override
  Map<String, dynamic> get tradeSettings {
    if (_tradeSettings is EqualUnmodifiableMapView) return _tradeSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tradeSettings);
  }

  final Map<String, dynamic>? _locationSettings;
  @override
  Map<String, dynamic>? get locationSettings {
    final value = _locationSettings;
    if (value == null) return null;
    if (_locationSettings is EqualUnmodifiableMapView) return _locationSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _userRequirements;
  @override
  Map<String, dynamic>? get userRequirements {
    final value = _userRequirements;
    if (value == null) return null;
    if (_userRequirements is EqualUnmodifiableMapView) return _userRequirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String status;
  @override
  final int views;
  final List<String>? _systemTags;
  @override
  List<String>? get systemTags {
    final value = _systemTags;
    if (value == null) return null;
    if (_systemTags is EqualUnmodifiableListView) return _systemTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? adminNotes;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  final String? deletedAt;
// Associated models
  @override
  final P2PUserModel? user;
  final List<P2PPaymentMethodModel>? _paymentMethods;
  @override
  List<P2PPaymentMethodModel>? get paymentMethods {
    final value = _paymentMethods;
    if (value == null) return null;
    if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final P2POfferFlagModel? flag;
  final List<P2PTradeModel>? _trades;
  @override
  List<P2PTradeModel>? get trades {
    final value = _trades;
    if (value == null) return null;
    if (_trades is EqualUnmodifiableListView) return _trades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'P2POfferModel(id: $id, userId: $userId, type: $type, currency: $currency, walletType: $walletType, amountConfig: $amountConfig, priceConfig: $priceConfig, tradeSettings: $tradeSettings, locationSettings: $locationSettings, userRequirements: $userRequirements, status: $status, views: $views, systemTags: $systemTags, adminNotes: $adminNotes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, user: $user, paymentMethods: $paymentMethods, flag: $flag, trades: $trades)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2POfferModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.walletType, walletType) ||
                other.walletType == walletType) &&
            const DeepCollectionEquality()
                .equals(other._amountConfig, _amountConfig) &&
            const DeepCollectionEquality()
                .equals(other._priceConfig, _priceConfig) &&
            const DeepCollectionEquality()
                .equals(other._tradeSettings, _tradeSettings) &&
            const DeepCollectionEquality()
                .equals(other._locationSettings, _locationSettings) &&
            const DeepCollectionEquality()
                .equals(other._userRequirements, _userRequirements) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.views, views) || other.views == views) &&
            const DeepCollectionEquality()
                .equals(other._systemTags, _systemTags) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality()
                .equals(other._paymentMethods, _paymentMethods) &&
            (identical(other.flag, flag) || other.flag == flag) &&
            const DeepCollectionEquality().equals(other._trades, _trades));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        type,
        currency,
        walletType,
        const DeepCollectionEquality().hash(_amountConfig),
        const DeepCollectionEquality().hash(_priceConfig),
        const DeepCollectionEquality().hash(_tradeSettings),
        const DeepCollectionEquality().hash(_locationSettings),
        const DeepCollectionEquality().hash(_userRequirements),
        status,
        views,
        const DeepCollectionEquality().hash(_systemTags),
        adminNotes,
        createdAt,
        updatedAt,
        deletedAt,
        user,
        const DeepCollectionEquality().hash(_paymentMethods),
        flag,
        const DeepCollectionEquality().hash(_trades)
      ]);

  /// Create a copy of P2POfferModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2POfferModelImplCopyWith<_$P2POfferModelImpl> get copyWith =>
      __$$P2POfferModelImplCopyWithImpl<_$P2POfferModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2POfferModelImplToJson(
      this,
    );
  }
}

abstract class _P2POfferModel implements P2POfferModel {
  const factory _P2POfferModel(
      {required final String id,
      required final String userId,
      required final String type,
      required final String currency,
      required final String walletType,
      required final Map<String, dynamic> amountConfig,
      required final Map<String, dynamic> priceConfig,
      required final Map<String, dynamic> tradeSettings,
      final Map<String, dynamic>? locationSettings,
      final Map<String, dynamic>? userRequirements,
      required final String status,
      required final int views,
      final List<String>? systemTags,
      final String? adminNotes,
      required final String createdAt,
      required final String updatedAt,
      final String? deletedAt,
      final P2PUserModel? user,
      final List<P2PPaymentMethodModel>? paymentMethods,
      final P2POfferFlagModel? flag,
      final List<P2PTradeModel>? trades}) = _$P2POfferModelImpl;

  factory _P2POfferModel.fromJson(Map<String, dynamic> json) =
      _$P2POfferModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get type;
  @override
  String get currency;
  @override
  String get walletType;
  @override
  Map<String, dynamic> get amountConfig;
  @override
  Map<String, dynamic> get priceConfig;
  @override
  Map<String, dynamic> get tradeSettings;
  @override
  Map<String, dynamic>? get locationSettings;
  @override
  Map<String, dynamic>? get userRequirements;
  @override
  String get status;
  @override
  int get views;
  @override
  List<String>? get systemTags;
  @override
  String? get adminNotes;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  String? get deletedAt; // Associated models
  @override
  P2PUserModel? get user;
  @override
  List<P2PPaymentMethodModel>? get paymentMethods;
  @override
  P2POfferFlagModel? get flag;
  @override
  List<P2PTradeModel>? get trades;

  /// Create a copy of P2POfferModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2POfferModelImplCopyWith<_$P2POfferModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

P2POfferFlagModel _$P2POfferFlagModelFromJson(Map<String, dynamic> json) {
  return _P2POfferFlagModel.fromJson(json);
}

/// @nodoc
mixin _$P2POfferFlagModel {
  String get id => throw _privateConstructorUsedError;
  String get offerId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this P2POfferFlagModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2POfferFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2POfferFlagModelCopyWith<P2POfferFlagModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2POfferFlagModelCopyWith<$Res> {
  factory $P2POfferFlagModelCopyWith(
          P2POfferFlagModel value, $Res Function(P2POfferFlagModel) then) =
      _$P2POfferFlagModelCopyWithImpl<$Res, P2POfferFlagModel>;
  @useResult
  $Res call(
      {String id,
      String offerId,
      String userId,
      String? reason,
      String? description,
      String? status,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class _$P2POfferFlagModelCopyWithImpl<$Res, $Val extends P2POfferFlagModel>
    implements $P2POfferFlagModelCopyWith<$Res> {
  _$P2POfferFlagModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2POfferFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? offerId = null,
    Object? userId = null,
    Object? reason = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      offerId: null == offerId
          ? _value.offerId
          : offerId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2POfferFlagModelImplCopyWith<$Res>
    implements $P2POfferFlagModelCopyWith<$Res> {
  factory _$$P2POfferFlagModelImplCopyWith(_$P2POfferFlagModelImpl value,
          $Res Function(_$P2POfferFlagModelImpl) then) =
      __$$P2POfferFlagModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String offerId,
      String userId,
      String? reason,
      String? description,
      String? status,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class __$$P2POfferFlagModelImplCopyWithImpl<$Res>
    extends _$P2POfferFlagModelCopyWithImpl<$Res, _$P2POfferFlagModelImpl>
    implements _$$P2POfferFlagModelImplCopyWith<$Res> {
  __$$P2POfferFlagModelImplCopyWithImpl(_$P2POfferFlagModelImpl _value,
      $Res Function(_$P2POfferFlagModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2POfferFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? offerId = null,
    Object? userId = null,
    Object? reason = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$P2POfferFlagModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      offerId: null == offerId
          ? _value.offerId
          : offerId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2POfferFlagModelImpl implements _P2POfferFlagModel {
  const _$P2POfferFlagModelImpl(
      {required this.id,
      required this.offerId,
      required this.userId,
      this.reason,
      this.description,
      this.status,
      this.createdAt,
      this.updatedAt});

  factory _$P2POfferFlagModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2POfferFlagModelImplFromJson(json);

  @override
  final String id;
  @override
  final String offerId;
  @override
  final String userId;
  @override
  final String? reason;
  @override
  final String? description;
  @override
  final String? status;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'P2POfferFlagModel(id: $id, offerId: $offerId, userId: $userId, reason: $reason, description: $description, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2POfferFlagModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.offerId, offerId) || other.offerId == offerId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, offerId, userId, reason,
      description, status, createdAt, updatedAt);

  /// Create a copy of P2POfferFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2POfferFlagModelImplCopyWith<_$P2POfferFlagModelImpl> get copyWith =>
      __$$P2POfferFlagModelImplCopyWithImpl<_$P2POfferFlagModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2POfferFlagModelImplToJson(
      this,
    );
  }
}

abstract class _P2POfferFlagModel implements P2POfferFlagModel {
  const factory _P2POfferFlagModel(
      {required final String id,
      required final String offerId,
      required final String userId,
      final String? reason,
      final String? description,
      final String? status,
      final String? createdAt,
      final String? updatedAt}) = _$P2POfferFlagModelImpl;

  factory _P2POfferFlagModel.fromJson(Map<String, dynamic> json) =
      _$P2POfferFlagModelImpl.fromJson;

  @override
  String get id;
  @override
  String get offerId;
  @override
  String get userId;
  @override
  String? get reason;
  @override
  String? get description;
  @override
  String? get status;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of P2POfferFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2POfferFlagModelImplCopyWith<_$P2POfferFlagModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
