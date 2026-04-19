// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_payment_method_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

P2PPaymentMethodModel _$P2PPaymentMethodModelFromJson(
    Map<String, dynamic> json) {
  return _P2PPaymentMethodModel.fromJson(json);
}

/// @nodoc
mixin _$P2PPaymentMethodModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  Map<String, dynamic>? get config => throw _privateConstructorUsedError;
  List<String>? get supportedCountries => throw _privateConstructorUsedError;
  Map<String, dynamic>? get limits => throw _privateConstructorUsedError;

  /// Serializes this P2PPaymentMethodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PPaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PPaymentMethodModelCopyWith<P2PPaymentMethodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PPaymentMethodModelCopyWith<$Res> {
  factory $P2PPaymentMethodModelCopyWith(P2PPaymentMethodModel value,
          $Res Function(P2PPaymentMethodModel) then) =
      _$P2PPaymentMethodModelCopyWithImpl<$Res, P2PPaymentMethodModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String currency,
      bool isEnabled,
      Map<String, dynamic>? config,
      List<String>? supportedCountries,
      Map<String, dynamic>? limits});
}

/// @nodoc
class _$P2PPaymentMethodModelCopyWithImpl<$Res,
        $Val extends P2PPaymentMethodModel>
    implements $P2PPaymentMethodModelCopyWith<$Res> {
  _$P2PPaymentMethodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PPaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? currency = null,
    Object? isEnabled = null,
    Object? config = freezed,
    Object? supportedCountries = freezed,
    Object? limits = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      supportedCountries: freezed == supportedCountries
          ? _value.supportedCountries
          : supportedCountries // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      limits: freezed == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2PPaymentMethodModelImplCopyWith<$Res>
    implements $P2PPaymentMethodModelCopyWith<$Res> {
  factory _$$P2PPaymentMethodModelImplCopyWith(
          _$P2PPaymentMethodModelImpl value,
          $Res Function(_$P2PPaymentMethodModelImpl) then) =
      __$$P2PPaymentMethodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String currency,
      bool isEnabled,
      Map<String, dynamic>? config,
      List<String>? supportedCountries,
      Map<String, dynamic>? limits});
}

/// @nodoc
class __$$P2PPaymentMethodModelImplCopyWithImpl<$Res>
    extends _$P2PPaymentMethodModelCopyWithImpl<$Res,
        _$P2PPaymentMethodModelImpl>
    implements _$$P2PPaymentMethodModelImplCopyWith<$Res> {
  __$$P2PPaymentMethodModelImplCopyWithImpl(_$P2PPaymentMethodModelImpl _value,
      $Res Function(_$P2PPaymentMethodModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PPaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? currency = null,
    Object? isEnabled = null,
    Object? config = freezed,
    Object? supportedCountries = freezed,
    Object? limits = freezed,
  }) {
    return _then(_$P2PPaymentMethodModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      config: freezed == config
          ? _value._config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      supportedCountries: freezed == supportedCountries
          ? _value._supportedCountries
          : supportedCountries // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      limits: freezed == limits
          ? _value._limits
          : limits // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PPaymentMethodModelImpl implements _P2PPaymentMethodModel {
  const _$P2PPaymentMethodModelImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.currency,
      required this.isEnabled,
      final Map<String, dynamic>? config,
      final List<String>? supportedCountries,
      final Map<String, dynamic>? limits})
      : _config = config,
        _supportedCountries = supportedCountries,
        _limits = limits;

  factory _$P2PPaymentMethodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PPaymentMethodModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String currency;
  @override
  final bool isEnabled;
  final Map<String, dynamic>? _config;
  @override
  Map<String, dynamic>? get config {
    final value = _config;
    if (value == null) return null;
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _supportedCountries;
  @override
  List<String>? get supportedCountries {
    final value = _supportedCountries;
    if (value == null) return null;
    if (_supportedCountries is EqualUnmodifiableListView)
      return _supportedCountries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _limits;
  @override
  Map<String, dynamic>? get limits {
    final value = _limits;
    if (value == null) return null;
    if (_limits is EqualUnmodifiableMapView) return _limits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'P2PPaymentMethodModel(id: $id, name: $name, type: $type, currency: $currency, isEnabled: $isEnabled, config: $config, supportedCountries: $supportedCountries, limits: $limits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PPaymentMethodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            const DeepCollectionEquality()
                .equals(other._supportedCountries, _supportedCountries) &&
            const DeepCollectionEquality().equals(other._limits, _limits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      currency,
      isEnabled,
      const DeepCollectionEquality().hash(_config),
      const DeepCollectionEquality().hash(_supportedCountries),
      const DeepCollectionEquality().hash(_limits));

  /// Create a copy of P2PPaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PPaymentMethodModelImplCopyWith<_$P2PPaymentMethodModelImpl>
      get copyWith => __$$P2PPaymentMethodModelImplCopyWithImpl<
          _$P2PPaymentMethodModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PPaymentMethodModelImplToJson(
      this,
    );
  }
}

abstract class _P2PPaymentMethodModel implements P2PPaymentMethodModel {
  const factory _P2PPaymentMethodModel(
      {required final String id,
      required final String name,
      required final String type,
      required final String currency,
      required final bool isEnabled,
      final Map<String, dynamic>? config,
      final List<String>? supportedCountries,
      final Map<String, dynamic>? limits}) = _$P2PPaymentMethodModelImpl;

  factory _P2PPaymentMethodModel.fromJson(Map<String, dynamic> json) =
      _$P2PPaymentMethodModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  String get currency;
  @override
  bool get isEnabled;
  @override
  Map<String, dynamic>? get config;
  @override
  List<String>? get supportedCountries;
  @override
  Map<String, dynamic>? get limits;

  /// Create a copy of P2PPaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PPaymentMethodModelImplCopyWith<_$P2PPaymentMethodModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
