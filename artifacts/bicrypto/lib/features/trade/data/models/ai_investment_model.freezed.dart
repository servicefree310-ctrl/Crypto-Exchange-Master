// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_investment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiInvestmentModel _$AiInvestmentModelFromJson(Map<String, dynamic> json) {
  return _AiInvestmentModel.fromJson(json);
}

/// @nodoc
mixin _$AiInvestmentModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  String get durationId => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get profit => throw _privateConstructorUsedError;
  String get result => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  double? get profitPercentage => throw _privateConstructorUsedError;
  String? get durationText =>
      throw _privateConstructorUsedError; // Include related data for API response parsing
  Map<String, dynamic>? get plan => throw _privateConstructorUsedError;
  Map<String, dynamic>? get duration => throw _privateConstructorUsedError;

  /// Serializes this AiInvestmentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiInvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiInvestmentModelCopyWith<AiInvestmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiInvestmentModelCopyWith<$Res> {
  factory $AiInvestmentModelCopyWith(
          AiInvestmentModel value, $Res Function(AiInvestmentModel) then) =
      _$AiInvestmentModelCopyWithImpl<$Res, AiInvestmentModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String planId,
      String durationId,
      String symbol,
      double amount,
      double profit,
      String result,
      String status,
      String type,
      DateTime createdAt,
      DateTime? endedAt,
      double? profitPercentage,
      String? durationText,
      Map<String, dynamic>? plan,
      Map<String, dynamic>? duration});
}

/// @nodoc
class _$AiInvestmentModelCopyWithImpl<$Res, $Val extends AiInvestmentModel>
    implements $AiInvestmentModelCopyWith<$Res> {
  _$AiInvestmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiInvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? planId = null,
    Object? durationId = null,
    Object? symbol = null,
    Object? amount = null,
    Object? profit = null,
    Object? result = null,
    Object? status = null,
    Object? type = null,
    Object? createdAt = null,
    Object? endedAt = freezed,
    Object? profitPercentage = freezed,
    Object? durationText = freezed,
    Object? plan = freezed,
    Object? duration = freezed,
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
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      durationId: null == durationId
          ? _value.durationId
          : durationId // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      profit: null == profit
          ? _value.profit
          : profit // ignore: cast_nullable_to_non_nullable
              as double,
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      profitPercentage: freezed == profitPercentage
          ? _value.profitPercentage
          : profitPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      durationText: freezed == durationText
          ? _value.durationText
          : durationText // ignore: cast_nullable_to_non_nullable
              as String?,
      plan: freezed == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiInvestmentModelImplCopyWith<$Res>
    implements $AiInvestmentModelCopyWith<$Res> {
  factory _$$AiInvestmentModelImplCopyWith(_$AiInvestmentModelImpl value,
          $Res Function(_$AiInvestmentModelImpl) then) =
      __$$AiInvestmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String planId,
      String durationId,
      String symbol,
      double amount,
      double profit,
      String result,
      String status,
      String type,
      DateTime createdAt,
      DateTime? endedAt,
      double? profitPercentage,
      String? durationText,
      Map<String, dynamic>? plan,
      Map<String, dynamic>? duration});
}

/// @nodoc
class __$$AiInvestmentModelImplCopyWithImpl<$Res>
    extends _$AiInvestmentModelCopyWithImpl<$Res, _$AiInvestmentModelImpl>
    implements _$$AiInvestmentModelImplCopyWith<$Res> {
  __$$AiInvestmentModelImplCopyWithImpl(_$AiInvestmentModelImpl _value,
      $Res Function(_$AiInvestmentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiInvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? planId = null,
    Object? durationId = null,
    Object? symbol = null,
    Object? amount = null,
    Object? profit = null,
    Object? result = null,
    Object? status = null,
    Object? type = null,
    Object? createdAt = null,
    Object? endedAt = freezed,
    Object? profitPercentage = freezed,
    Object? durationText = freezed,
    Object? plan = freezed,
    Object? duration = freezed,
  }) {
    return _then(_$AiInvestmentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      durationId: null == durationId
          ? _value.durationId
          : durationId // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      profit: null == profit
          ? _value.profit
          : profit // ignore: cast_nullable_to_non_nullable
              as double,
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      profitPercentage: freezed == profitPercentage
          ? _value.profitPercentage
          : profitPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      durationText: freezed == durationText
          ? _value.durationText
          : durationText // ignore: cast_nullable_to_non_nullable
              as String?,
      plan: freezed == plan
          ? _value._plan
          : plan // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      duration: freezed == duration
          ? _value._duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiInvestmentModelImpl implements _AiInvestmentModel {
  const _$AiInvestmentModelImpl(
      {required this.id,
      required this.userId,
      required this.planId,
      required this.durationId,
      required this.symbol,
      required this.amount,
      required this.profit,
      required this.result,
      required this.status,
      required this.type,
      required this.createdAt,
      this.endedAt,
      this.profitPercentage,
      this.durationText,
      final Map<String, dynamic>? plan,
      final Map<String, dynamic>? duration})
      : _plan = plan,
        _duration = duration;

  factory _$AiInvestmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiInvestmentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String planId;
  @override
  final String durationId;
  @override
  final String symbol;
  @override
  final double amount;
  @override
  final double profit;
  @override
  final String result;
  @override
  final String status;
  @override
  final String type;
  @override
  final DateTime createdAt;
  @override
  final DateTime? endedAt;
  @override
  final double? profitPercentage;
  @override
  final String? durationText;
// Include related data for API response parsing
  final Map<String, dynamic>? _plan;
// Include related data for API response parsing
  @override
  Map<String, dynamic>? get plan {
    final value = _plan;
    if (value == null) return null;
    if (_plan is EqualUnmodifiableMapView) return _plan;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _duration;
  @override
  Map<String, dynamic>? get duration {
    final value = _duration;
    if (value == null) return null;
    if (_duration is EqualUnmodifiableMapView) return _duration;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AiInvestmentModel(id: $id, userId: $userId, planId: $planId, durationId: $durationId, symbol: $symbol, amount: $amount, profit: $profit, result: $result, status: $status, type: $type, createdAt: $createdAt, endedAt: $endedAt, profitPercentage: $profitPercentage, durationText: $durationText, plan: $plan, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiInvestmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.durationId, durationId) ||
                other.durationId == durationId) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.profit, profit) || other.profit == profit) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.profitPercentage, profitPercentage) ||
                other.profitPercentage == profitPercentage) &&
            (identical(other.durationText, durationText) ||
                other.durationText == durationText) &&
            const DeepCollectionEquality().equals(other._plan, _plan) &&
            const DeepCollectionEquality().equals(other._duration, _duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      planId,
      durationId,
      symbol,
      amount,
      profit,
      result,
      status,
      type,
      createdAt,
      endedAt,
      profitPercentage,
      durationText,
      const DeepCollectionEquality().hash(_plan),
      const DeepCollectionEquality().hash(_duration));

  /// Create a copy of AiInvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiInvestmentModelImplCopyWith<_$AiInvestmentModelImpl> get copyWith =>
      __$$AiInvestmentModelImplCopyWithImpl<_$AiInvestmentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiInvestmentModelImplToJson(
      this,
    );
  }
}

abstract class _AiInvestmentModel implements AiInvestmentModel {
  const factory _AiInvestmentModel(
      {required final String id,
      required final String userId,
      required final String planId,
      required final String durationId,
      required final String symbol,
      required final double amount,
      required final double profit,
      required final String result,
      required final String status,
      required final String type,
      required final DateTime createdAt,
      final DateTime? endedAt,
      final double? profitPercentage,
      final String? durationText,
      final Map<String, dynamic>? plan,
      final Map<String, dynamic>? duration}) = _$AiInvestmentModelImpl;

  factory _AiInvestmentModel.fromJson(Map<String, dynamic> json) =
      _$AiInvestmentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get planId;
  @override
  String get durationId;
  @override
  String get symbol;
  @override
  double get amount;
  @override
  double get profit;
  @override
  String get result;
  @override
  String get status;
  @override
  String get type;
  @override
  DateTime get createdAt;
  @override
  DateTime? get endedAt;
  @override
  double? get profitPercentage;
  @override
  String? get durationText; // Include related data for API response parsing
  @override
  Map<String, dynamic>? get plan;
  @override
  Map<String, dynamic>? get duration;

  /// Create a copy of AiInvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiInvestmentModelImplCopyWith<_$AiInvestmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
