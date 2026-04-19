// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_investment_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiInvestmentPlanModel _$AiInvestmentPlanModelFromJson(
    Map<String, dynamic> json) {
  return _AiInvestmentPlanModel.fromJson(json);
}

/// @nodoc
mixin _$AiInvestmentPlanModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  double get minAmount => throw _privateConstructorUsedError;
  double get maxAmount => throw _privateConstructorUsedError;
  double get profitPercentage => throw _privateConstructorUsedError;
  double get invested => throw _privateConstructorUsedError;
  bool? get trending => throw _privateConstructorUsedError;
  bool? get status => throw _privateConstructorUsedError;
  List<AiInvestmentDurationModel>? get durations =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AiInvestmentPlanModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiInvestmentPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiInvestmentPlanModelCopyWith<AiInvestmentPlanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiInvestmentPlanModelCopyWith<$Res> {
  factory $AiInvestmentPlanModelCopyWith(AiInvestmentPlanModel value,
          $Res Function(AiInvestmentPlanModel) then) =
      _$AiInvestmentPlanModelCopyWithImpl<$Res, AiInvestmentPlanModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String? image,
      double minAmount,
      double maxAmount,
      double profitPercentage,
      double invested,
      bool? trending,
      bool? status,
      List<AiInvestmentDurationModel>? durations,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$AiInvestmentPlanModelCopyWithImpl<$Res,
        $Val extends AiInvestmentPlanModel>
    implements $AiInvestmentPlanModelCopyWith<$Res> {
  _$AiInvestmentPlanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiInvestmentPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? image = freezed,
    Object? minAmount = null,
    Object? maxAmount = null,
    Object? profitPercentage = null,
    Object? invested = null,
    Object? trending = freezed,
    Object? status = freezed,
    Object? durations = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      minAmount: null == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double,
      maxAmount: null == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      profitPercentage: null == profitPercentage
          ? _value.profitPercentage
          : profitPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      invested: null == invested
          ? _value.invested
          : invested // ignore: cast_nullable_to_non_nullable
              as double,
      trending: freezed == trending
          ? _value.trending
          : trending // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool?,
      durations: freezed == durations
          ? _value.durations
          : durations // ignore: cast_nullable_to_non_nullable
              as List<AiInvestmentDurationModel>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiInvestmentPlanModelImplCopyWith<$Res>
    implements $AiInvestmentPlanModelCopyWith<$Res> {
  factory _$$AiInvestmentPlanModelImplCopyWith(
          _$AiInvestmentPlanModelImpl value,
          $Res Function(_$AiInvestmentPlanModelImpl) then) =
      __$$AiInvestmentPlanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String? image,
      double minAmount,
      double maxAmount,
      double profitPercentage,
      double invested,
      bool? trending,
      bool? status,
      List<AiInvestmentDurationModel>? durations,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$AiInvestmentPlanModelImplCopyWithImpl<$Res>
    extends _$AiInvestmentPlanModelCopyWithImpl<$Res,
        _$AiInvestmentPlanModelImpl>
    implements _$$AiInvestmentPlanModelImplCopyWith<$Res> {
  __$$AiInvestmentPlanModelImplCopyWithImpl(_$AiInvestmentPlanModelImpl _value,
      $Res Function(_$AiInvestmentPlanModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiInvestmentPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? image = freezed,
    Object? minAmount = null,
    Object? maxAmount = null,
    Object? profitPercentage = null,
    Object? invested = null,
    Object? trending = freezed,
    Object? status = freezed,
    Object? durations = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AiInvestmentPlanModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      minAmount: null == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double,
      maxAmount: null == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      profitPercentage: null == profitPercentage
          ? _value.profitPercentage
          : profitPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      invested: null == invested
          ? _value.invested
          : invested // ignore: cast_nullable_to_non_nullable
              as double,
      trending: freezed == trending
          ? _value.trending
          : trending // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool?,
      durations: freezed == durations
          ? _value._durations
          : durations // ignore: cast_nullable_to_non_nullable
              as List<AiInvestmentDurationModel>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiInvestmentPlanModelImpl implements _AiInvestmentPlanModel {
  const _$AiInvestmentPlanModelImpl(
      {required this.id,
      required this.title,
      this.description,
      this.image,
      required this.minAmount,
      required this.maxAmount,
      required this.profitPercentage,
      required this.invested,
      this.trending,
      this.status,
      final List<AiInvestmentDurationModel>? durations,
      this.createdAt,
      this.updatedAt})
      : _durations = durations;

  factory _$AiInvestmentPlanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiInvestmentPlanModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? image;
  @override
  final double minAmount;
  @override
  final double maxAmount;
  @override
  final double profitPercentage;
  @override
  final double invested;
  @override
  final bool? trending;
  @override
  final bool? status;
  final List<AiInvestmentDurationModel>? _durations;
  @override
  List<AiInvestmentDurationModel>? get durations {
    final value = _durations;
    if (value == null) return null;
    if (_durations is EqualUnmodifiableListView) return _durations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AiInvestmentPlanModel(id: $id, title: $title, description: $description, image: $image, minAmount: $minAmount, maxAmount: $maxAmount, profitPercentage: $profitPercentage, invested: $invested, trending: $trending, status: $status, durations: $durations, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiInvestmentPlanModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.minAmount, minAmount) ||
                other.minAmount == minAmount) &&
            (identical(other.maxAmount, maxAmount) ||
                other.maxAmount == maxAmount) &&
            (identical(other.profitPercentage, profitPercentage) ||
                other.profitPercentage == profitPercentage) &&
            (identical(other.invested, invested) ||
                other.invested == invested) &&
            (identical(other.trending, trending) ||
                other.trending == trending) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._durations, _durations) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      image,
      minAmount,
      maxAmount,
      profitPercentage,
      invested,
      trending,
      status,
      const DeepCollectionEquality().hash(_durations),
      createdAt,
      updatedAt);

  /// Create a copy of AiInvestmentPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiInvestmentPlanModelImplCopyWith<_$AiInvestmentPlanModelImpl>
      get copyWith => __$$AiInvestmentPlanModelImplCopyWithImpl<
          _$AiInvestmentPlanModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiInvestmentPlanModelImplToJson(
      this,
    );
  }
}

abstract class _AiInvestmentPlanModel implements AiInvestmentPlanModel {
  const factory _AiInvestmentPlanModel(
      {required final String id,
      required final String title,
      final String? description,
      final String? image,
      required final double minAmount,
      required final double maxAmount,
      required final double profitPercentage,
      required final double invested,
      final bool? trending,
      final bool? status,
      final List<AiInvestmentDurationModel>? durations,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$AiInvestmentPlanModelImpl;

  factory _AiInvestmentPlanModel.fromJson(Map<String, dynamic> json) =
      _$AiInvestmentPlanModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get image;
  @override
  double get minAmount;
  @override
  double get maxAmount;
  @override
  double get profitPercentage;
  @override
  double get invested;
  @override
  bool? get trending;
  @override
  bool? get status;
  @override
  List<AiInvestmentDurationModel>? get durations;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AiInvestmentPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiInvestmentPlanModelImplCopyWith<_$AiInvestmentPlanModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AiInvestmentDurationModel _$AiInvestmentDurationModelFromJson(
    Map<String, dynamic> json) {
  return _AiInvestmentDurationModel.fromJson(json);
}

/// @nodoc
mixin _$AiInvestmentDurationModel {
  String get id => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get timeframe => throw _privateConstructorUsedError;

  /// Serializes this AiInvestmentDurationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiInvestmentDurationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiInvestmentDurationModelCopyWith<AiInvestmentDurationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiInvestmentDurationModelCopyWith<$Res> {
  factory $AiInvestmentDurationModelCopyWith(AiInvestmentDurationModel value,
          $Res Function(AiInvestmentDurationModel) then) =
      _$AiInvestmentDurationModelCopyWithImpl<$Res, AiInvestmentDurationModel>;
  @useResult
  $Res call({String id, int duration, String timeframe});
}

/// @nodoc
class _$AiInvestmentDurationModelCopyWithImpl<$Res,
        $Val extends AiInvestmentDurationModel>
    implements $AiInvestmentDurationModelCopyWith<$Res> {
  _$AiInvestmentDurationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiInvestmentDurationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? duration = null,
    Object? timeframe = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiInvestmentDurationModelImplCopyWith<$Res>
    implements $AiInvestmentDurationModelCopyWith<$Res> {
  factory _$$AiInvestmentDurationModelImplCopyWith(
          _$AiInvestmentDurationModelImpl value,
          $Res Function(_$AiInvestmentDurationModelImpl) then) =
      __$$AiInvestmentDurationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int duration, String timeframe});
}

/// @nodoc
class __$$AiInvestmentDurationModelImplCopyWithImpl<$Res>
    extends _$AiInvestmentDurationModelCopyWithImpl<$Res,
        _$AiInvestmentDurationModelImpl>
    implements _$$AiInvestmentDurationModelImplCopyWith<$Res> {
  __$$AiInvestmentDurationModelImplCopyWithImpl(
      _$AiInvestmentDurationModelImpl _value,
      $Res Function(_$AiInvestmentDurationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiInvestmentDurationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? duration = null,
    Object? timeframe = null,
  }) {
    return _then(_$AiInvestmentDurationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiInvestmentDurationModelImpl implements _AiInvestmentDurationModel {
  const _$AiInvestmentDurationModelImpl(
      {required this.id, required this.duration, required this.timeframe});

  factory _$AiInvestmentDurationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiInvestmentDurationModelImplFromJson(json);

  @override
  final String id;
  @override
  final int duration;
  @override
  final String timeframe;

  @override
  String toString() {
    return 'AiInvestmentDurationModel(id: $id, duration: $duration, timeframe: $timeframe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiInvestmentDurationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, duration, timeframe);

  /// Create a copy of AiInvestmentDurationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiInvestmentDurationModelImplCopyWith<_$AiInvestmentDurationModelImpl>
      get copyWith => __$$AiInvestmentDurationModelImplCopyWithImpl<
          _$AiInvestmentDurationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiInvestmentDurationModelImplToJson(
      this,
    );
  }
}

abstract class _AiInvestmentDurationModel implements AiInvestmentDurationModel {
  const factory _AiInvestmentDurationModel(
      {required final String id,
      required final int duration,
      required final String timeframe}) = _$AiInvestmentDurationModelImpl;

  factory _AiInvestmentDurationModel.fromJson(Map<String, dynamic> json) =
      _$AiInvestmentDurationModelImpl.fromJson;

  @override
  String get id;
  @override
  int get duration;
  @override
  String get timeframe;

  /// Create a copy of AiInvestmentDurationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiInvestmentDurationModelImplCopyWith<_$AiInvestmentDurationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
