// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staking_pool_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StakingPoolModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  double get apr => throw _privateConstructorUsedError;
  double get minStake => throw _privateConstructorUsedError;
  double? get maxStake => throw _privateConstructorUsedError;
  int get lockPeriod => throw _privateConstructorUsedError; // in days
  double get availableToStake => throw _privateConstructorUsedError;
  double get totalStaked => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get poolType => throw _privateConstructorUsedError;
  bool get isPromoted => throw _privateConstructorUsedError;
  bool get autoCompound => throw _privateConstructorUsedError;
  int? get maxPositionsPerUser => throw _privateConstructorUsedError;
  double? get earlyWithdrawalPenalty => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Analytics data (optional, populated in some endpoints)
  @JsonKey(name: 'tvl')
  double? get totalValueLocked => throw _privateConstructorUsedError;
  int? get totalUsers => throw _privateConstructorUsedError;
  double? get totalRewardsDistributed =>
      throw _privateConstructorUsedError; // User specific data (optional)
  double? get userStaked => throw _privateConstructorUsedError;
  int? get userPositionCount => throw _privateConstructorUsedError;

  /// Create a copy of StakingPoolModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StakingPoolModelCopyWith<StakingPoolModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StakingPoolModelCopyWith<$Res> {
  factory $StakingPoolModelCopyWith(
          StakingPoolModel value, $Res Function(StakingPoolModel) then) =
      _$StakingPoolModelCopyWithImpl<$Res, StakingPoolModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? icon,
      String symbol,
      double apr,
      double minStake,
      double? maxStake,
      int lockPeriod,
      double availableToStake,
      double totalStaked,
      String status,
      String poolType,
      bool isPromoted,
      bool autoCompound,
      int? maxPositionsPerUser,
      double? earlyWithdrawalPenalty,
      int order,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(name: 'tvl') double? totalValueLocked,
      int? totalUsers,
      double? totalRewardsDistributed,
      double? userStaked,
      int? userPositionCount});
}

/// @nodoc
class _$StakingPoolModelCopyWithImpl<$Res, $Val extends StakingPoolModel>
    implements $StakingPoolModelCopyWith<$Res> {
  _$StakingPoolModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StakingPoolModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? symbol = null,
    Object? apr = null,
    Object? minStake = null,
    Object? maxStake = freezed,
    Object? lockPeriod = null,
    Object? availableToStake = null,
    Object? totalStaked = null,
    Object? status = null,
    Object? poolType = null,
    Object? isPromoted = null,
    Object? autoCompound = null,
    Object? maxPositionsPerUser = freezed,
    Object? earlyWithdrawalPenalty = freezed,
    Object? order = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? totalValueLocked = freezed,
    Object? totalUsers = freezed,
    Object? totalRewardsDistributed = freezed,
    Object? userStaked = freezed,
    Object? userPositionCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      apr: null == apr
          ? _value.apr
          : apr // ignore: cast_nullable_to_non_nullable
              as double,
      minStake: null == minStake
          ? _value.minStake
          : minStake // ignore: cast_nullable_to_non_nullable
              as double,
      maxStake: freezed == maxStake
          ? _value.maxStake
          : maxStake // ignore: cast_nullable_to_non_nullable
              as double?,
      lockPeriod: null == lockPeriod
          ? _value.lockPeriod
          : lockPeriod // ignore: cast_nullable_to_non_nullable
              as int,
      availableToStake: null == availableToStake
          ? _value.availableToStake
          : availableToStake // ignore: cast_nullable_to_non_nullable
              as double,
      totalStaked: null == totalStaked
          ? _value.totalStaked
          : totalStaked // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      poolType: null == poolType
          ? _value.poolType
          : poolType // ignore: cast_nullable_to_non_nullable
              as String,
      isPromoted: null == isPromoted
          ? _value.isPromoted
          : isPromoted // ignore: cast_nullable_to_non_nullable
              as bool,
      autoCompound: null == autoCompound
          ? _value.autoCompound
          : autoCompound // ignore: cast_nullable_to_non_nullable
              as bool,
      maxPositionsPerUser: freezed == maxPositionsPerUser
          ? _value.maxPositionsPerUser
          : maxPositionsPerUser // ignore: cast_nullable_to_non_nullable
              as int?,
      earlyWithdrawalPenalty: freezed == earlyWithdrawalPenalty
          ? _value.earlyWithdrawalPenalty
          : earlyWithdrawalPenalty // ignore: cast_nullable_to_non_nullable
              as double?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalValueLocked: freezed == totalValueLocked
          ? _value.totalValueLocked
          : totalValueLocked // ignore: cast_nullable_to_non_nullable
              as double?,
      totalUsers: freezed == totalUsers
          ? _value.totalUsers
          : totalUsers // ignore: cast_nullable_to_non_nullable
              as int?,
      totalRewardsDistributed: freezed == totalRewardsDistributed
          ? _value.totalRewardsDistributed
          : totalRewardsDistributed // ignore: cast_nullable_to_non_nullable
              as double?,
      userStaked: freezed == userStaked
          ? _value.userStaked
          : userStaked // ignore: cast_nullable_to_non_nullable
              as double?,
      userPositionCount: freezed == userPositionCount
          ? _value.userPositionCount
          : userPositionCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StakingPoolModelImplCopyWith<$Res>
    implements $StakingPoolModelCopyWith<$Res> {
  factory _$$StakingPoolModelImplCopyWith(_$StakingPoolModelImpl value,
          $Res Function(_$StakingPoolModelImpl) then) =
      __$$StakingPoolModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? icon,
      String symbol,
      double apr,
      double minStake,
      double? maxStake,
      int lockPeriod,
      double availableToStake,
      double totalStaked,
      String status,
      String poolType,
      bool isPromoted,
      bool autoCompound,
      int? maxPositionsPerUser,
      double? earlyWithdrawalPenalty,
      int order,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(name: 'tvl') double? totalValueLocked,
      int? totalUsers,
      double? totalRewardsDistributed,
      double? userStaked,
      int? userPositionCount});
}

/// @nodoc
class __$$StakingPoolModelImplCopyWithImpl<$Res>
    extends _$StakingPoolModelCopyWithImpl<$Res, _$StakingPoolModelImpl>
    implements _$$StakingPoolModelImplCopyWith<$Res> {
  __$$StakingPoolModelImplCopyWithImpl(_$StakingPoolModelImpl _value,
      $Res Function(_$StakingPoolModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of StakingPoolModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? symbol = null,
    Object? apr = null,
    Object? minStake = null,
    Object? maxStake = freezed,
    Object? lockPeriod = null,
    Object? availableToStake = null,
    Object? totalStaked = null,
    Object? status = null,
    Object? poolType = null,
    Object? isPromoted = null,
    Object? autoCompound = null,
    Object? maxPositionsPerUser = freezed,
    Object? earlyWithdrawalPenalty = freezed,
    Object? order = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? totalValueLocked = freezed,
    Object? totalUsers = freezed,
    Object? totalRewardsDistributed = freezed,
    Object? userStaked = freezed,
    Object? userPositionCount = freezed,
  }) {
    return _then(_$StakingPoolModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      apr: null == apr
          ? _value.apr
          : apr // ignore: cast_nullable_to_non_nullable
              as double,
      minStake: null == minStake
          ? _value.minStake
          : minStake // ignore: cast_nullable_to_non_nullable
              as double,
      maxStake: freezed == maxStake
          ? _value.maxStake
          : maxStake // ignore: cast_nullable_to_non_nullable
              as double?,
      lockPeriod: null == lockPeriod
          ? _value.lockPeriod
          : lockPeriod // ignore: cast_nullable_to_non_nullable
              as int,
      availableToStake: null == availableToStake
          ? _value.availableToStake
          : availableToStake // ignore: cast_nullable_to_non_nullable
              as double,
      totalStaked: null == totalStaked
          ? _value.totalStaked
          : totalStaked // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      poolType: null == poolType
          ? _value.poolType
          : poolType // ignore: cast_nullable_to_non_nullable
              as String,
      isPromoted: null == isPromoted
          ? _value.isPromoted
          : isPromoted // ignore: cast_nullable_to_non_nullable
              as bool,
      autoCompound: null == autoCompound
          ? _value.autoCompound
          : autoCompound // ignore: cast_nullable_to_non_nullable
              as bool,
      maxPositionsPerUser: freezed == maxPositionsPerUser
          ? _value.maxPositionsPerUser
          : maxPositionsPerUser // ignore: cast_nullable_to_non_nullable
              as int?,
      earlyWithdrawalPenalty: freezed == earlyWithdrawalPenalty
          ? _value.earlyWithdrawalPenalty
          : earlyWithdrawalPenalty // ignore: cast_nullable_to_non_nullable
              as double?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalValueLocked: freezed == totalValueLocked
          ? _value.totalValueLocked
          : totalValueLocked // ignore: cast_nullable_to_non_nullable
              as double?,
      totalUsers: freezed == totalUsers
          ? _value.totalUsers
          : totalUsers // ignore: cast_nullable_to_non_nullable
              as int?,
      totalRewardsDistributed: freezed == totalRewardsDistributed
          ? _value.totalRewardsDistributed
          : totalRewardsDistributed // ignore: cast_nullable_to_non_nullable
              as double?,
      userStaked: freezed == userStaked
          ? _value.userStaked
          : userStaked // ignore: cast_nullable_to_non_nullable
              as double?,
      userPositionCount: freezed == userPositionCount
          ? _value.userPositionCount
          : userPositionCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$StakingPoolModelImpl implements _StakingPoolModel {
  const _$StakingPoolModelImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.icon,
      required this.symbol,
      required this.apr,
      required this.minStake,
      required this.maxStake,
      required this.lockPeriod,
      required this.availableToStake,
      required this.totalStaked,
      required this.status,
      required this.poolType,
      this.isPromoted = false,
      this.autoCompound = false,
      this.maxPositionsPerUser,
      this.earlyWithdrawalPenalty,
      this.order = 0,
      this.createdAt,
      this.updatedAt,
      @JsonKey(name: 'tvl') this.totalValueLocked,
      this.totalUsers,
      this.totalRewardsDistributed,
      this.userStaked,
      this.userPositionCount});

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  final String symbol;
  @override
  final double apr;
  @override
  final double minStake;
  @override
  final double? maxStake;
  @override
  final int lockPeriod;
// in days
  @override
  final double availableToStake;
  @override
  final double totalStaked;
  @override
  final String status;
  @override
  final String poolType;
  @override
  @JsonKey()
  final bool isPromoted;
  @override
  @JsonKey()
  final bool autoCompound;
  @override
  final int? maxPositionsPerUser;
  @override
  final double? earlyWithdrawalPenalty;
  @override
  @JsonKey()
  final int order;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// Analytics data (optional, populated in some endpoints)
  @override
  @JsonKey(name: 'tvl')
  final double? totalValueLocked;
  @override
  final int? totalUsers;
  @override
  final double? totalRewardsDistributed;
// User specific data (optional)
  @override
  final double? userStaked;
  @override
  final int? userPositionCount;

  @override
  String toString() {
    return 'StakingPoolModel(id: $id, name: $name, description: $description, icon: $icon, symbol: $symbol, apr: $apr, minStake: $minStake, maxStake: $maxStake, lockPeriod: $lockPeriod, availableToStake: $availableToStake, totalStaked: $totalStaked, status: $status, poolType: $poolType, isPromoted: $isPromoted, autoCompound: $autoCompound, maxPositionsPerUser: $maxPositionsPerUser, earlyWithdrawalPenalty: $earlyWithdrawalPenalty, order: $order, createdAt: $createdAt, updatedAt: $updatedAt, totalValueLocked: $totalValueLocked, totalUsers: $totalUsers, totalRewardsDistributed: $totalRewardsDistributed, userStaked: $userStaked, userPositionCount: $userPositionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StakingPoolModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.apr, apr) || other.apr == apr) &&
            (identical(other.minStake, minStake) ||
                other.minStake == minStake) &&
            (identical(other.maxStake, maxStake) ||
                other.maxStake == maxStake) &&
            (identical(other.lockPeriod, lockPeriod) ||
                other.lockPeriod == lockPeriod) &&
            (identical(other.availableToStake, availableToStake) ||
                other.availableToStake == availableToStake) &&
            (identical(other.totalStaked, totalStaked) ||
                other.totalStaked == totalStaked) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.poolType, poolType) ||
                other.poolType == poolType) &&
            (identical(other.isPromoted, isPromoted) ||
                other.isPromoted == isPromoted) &&
            (identical(other.autoCompound, autoCompound) ||
                other.autoCompound == autoCompound) &&
            (identical(other.maxPositionsPerUser, maxPositionsPerUser) ||
                other.maxPositionsPerUser == maxPositionsPerUser) &&
            (identical(other.earlyWithdrawalPenalty, earlyWithdrawalPenalty) ||
                other.earlyWithdrawalPenalty == earlyWithdrawalPenalty) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.totalValueLocked, totalValueLocked) ||
                other.totalValueLocked == totalValueLocked) &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers) &&
            (identical(
                    other.totalRewardsDistributed, totalRewardsDistributed) ||
                other.totalRewardsDistributed == totalRewardsDistributed) &&
            (identical(other.userStaked, userStaked) ||
                other.userStaked == userStaked) &&
            (identical(other.userPositionCount, userPositionCount) ||
                other.userPositionCount == userPositionCount));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        icon,
        symbol,
        apr,
        minStake,
        maxStake,
        lockPeriod,
        availableToStake,
        totalStaked,
        status,
        poolType,
        isPromoted,
        autoCompound,
        maxPositionsPerUser,
        earlyWithdrawalPenalty,
        order,
        createdAt,
        updatedAt,
        totalValueLocked,
        totalUsers,
        totalRewardsDistributed,
        userStaked,
        userPositionCount
      ]);

  /// Create a copy of StakingPoolModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StakingPoolModelImplCopyWith<_$StakingPoolModelImpl> get copyWith =>
      __$$StakingPoolModelImplCopyWithImpl<_$StakingPoolModelImpl>(
          this, _$identity);
}

abstract class _StakingPoolModel implements StakingPoolModel {
  const factory _StakingPoolModel(
      {required final String id,
      required final String name,
      required final String? description,
      required final String? icon,
      required final String symbol,
      required final double apr,
      required final double minStake,
      required final double? maxStake,
      required final int lockPeriod,
      required final double availableToStake,
      required final double totalStaked,
      required final String status,
      required final String poolType,
      final bool isPromoted,
      final bool autoCompound,
      final int? maxPositionsPerUser,
      final double? earlyWithdrawalPenalty,
      final int order,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      @JsonKey(name: 'tvl') final double? totalValueLocked,
      final int? totalUsers,
      final double? totalRewardsDistributed,
      final double? userStaked,
      final int? userPositionCount}) = _$StakingPoolModelImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get icon;
  @override
  String get symbol;
  @override
  double get apr;
  @override
  double get minStake;
  @override
  double? get maxStake;
  @override
  int get lockPeriod; // in days
  @override
  double get availableToStake;
  @override
  double get totalStaked;
  @override
  String get status;
  @override
  String get poolType;
  @override
  bool get isPromoted;
  @override
  bool get autoCompound;
  @override
  int? get maxPositionsPerUser;
  @override
  double? get earlyWithdrawalPenalty;
  @override
  int get order;
  @override
  DateTime? get createdAt;
  @override
  DateTime?
      get updatedAt; // Analytics data (optional, populated in some endpoints)
  @override
  @JsonKey(name: 'tvl')
  double? get totalValueLocked;
  @override
  int? get totalUsers;
  @override
  double? get totalRewardsDistributed; // User specific data (optional)
  @override
  double? get userStaked;
  @override
  int? get userPositionCount;

  /// Create a copy of StakingPoolModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StakingPoolModelImplCopyWith<_$StakingPoolModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
