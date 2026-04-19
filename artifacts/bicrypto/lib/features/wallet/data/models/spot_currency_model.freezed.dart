// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spot_currency_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpotCurrencyModel _$SpotCurrencyModelFromJson(Map<String, dynamic> json) {
  return _SpotCurrencyModel.fromJson(json);
}

/// @nodoc
mixin _$SpotCurrencyModel {
  String get value => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  /// Serializes this SpotCurrencyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpotCurrencyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotCurrencyModelCopyWith<SpotCurrencyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotCurrencyModelCopyWith<$Res> {
  factory $SpotCurrencyModelCopyWith(
          SpotCurrencyModel value, $Res Function(SpotCurrencyModel) then) =
      _$SpotCurrencyModelCopyWithImpl<$Res, SpotCurrencyModel>;
  @useResult
  $Res call({String value, String label, String? icon});
}

/// @nodoc
class _$SpotCurrencyModelCopyWithImpl<$Res, $Val extends SpotCurrencyModel>
    implements $SpotCurrencyModelCopyWith<$Res> {
  _$SpotCurrencyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotCurrencyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? label = null,
    Object? icon = freezed,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpotCurrencyModelImplCopyWith<$Res>
    implements $SpotCurrencyModelCopyWith<$Res> {
  factory _$$SpotCurrencyModelImplCopyWith(_$SpotCurrencyModelImpl value,
          $Res Function(_$SpotCurrencyModelImpl) then) =
      __$$SpotCurrencyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, String label, String? icon});
}

/// @nodoc
class __$$SpotCurrencyModelImplCopyWithImpl<$Res>
    extends _$SpotCurrencyModelCopyWithImpl<$Res, _$SpotCurrencyModelImpl>
    implements _$$SpotCurrencyModelImplCopyWith<$Res> {
  __$$SpotCurrencyModelImplCopyWithImpl(_$SpotCurrencyModelImpl _value,
      $Res Function(_$SpotCurrencyModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotCurrencyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? label = null,
    Object? icon = freezed,
  }) {
    return _then(_$SpotCurrencyModelImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpotCurrencyModelImpl implements _SpotCurrencyModel {
  const _$SpotCurrencyModelImpl(
      {required this.value, required this.label, this.icon});

  factory _$SpotCurrencyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpotCurrencyModelImplFromJson(json);

  @override
  final String value;
  @override
  final String label;
  @override
  final String? icon;

  @override
  String toString() {
    return 'SpotCurrencyModel(value: $value, label: $label, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotCurrencyModelImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label, icon);

  /// Create a copy of SpotCurrencyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotCurrencyModelImplCopyWith<_$SpotCurrencyModelImpl> get copyWith =>
      __$$SpotCurrencyModelImplCopyWithImpl<_$SpotCurrencyModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpotCurrencyModelImplToJson(
      this,
    );
  }
}

abstract class _SpotCurrencyModel implements SpotCurrencyModel {
  const factory _SpotCurrencyModel(
      {required final String value,
      required final String label,
      final String? icon}) = _$SpotCurrencyModelImpl;

  factory _SpotCurrencyModel.fromJson(Map<String, dynamic> json) =
      _$SpotCurrencyModelImpl.fromJson;

  @override
  String get value;
  @override
  String get label;
  @override
  String? get icon;

  /// Create a copy of SpotCurrencyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotCurrencyModelImplCopyWith<_$SpotCurrencyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
