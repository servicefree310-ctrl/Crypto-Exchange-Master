// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

P2PUserModel _$P2PUserModelFromJson(Map<String, dynamic> json) {
  return _P2PUserModel.fromJson(json);
}

/// @nodoc
mixin _$P2PUserModel {
  String get id => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  Map<String, dynamic>? get profile => throw _privateConstructorUsedError;
  bool? get emailVerified =>
      throw _privateConstructorUsedError; // P2P related fields
  List<Map<String, dynamic>>? get p2pTrades =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>>? get receivedReviews =>
      throw _privateConstructorUsedError;

  /// Serializes this P2PUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PUserModelCopyWith<P2PUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PUserModelCopyWith<$Res> {
  factory $P2PUserModelCopyWith(
          P2PUserModel value, $Res Function(P2PUserModel) then) =
      _$P2PUserModelCopyWithImpl<$Res, P2PUserModel>;
  @useResult
  $Res call(
      {String id,
      String? firstName,
      String? lastName,
      String? email,
      String? avatar,
      Map<String, dynamic>? profile,
      bool? emailVerified,
      List<Map<String, dynamic>>? p2pTrades,
      List<Map<String, dynamic>>? receivedReviews});
}

/// @nodoc
class _$P2PUserModelCopyWithImpl<$Res, $Val extends P2PUserModel>
    implements $P2PUserModelCopyWith<$Res> {
  _$P2PUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? avatar = freezed,
    Object? profile = freezed,
    Object? emailVerified = freezed,
    Object? p2pTrades = freezed,
    Object? receivedReviews = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      emailVerified: freezed == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      p2pTrades: freezed == p2pTrades
          ? _value.p2pTrades
          : p2pTrades // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      receivedReviews: freezed == receivedReviews
          ? _value.receivedReviews
          : receivedReviews // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2PUserModelImplCopyWith<$Res>
    implements $P2PUserModelCopyWith<$Res> {
  factory _$$P2PUserModelImplCopyWith(
          _$P2PUserModelImpl value, $Res Function(_$P2PUserModelImpl) then) =
      __$$P2PUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? firstName,
      String? lastName,
      String? email,
      String? avatar,
      Map<String, dynamic>? profile,
      bool? emailVerified,
      List<Map<String, dynamic>>? p2pTrades,
      List<Map<String, dynamic>>? receivedReviews});
}

/// @nodoc
class __$$P2PUserModelImplCopyWithImpl<$Res>
    extends _$P2PUserModelCopyWithImpl<$Res, _$P2PUserModelImpl>
    implements _$$P2PUserModelImplCopyWith<$Res> {
  __$$P2PUserModelImplCopyWithImpl(
      _$P2PUserModelImpl _value, $Res Function(_$P2PUserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? avatar = freezed,
    Object? profile = freezed,
    Object? emailVerified = freezed,
    Object? p2pTrades = freezed,
    Object? receivedReviews = freezed,
  }) {
    return _then(_$P2PUserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      profile: freezed == profile
          ? _value._profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      emailVerified: freezed == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      p2pTrades: freezed == p2pTrades
          ? _value._p2pTrades
          : p2pTrades // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      receivedReviews: freezed == receivedReviews
          ? _value._receivedReviews
          : receivedReviews // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PUserModelImpl implements _P2PUserModel {
  const _$P2PUserModelImpl(
      {required this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.avatar,
      final Map<String, dynamic>? profile,
      this.emailVerified,
      final List<Map<String, dynamic>>? p2pTrades,
      final List<Map<String, dynamic>>? receivedReviews})
      : _profile = profile,
        _p2pTrades = p2pTrades,
        _receivedReviews = receivedReviews;

  factory _$P2PUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PUserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? email;
  @override
  final String? avatar;
  final Map<String, dynamic>? _profile;
  @override
  Map<String, dynamic>? get profile {
    final value = _profile;
    if (value == null) return null;
    if (_profile is EqualUnmodifiableMapView) return _profile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? emailVerified;
// P2P related fields
  final List<Map<String, dynamic>>? _p2pTrades;
// P2P related fields
  @override
  List<Map<String, dynamic>>? get p2pTrades {
    final value = _p2pTrades;
    if (value == null) return null;
    if (_p2pTrades is EqualUnmodifiableListView) return _p2pTrades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Map<String, dynamic>>? _receivedReviews;
  @override
  List<Map<String, dynamic>>? get receivedReviews {
    final value = _receivedReviews;
    if (value == null) return null;
    if (_receivedReviews is EqualUnmodifiableListView) return _receivedReviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'P2PUserModel(id: $id, firstName: $firstName, lastName: $lastName, email: $email, avatar: $avatar, profile: $profile, emailVerified: $emailVerified, p2pTrades: $p2pTrades, receivedReviews: $receivedReviews)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PUserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            const DeepCollectionEquality().equals(other._profile, _profile) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            const DeepCollectionEquality()
                .equals(other._p2pTrades, _p2pTrades) &&
            const DeepCollectionEquality()
                .equals(other._receivedReviews, _receivedReviews));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      lastName,
      email,
      avatar,
      const DeepCollectionEquality().hash(_profile),
      emailVerified,
      const DeepCollectionEquality().hash(_p2pTrades),
      const DeepCollectionEquality().hash(_receivedReviews));

  /// Create a copy of P2PUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PUserModelImplCopyWith<_$P2PUserModelImpl> get copyWith =>
      __$$P2PUserModelImplCopyWithImpl<_$P2PUserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PUserModelImplToJson(
      this,
    );
  }
}

abstract class _P2PUserModel implements P2PUserModel {
  const factory _P2PUserModel(
      {required final String id,
      final String? firstName,
      final String? lastName,
      final String? email,
      final String? avatar,
      final Map<String, dynamic>? profile,
      final bool? emailVerified,
      final List<Map<String, dynamic>>? p2pTrades,
      final List<Map<String, dynamic>>? receivedReviews}) = _$P2PUserModelImpl;

  factory _P2PUserModel.fromJson(Map<String, dynamic> json) =
      _$P2PUserModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get email;
  @override
  String? get avatar;
  @override
  Map<String, dynamic>? get profile;
  @override
  bool? get emailVerified; // P2P related fields
  @override
  List<Map<String, dynamic>>? get p2pTrades;
  @override
  List<Map<String, dynamic>>? get receivedReviews;

  /// Create a copy of P2PUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PUserModelImplCopyWith<_$P2PUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
