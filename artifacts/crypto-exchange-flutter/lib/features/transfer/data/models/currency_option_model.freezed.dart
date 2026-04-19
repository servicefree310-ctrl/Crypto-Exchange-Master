// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'currency_option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CurrencyOptionModel _$CurrencyOptionModelFromJson(Map<String, dynamic> json) {
  return _CurrencyOptionModel.fromJson(json);
}

/// @nodoc
mixin _$CurrencyOptionModel {
  String get value =>
      throw _privateConstructorUsedError; // Currency code (BTC, ETH, USD)
  String get label => throw _privateConstructorUsedError; // Display label
  String? get icon => throw _privateConstructorUsedError; // Currency icon URL
  double? get balance => throw _privateConstructorUsedError;

  /// Serializes this CurrencyOptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurrencyOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrencyOptionModelCopyWith<CurrencyOptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrencyOptionModelCopyWith<$Res> {
  factory $CurrencyOptionModelCopyWith(
          CurrencyOptionModel value, $Res Function(CurrencyOptionModel) then) =
      _$CurrencyOptionModelCopyWithImpl<$Res, CurrencyOptionModel>;
  @useResult
  $Res call({String value, String label, String? icon, double? balance});
}

/// @nodoc
class _$CurrencyOptionModelCopyWithImpl<$Res, $Val extends CurrencyOptionModel>
    implements $CurrencyOptionModelCopyWith<$Res> {
  _$CurrencyOptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrencyOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? label = null,
    Object? icon = freezed,
    Object? balance = freezed,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrencyOptionModelImplCopyWith<$Res>
    implements $CurrencyOptionModelCopyWith<$Res> {
  factory _$$CurrencyOptionModelImplCopyWith(_$CurrencyOptionModelImpl value,
          $Res Function(_$CurrencyOptionModelImpl) then) =
      __$$CurrencyOptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, String label, String? icon, double? balance});
}

/// @nodoc
class __$$CurrencyOptionModelImplCopyWithImpl<$Res>
    extends _$CurrencyOptionModelCopyWithImpl<$Res, _$CurrencyOptionModelImpl>
    implements _$$CurrencyOptionModelImplCopyWith<$Res> {
  __$$CurrencyOptionModelImplCopyWithImpl(_$CurrencyOptionModelImpl _value,
      $Res Function(_$CurrencyOptionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrencyOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? label = null,
    Object? icon = freezed,
    Object? balance = freezed,
  }) {
    return _then(_$CurrencyOptionModelImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrencyOptionModelImpl implements _CurrencyOptionModel {
  const _$CurrencyOptionModelImpl(
      {required this.value, required this.label, this.icon, this.balance});

  factory _$CurrencyOptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrencyOptionModelImplFromJson(json);

  @override
  final String value;
// Currency code (BTC, ETH, USD)
  @override
  final String label;
// Display label
  @override
  final String? icon;
// Currency icon URL
  @override
  final double? balance;

  @override
  String toString() {
    return 'CurrencyOptionModel(value: $value, label: $label, icon: $icon, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrencyOptionModelImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.balance, balance) || other.balance == balance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label, icon, balance);

  /// Create a copy of CurrencyOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrencyOptionModelImplCopyWith<_$CurrencyOptionModelImpl> get copyWith =>
      __$$CurrencyOptionModelImplCopyWithImpl<_$CurrencyOptionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrencyOptionModelImplToJson(
      this,
    );
  }
}

abstract class _CurrencyOptionModel implements CurrencyOptionModel {
  const factory _CurrencyOptionModel(
      {required final String value,
      required final String label,
      final String? icon,
      final double? balance}) = _$CurrencyOptionModelImpl;

  factory _CurrencyOptionModel.fromJson(Map<String, dynamic> json) =
      _$CurrencyOptionModelImpl.fromJson;

  @override
  String get value; // Currency code (BTC, ETH, USD)
  @override
  String get label; // Display label
  @override
  String? get icon; // Currency icon URL
  @override
  double? get balance;

  /// Create a copy of CurrencyOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrencyOptionModelImplCopyWith<_$CurrencyOptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
