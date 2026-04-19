// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NewsCategoryModel _$NewsCategoryModelFromJson(Map<String, dynamic> json) {
  return _NewsCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$NewsCategoryModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this NewsCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsCategoryModelCopyWith<NewsCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsCategoryModelCopyWith<$Res> {
  factory $NewsCategoryModelCopyWith(
          NewsCategoryModel value, $Res Function(NewsCategoryModel) then) =
      _$NewsCategoryModelCopyWithImpl<$Res, NewsCategoryModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$NewsCategoryModelCopyWithImpl<$Res, $Val extends NewsCategoryModel>
    implements $NewsCategoryModelCopyWith<$Res> {
  _$NewsCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? isActive = null,
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
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NewsCategoryModelImplCopyWith<$Res>
    implements $NewsCategoryModelCopyWith<$Res> {
  factory _$$NewsCategoryModelImplCopyWith(_$NewsCategoryModelImpl value,
          $Res Function(_$NewsCategoryModelImpl) then) =
      __$$NewsCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$NewsCategoryModelImplCopyWithImpl<$Res>
    extends _$NewsCategoryModelCopyWithImpl<$Res, _$NewsCategoryModelImpl>
    implements _$$NewsCategoryModelImplCopyWith<$Res> {
  __$$NewsCategoryModelImplCopyWithImpl(_$NewsCategoryModelImpl _value,
      $Res Function(_$NewsCategoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewsCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? isActive = null,
  }) {
    return _then(_$NewsCategoryModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsCategoryModelImpl implements _NewsCategoryModel {
  const _$NewsCategoryModelImpl(
      {required this.id,
      required this.name,
      required this.icon,
      @JsonKey(name: 'is_active') required this.isActive});

  factory _$NewsCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsCategoryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'NewsCategoryModel(id: $id, name: $name, icon: $icon, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon, isActive);

  /// Create a copy of NewsCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsCategoryModelImplCopyWith<_$NewsCategoryModelImpl> get copyWith =>
      __$$NewsCategoryModelImplCopyWithImpl<_$NewsCategoryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsCategoryModelImplToJson(
      this,
    );
  }
}

abstract class _NewsCategoryModel implements NewsCategoryModel {
  const factory _NewsCategoryModel(
          {required final String id,
          required final String name,
          required final String icon,
          @JsonKey(name: 'is_active') required final bool isActive}) =
      _$NewsCategoryModelImpl;

  factory _NewsCategoryModel.fromJson(Map<String, dynamic> json) =
      _$NewsCategoryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of NewsCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsCategoryModelImplCopyWith<_$NewsCategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
