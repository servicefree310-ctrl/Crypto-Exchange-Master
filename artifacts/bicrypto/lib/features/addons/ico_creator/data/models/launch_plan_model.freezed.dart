// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launch_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LaunchPlanModel _$LaunchPlanModelFromJson(Map<String, dynamic> json) {
  return _LaunchPlanModel.fromJson(json);
}

/// @nodoc
mixin _$LaunchPlanModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get walletType => throw _privateConstructorUsedError;
  String get features => throw _privateConstructorUsedError;

  /// Serializes this LaunchPlanModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LaunchPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LaunchPlanModelCopyWith<LaunchPlanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaunchPlanModelCopyWith<$Res> {
  factory $LaunchPlanModelCopyWith(
          LaunchPlanModel value, $Res Function(LaunchPlanModel) then) =
      _$LaunchPlanModelCopyWithImpl<$Res, LaunchPlanModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double price,
      String currency,
      String walletType,
      String features});
}

/// @nodoc
class _$LaunchPlanModelCopyWithImpl<$Res, $Val extends LaunchPlanModel>
    implements $LaunchPlanModelCopyWith<$Res> {
  _$LaunchPlanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LaunchPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? currency = null,
    Object? walletType = null,
    Object? features = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LaunchPlanModelImplCopyWith<$Res>
    implements $LaunchPlanModelCopyWith<$Res> {
  factory _$$LaunchPlanModelImplCopyWith(_$LaunchPlanModelImpl value,
          $Res Function(_$LaunchPlanModelImpl) then) =
      __$$LaunchPlanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double price,
      String currency,
      String walletType,
      String features});
}

/// @nodoc
class __$$LaunchPlanModelImplCopyWithImpl<$Res>
    extends _$LaunchPlanModelCopyWithImpl<$Res, _$LaunchPlanModelImpl>
    implements _$$LaunchPlanModelImplCopyWith<$Res> {
  __$$LaunchPlanModelImplCopyWithImpl(
      _$LaunchPlanModelImpl _value, $Res Function(_$LaunchPlanModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LaunchPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? currency = null,
    Object? walletType = null,
    Object? features = null,
  }) {
    return _then(_$LaunchPlanModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LaunchPlanModelImpl implements _LaunchPlanModel {
  const _$LaunchPlanModelImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.currency,
      required this.walletType,
      required this.features});

  factory _$LaunchPlanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LaunchPlanModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final String currency;
  @override
  final String walletType;
  @override
  final String features;

  @override
  String toString() {
    return 'LaunchPlanModel(id: $id, name: $name, description: $description, price: $price, currency: $currency, walletType: $walletType, features: $features)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LaunchPlanModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.walletType, walletType) ||
                other.walletType == walletType) &&
            (identical(other.features, features) ||
                other.features == features));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, price,
      currency, walletType, features);

  /// Create a copy of LaunchPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LaunchPlanModelImplCopyWith<_$LaunchPlanModelImpl> get copyWith =>
      __$$LaunchPlanModelImplCopyWithImpl<_$LaunchPlanModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LaunchPlanModelImplToJson(
      this,
    );
  }
}

abstract class _LaunchPlanModel implements LaunchPlanModel {
  const factory _LaunchPlanModel(
      {required final String id,
      required final String name,
      required final String description,
      required final double price,
      required final String currency,
      required final String walletType,
      required final String features}) = _$LaunchPlanModelImpl;

  factory _LaunchPlanModel.fromJson(Map<String, dynamic> json) =
      _$LaunchPlanModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get price;
  @override
  String get currency;
  @override
  String get walletType;
  @override
  String get features;

  /// Create a copy of LaunchPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LaunchPlanModelImplCopyWith<_$LaunchPlanModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
