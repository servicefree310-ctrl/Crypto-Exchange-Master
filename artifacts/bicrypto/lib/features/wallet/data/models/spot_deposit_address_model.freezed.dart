// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spot_deposit_address_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpotDepositAddressModel _$SpotDepositAddressModelFromJson(
    Map<String, dynamic> json) {
  return _SpotDepositAddressModel.fromJson(json);
}

/// @nodoc
mixin _$SpotDepositAddressModel {
  String get address => throw _privateConstructorUsedError;
  String? get tag => throw _privateConstructorUsedError;
  String get network => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get trx => throw _privateConstructorUsedError;

  /// Serializes this SpotDepositAddressModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpotDepositAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotDepositAddressModelCopyWith<SpotDepositAddressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotDepositAddressModelCopyWith<$Res> {
  factory $SpotDepositAddressModelCopyWith(SpotDepositAddressModel value,
          $Res Function(SpotDepositAddressModel) then) =
      _$SpotDepositAddressModelCopyWithImpl<$Res, SpotDepositAddressModel>;
  @useResult
  $Res call(
      {String address, String? tag, String network, String currency, bool trx});
}

/// @nodoc
class _$SpotDepositAddressModelCopyWithImpl<$Res,
        $Val extends SpotDepositAddressModel>
    implements $SpotDepositAddressModelCopyWith<$Res> {
  _$SpotDepositAddressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotDepositAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? tag = freezed,
    Object? network = null,
    Object? currency = null,
    Object? trx = null,
  }) {
    return _then(_value.copyWith(
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      tag: freezed == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String?,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      trx: null == trx
          ? _value.trx
          : trx // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpotDepositAddressModelImplCopyWith<$Res>
    implements $SpotDepositAddressModelCopyWith<$Res> {
  factory _$$SpotDepositAddressModelImplCopyWith(
          _$SpotDepositAddressModelImpl value,
          $Res Function(_$SpotDepositAddressModelImpl) then) =
      __$$SpotDepositAddressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String address, String? tag, String network, String currency, bool trx});
}

/// @nodoc
class __$$SpotDepositAddressModelImplCopyWithImpl<$Res>
    extends _$SpotDepositAddressModelCopyWithImpl<$Res,
        _$SpotDepositAddressModelImpl>
    implements _$$SpotDepositAddressModelImplCopyWith<$Res> {
  __$$SpotDepositAddressModelImplCopyWithImpl(
      _$SpotDepositAddressModelImpl _value,
      $Res Function(_$SpotDepositAddressModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotDepositAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? tag = freezed,
    Object? network = null,
    Object? currency = null,
    Object? trx = null,
  }) {
    return _then(_$SpotDepositAddressModelImpl(
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      tag: freezed == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String?,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      trx: null == trx
          ? _value.trx
          : trx // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpotDepositAddressModelImpl implements _SpotDepositAddressModel {
  const _$SpotDepositAddressModelImpl(
      {required this.address,
      this.tag,
      required this.network,
      required this.currency,
      required this.trx});

  factory _$SpotDepositAddressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpotDepositAddressModelImplFromJson(json);

  @override
  final String address;
  @override
  final String? tag;
  @override
  final String network;
  @override
  final String currency;
  @override
  final bool trx;

  @override
  String toString() {
    return 'SpotDepositAddressModel(address: $address, tag: $tag, network: $network, currency: $currency, trx: $trx)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotDepositAddressModelImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.trx, trx) || other.trx == trx));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, address, tag, network, currency, trx);

  /// Create a copy of SpotDepositAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotDepositAddressModelImplCopyWith<_$SpotDepositAddressModelImpl>
      get copyWith => __$$SpotDepositAddressModelImplCopyWithImpl<
          _$SpotDepositAddressModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpotDepositAddressModelImplToJson(
      this,
    );
  }
}

abstract class _SpotDepositAddressModel implements SpotDepositAddressModel {
  const factory _SpotDepositAddressModel(
      {required final String address,
      final String? tag,
      required final String network,
      required final String currency,
      required final bool trx}) = _$SpotDepositAddressModelImpl;

  factory _SpotDepositAddressModel.fromJson(Map<String, dynamic> json) =
      _$SpotDepositAddressModelImpl.fromJson;

  @override
  String get address;
  @override
  String? get tag;
  @override
  String get network;
  @override
  String get currency;
  @override
  bool get trx;

  /// Create a copy of SpotDepositAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotDepositAddressModelImplCopyWith<_$SpotDepositAddressModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
