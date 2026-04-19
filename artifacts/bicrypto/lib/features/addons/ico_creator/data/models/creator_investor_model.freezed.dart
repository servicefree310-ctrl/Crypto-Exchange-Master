// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'creator_investor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreatorInvestorModel _$CreatorInvestorModelFromJson(Map<String, dynamic> json) {
  return _CreatorInvestorModel.fromJson(json);
}

/// @nodoc
mixin _$CreatorInvestorModel {
  String get userId => throw _privateConstructorUsedError;
  String get offeringId => throw _privateConstructorUsedError;
  double get totalCost => throw _privateConstructorUsedError;
  double get rejectedCost => throw _privateConstructorUsedError;
  double get totalTokens => throw _privateConstructorUsedError;
  DateTime get lastTransactionDate => throw _privateConstructorUsedError;
  InvestorUserModel get user => throw _privateConstructorUsedError;
  InvestorOfferingModel get offering => throw _privateConstructorUsedError;

  /// Serializes this CreatorInvestorModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreatorInvestorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatorInvestorModelCopyWith<CreatorInvestorModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatorInvestorModelCopyWith<$Res> {
  factory $CreatorInvestorModelCopyWith(CreatorInvestorModel value,
          $Res Function(CreatorInvestorModel) then) =
      _$CreatorInvestorModelCopyWithImpl<$Res, CreatorInvestorModel>;
  @useResult
  $Res call(
      {String userId,
      String offeringId,
      double totalCost,
      double rejectedCost,
      double totalTokens,
      DateTime lastTransactionDate,
      InvestorUserModel user,
      InvestorOfferingModel offering});

  $InvestorUserModelCopyWith<$Res> get user;
  $InvestorOfferingModelCopyWith<$Res> get offering;
}

/// @nodoc
class _$CreatorInvestorModelCopyWithImpl<$Res,
        $Val extends CreatorInvestorModel>
    implements $CreatorInvestorModelCopyWith<$Res> {
  _$CreatorInvestorModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatorInvestorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? offeringId = null,
    Object? totalCost = null,
    Object? rejectedCost = null,
    Object? totalTokens = null,
    Object? lastTransactionDate = null,
    Object? user = null,
    Object? offering = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      offeringId: null == offeringId
          ? _value.offeringId
          : offeringId // ignore: cast_nullable_to_non_nullable
              as String,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      rejectedCost: null == rejectedCost
          ? _value.rejectedCost
          : rejectedCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as double,
      lastTransactionDate: null == lastTransactionDate
          ? _value.lastTransactionDate
          : lastTransactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as InvestorUserModel,
      offering: null == offering
          ? _value.offering
          : offering // ignore: cast_nullable_to_non_nullable
              as InvestorOfferingModel,
    ) as $Val);
  }

  /// Create a copy of CreatorInvestorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InvestorUserModelCopyWith<$Res> get user {
    return $InvestorUserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of CreatorInvestorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InvestorOfferingModelCopyWith<$Res> get offering {
    return $InvestorOfferingModelCopyWith<$Res>(_value.offering, (value) {
      return _then(_value.copyWith(offering: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreatorInvestorModelImplCopyWith<$Res>
    implements $CreatorInvestorModelCopyWith<$Res> {
  factory _$$CreatorInvestorModelImplCopyWith(_$CreatorInvestorModelImpl value,
          $Res Function(_$CreatorInvestorModelImpl) then) =
      __$$CreatorInvestorModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String offeringId,
      double totalCost,
      double rejectedCost,
      double totalTokens,
      DateTime lastTransactionDate,
      InvestorUserModel user,
      InvestorOfferingModel offering});

  @override
  $InvestorUserModelCopyWith<$Res> get user;
  @override
  $InvestorOfferingModelCopyWith<$Res> get offering;
}

/// @nodoc
class __$$CreatorInvestorModelImplCopyWithImpl<$Res>
    extends _$CreatorInvestorModelCopyWithImpl<$Res, _$CreatorInvestorModelImpl>
    implements _$$CreatorInvestorModelImplCopyWith<$Res> {
  __$$CreatorInvestorModelImplCopyWithImpl(_$CreatorInvestorModelImpl _value,
      $Res Function(_$CreatorInvestorModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreatorInvestorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? offeringId = null,
    Object? totalCost = null,
    Object? rejectedCost = null,
    Object? totalTokens = null,
    Object? lastTransactionDate = null,
    Object? user = null,
    Object? offering = null,
  }) {
    return _then(_$CreatorInvestorModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      offeringId: null == offeringId
          ? _value.offeringId
          : offeringId // ignore: cast_nullable_to_non_nullable
              as String,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      rejectedCost: null == rejectedCost
          ? _value.rejectedCost
          : rejectedCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as double,
      lastTransactionDate: null == lastTransactionDate
          ? _value.lastTransactionDate
          : lastTransactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as InvestorUserModel,
      offering: null == offering
          ? _value.offering
          : offering // ignore: cast_nullable_to_non_nullable
              as InvestorOfferingModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatorInvestorModelImpl implements _CreatorInvestorModel {
  const _$CreatorInvestorModelImpl(
      {required this.userId,
      required this.offeringId,
      required this.totalCost,
      required this.rejectedCost,
      required this.totalTokens,
      required this.lastTransactionDate,
      required this.user,
      required this.offering});

  factory _$CreatorInvestorModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatorInvestorModelImplFromJson(json);

  @override
  final String userId;
  @override
  final String offeringId;
  @override
  final double totalCost;
  @override
  final double rejectedCost;
  @override
  final double totalTokens;
  @override
  final DateTime lastTransactionDate;
  @override
  final InvestorUserModel user;
  @override
  final InvestorOfferingModel offering;

  @override
  String toString() {
    return 'CreatorInvestorModel(userId: $userId, offeringId: $offeringId, totalCost: $totalCost, rejectedCost: $rejectedCost, totalTokens: $totalTokens, lastTransactionDate: $lastTransactionDate, user: $user, offering: $offering)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatorInvestorModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.offeringId, offeringId) ||
                other.offeringId == offeringId) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.rejectedCost, rejectedCost) ||
                other.rejectedCost == rejectedCost) &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens) &&
            (identical(other.lastTransactionDate, lastTransactionDate) ||
                other.lastTransactionDate == lastTransactionDate) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.offering, offering) ||
                other.offering == offering));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, offeringId, totalCost,
      rejectedCost, totalTokens, lastTransactionDate, user, offering);

  /// Create a copy of CreatorInvestorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatorInvestorModelImplCopyWith<_$CreatorInvestorModelImpl>
      get copyWith =>
          __$$CreatorInvestorModelImplCopyWithImpl<_$CreatorInvestorModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatorInvestorModelImplToJson(
      this,
    );
  }
}

abstract class _CreatorInvestorModel implements CreatorInvestorModel {
  const factory _CreatorInvestorModel(
          {required final String userId,
          required final String offeringId,
          required final double totalCost,
          required final double rejectedCost,
          required final double totalTokens,
          required final DateTime lastTransactionDate,
          required final InvestorUserModel user,
          required final InvestorOfferingModel offering}) =
      _$CreatorInvestorModelImpl;

  factory _CreatorInvestorModel.fromJson(Map<String, dynamic> json) =
      _$CreatorInvestorModelImpl.fromJson;

  @override
  String get userId;
  @override
  String get offeringId;
  @override
  double get totalCost;
  @override
  double get rejectedCost;
  @override
  double get totalTokens;
  @override
  DateTime get lastTransactionDate;
  @override
  InvestorUserModel get user;
  @override
  InvestorOfferingModel get offering;

  /// Create a copy of CreatorInvestorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatorInvestorModelImplCopyWith<_$CreatorInvestorModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

InvestorUserModel _$InvestorUserModelFromJson(Map<String, dynamic> json) {
  return _InvestorUserModel.fromJson(json);
}

/// @nodoc
mixin _$InvestorUserModel {
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  /// Serializes this InvestorUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvestorUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestorUserModelCopyWith<InvestorUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestorUserModelCopyWith<$Res> {
  factory $InvestorUserModelCopyWith(
          InvestorUserModel value, $Res Function(InvestorUserModel) then) =
      _$InvestorUserModelCopyWithImpl<$Res, InvestorUserModel>;
  @useResult
  $Res call({String firstName, String lastName, String? avatar});
}

/// @nodoc
class _$InvestorUserModelCopyWithImpl<$Res, $Val extends InvestorUserModel>
    implements $InvestorUserModelCopyWith<$Res> {
  _$InvestorUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvestorUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? avatar = freezed,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvestorUserModelImplCopyWith<$Res>
    implements $InvestorUserModelCopyWith<$Res> {
  factory _$$InvestorUserModelImplCopyWith(_$InvestorUserModelImpl value,
          $Res Function(_$InvestorUserModelImpl) then) =
      __$$InvestorUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String firstName, String lastName, String? avatar});
}

/// @nodoc
class __$$InvestorUserModelImplCopyWithImpl<$Res>
    extends _$InvestorUserModelCopyWithImpl<$Res, _$InvestorUserModelImpl>
    implements _$$InvestorUserModelImplCopyWith<$Res> {
  __$$InvestorUserModelImplCopyWithImpl(_$InvestorUserModelImpl _value,
      $Res Function(_$InvestorUserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvestorUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? avatar = freezed,
  }) {
    return _then(_$InvestorUserModelImpl(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvestorUserModelImpl implements _InvestorUserModel {
  const _$InvestorUserModelImpl(
      {required this.firstName, required this.lastName, this.avatar});

  factory _$InvestorUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestorUserModelImplFromJson(json);

  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? avatar;

  @override
  String toString() {
    return 'InvestorUserModel(firstName: $firstName, lastName: $lastName, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestorUserModelImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, avatar);

  /// Create a copy of InvestorUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestorUserModelImplCopyWith<_$InvestorUserModelImpl> get copyWith =>
      __$$InvestorUserModelImplCopyWithImpl<_$InvestorUserModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestorUserModelImplToJson(
      this,
    );
  }
}

abstract class _InvestorUserModel implements InvestorUserModel {
  const factory _InvestorUserModel(
      {required final String firstName,
      required final String lastName,
      final String? avatar}) = _$InvestorUserModelImpl;

  factory _InvestorUserModel.fromJson(Map<String, dynamic> json) =
      _$InvestorUserModelImpl.fromJson;

  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String? get avatar;

  /// Create a copy of InvestorUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestorUserModelImplCopyWith<_$InvestorUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvestorOfferingModel _$InvestorOfferingModelFromJson(
    Map<String, dynamic> json) {
  return _InvestorOfferingModel.fromJson(json);
}

/// @nodoc
mixin _$InvestorOfferingModel {
  String get name => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  /// Serializes this InvestorOfferingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvestorOfferingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestorOfferingModelCopyWith<InvestorOfferingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestorOfferingModelCopyWith<$Res> {
  factory $InvestorOfferingModelCopyWith(InvestorOfferingModel value,
          $Res Function(InvestorOfferingModel) then) =
      _$InvestorOfferingModelCopyWithImpl<$Res, InvestorOfferingModel>;
  @useResult
  $Res call({String name, String symbol, String? icon});
}

/// @nodoc
class _$InvestorOfferingModelCopyWithImpl<$Res,
        $Val extends InvestorOfferingModel>
    implements $InvestorOfferingModelCopyWith<$Res> {
  _$InvestorOfferingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvestorOfferingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? symbol = null,
    Object? icon = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvestorOfferingModelImplCopyWith<$Res>
    implements $InvestorOfferingModelCopyWith<$Res> {
  factory _$$InvestorOfferingModelImplCopyWith(
          _$InvestorOfferingModelImpl value,
          $Res Function(_$InvestorOfferingModelImpl) then) =
      __$$InvestorOfferingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String symbol, String? icon});
}

/// @nodoc
class __$$InvestorOfferingModelImplCopyWithImpl<$Res>
    extends _$InvestorOfferingModelCopyWithImpl<$Res,
        _$InvestorOfferingModelImpl>
    implements _$$InvestorOfferingModelImplCopyWith<$Res> {
  __$$InvestorOfferingModelImplCopyWithImpl(_$InvestorOfferingModelImpl _value,
      $Res Function(_$InvestorOfferingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvestorOfferingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? symbol = null,
    Object? icon = freezed,
  }) {
    return _then(_$InvestorOfferingModelImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvestorOfferingModelImpl implements _InvestorOfferingModel {
  const _$InvestorOfferingModelImpl(
      {required this.name, required this.symbol, this.icon});

  factory _$InvestorOfferingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestorOfferingModelImplFromJson(json);

  @override
  final String name;
  @override
  final String symbol;
  @override
  final String? icon;

  @override
  String toString() {
    return 'InvestorOfferingModel(name: $name, symbol: $symbol, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestorOfferingModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, symbol, icon);

  /// Create a copy of InvestorOfferingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestorOfferingModelImplCopyWith<_$InvestorOfferingModelImpl>
      get copyWith => __$$InvestorOfferingModelImplCopyWithImpl<
          _$InvestorOfferingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestorOfferingModelImplToJson(
      this,
    );
  }
}

abstract class _InvestorOfferingModel implements InvestorOfferingModel {
  const factory _InvestorOfferingModel(
      {required final String name,
      required final String symbol,
      final String? icon}) = _$InvestorOfferingModelImpl;

  factory _InvestorOfferingModel.fromJson(Map<String, dynamic> json) =
      _$InvestorOfferingModelImpl.fromJson;

  @override
  String get name;
  @override
  String get symbol;
  @override
  String? get icon;

  /// Create a copy of InvestorOfferingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestorOfferingModelImplCopyWith<_$InvestorOfferingModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
