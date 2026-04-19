// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eco_wallet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EcoWalletModel _$EcoWalletModelFromJson(Map<String, dynamic> json) {
  return _EcoWalletModel.fromJson(json);
}

/// @nodoc
mixin _$EcoWalletModel {
  String get id => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  Map<String, dynamic>? get address => throw _privateConstructorUsedError;

  /// Serializes this EcoWalletModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EcoWalletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EcoWalletModelCopyWith<EcoWalletModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoWalletModelCopyWith<$Res> {
  factory $EcoWalletModelCopyWith(
          EcoWalletModel value, $Res Function(EcoWalletModel) then) =
      _$EcoWalletModelCopyWithImpl<$Res, EcoWalletModel>;
  @useResult
  $Res call(
      {String id,
      String currency,
      double balance,
      String type,
      Map<String, dynamic>? address});
}

/// @nodoc
class _$EcoWalletModelCopyWithImpl<$Res, $Val extends EcoWalletModel>
    implements $EcoWalletModelCopyWith<$Res> {
  _$EcoWalletModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EcoWalletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? currency = null,
    Object? balance = null,
    Object? type = null,
    Object? address = freezed,
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
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EcoWalletModelImplCopyWith<$Res>
    implements $EcoWalletModelCopyWith<$Res> {
  factory _$$EcoWalletModelImplCopyWith(_$EcoWalletModelImpl value,
          $Res Function(_$EcoWalletModelImpl) then) =
      __$$EcoWalletModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String currency,
      double balance,
      String type,
      Map<String, dynamic>? address});
}

/// @nodoc
class __$$EcoWalletModelImplCopyWithImpl<$Res>
    extends _$EcoWalletModelCopyWithImpl<$Res, _$EcoWalletModelImpl>
    implements _$$EcoWalletModelImplCopyWith<$Res> {
  __$$EcoWalletModelImplCopyWithImpl(
      _$EcoWalletModelImpl _value, $Res Function(_$EcoWalletModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EcoWalletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? currency = null,
    Object? balance = null,
    Object? type = null,
    Object? address = freezed,
  }) {
    return _then(_$EcoWalletModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value._address
          : address // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoWalletModelImpl implements _EcoWalletModel {
  const _$EcoWalletModelImpl(
      {required this.id,
      required this.currency,
      required this.balance,
      required this.type,
      final Map<String, dynamic>? address})
      : _address = address;

  factory _$EcoWalletModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoWalletModelImplFromJson(json);

  @override
  final String id;
  @override
  final String currency;
  @override
  final double balance;
  @override
  final String type;
  final Map<String, dynamic>? _address;
  @override
  Map<String, dynamic>? get address {
    final value = _address;
    if (value == null) return null;
    if (_address is EqualUnmodifiableMapView) return _address;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'EcoWalletModel(id: $id, currency: $currency, balance: $balance, type: $type, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoWalletModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._address, _address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, currency, balance, type,
      const DeepCollectionEquality().hash(_address));

  /// Create a copy of EcoWalletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoWalletModelImplCopyWith<_$EcoWalletModelImpl> get copyWith =>
      __$$EcoWalletModelImplCopyWithImpl<_$EcoWalletModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoWalletModelImplToJson(
      this,
    );
  }
}

abstract class _EcoWalletModel implements EcoWalletModel {
  const factory _EcoWalletModel(
      {required final String id,
      required final String currency,
      required final double balance,
      required final String type,
      final Map<String, dynamic>? address}) = _$EcoWalletModelImpl;

  factory _EcoWalletModel.fromJson(Map<String, dynamic> json) =
      _$EcoWalletModelImpl.fromJson;

  @override
  String get id;
  @override
  String get currency;
  @override
  double get balance;
  @override
  String get type;
  @override
  Map<String, dynamic>? get address;

  /// Create a copy of EcoWalletModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EcoWalletModelImplCopyWith<_$EcoWalletModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
