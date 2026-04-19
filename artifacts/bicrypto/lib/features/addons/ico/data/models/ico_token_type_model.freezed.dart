// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ico_token_type_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IcoTokenTypeModel _$IcoTokenTypeModelFromJson(Map<String, dynamic> json) {
  return _IcoTokenTypeModel.fromJson(json);
}

/// @nodoc
mixin _$IcoTokenTypeModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this IcoTokenTypeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IcoTokenTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IcoTokenTypeModelCopyWith<IcoTokenTypeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IcoTokenTypeModelCopyWith<$Res> {
  factory $IcoTokenTypeModelCopyWith(
          IcoTokenTypeModel value, $Res Function(IcoTokenTypeModel) then) =
      _$IcoTokenTypeModelCopyWithImpl<$Res, IcoTokenTypeModel>;
  @useResult
  $Res call({String id, String name, String description, bool isActive});
}

/// @nodoc
class _$IcoTokenTypeModelCopyWithImpl<$Res, $Val extends IcoTokenTypeModel>
    implements $IcoTokenTypeModelCopyWith<$Res> {
  _$IcoTokenTypeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IcoTokenTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IcoTokenTypeModelImplCopyWith<$Res>
    implements $IcoTokenTypeModelCopyWith<$Res> {
  factory _$$IcoTokenTypeModelImplCopyWith(_$IcoTokenTypeModelImpl value,
          $Res Function(_$IcoTokenTypeModelImpl) then) =
      __$$IcoTokenTypeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String description, bool isActive});
}

/// @nodoc
class __$$IcoTokenTypeModelImplCopyWithImpl<$Res>
    extends _$IcoTokenTypeModelCopyWithImpl<$Res, _$IcoTokenTypeModelImpl>
    implements _$$IcoTokenTypeModelImplCopyWith<$Res> {
  __$$IcoTokenTypeModelImplCopyWithImpl(_$IcoTokenTypeModelImpl _value,
      $Res Function(_$IcoTokenTypeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of IcoTokenTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? isActive = null,
  }) {
    return _then(_$IcoTokenTypeModelImpl(
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
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IcoTokenTypeModelImpl extends _IcoTokenTypeModel {
  const _$IcoTokenTypeModelImpl(
      {required this.id,
      required this.name,
      required this.description,
      this.isActive = true})
      : super._();

  factory _$IcoTokenTypeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IcoTokenTypeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'IcoTokenTypeModel(id: $id, name: $name, description: $description, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IcoTokenTypeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, isActive);

  /// Create a copy of IcoTokenTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IcoTokenTypeModelImplCopyWith<_$IcoTokenTypeModelImpl> get copyWith =>
      __$$IcoTokenTypeModelImplCopyWithImpl<_$IcoTokenTypeModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IcoTokenTypeModelImplToJson(
      this,
    );
  }
}

abstract class _IcoTokenTypeModel extends IcoTokenTypeModel {
  const factory _IcoTokenTypeModel(
      {required final String id,
      required final String name,
      required final String description,
      final bool isActive}) = _$IcoTokenTypeModelImpl;
  const _IcoTokenTypeModel._() : super._();

  factory _IcoTokenTypeModel.fromJson(Map<String, dynamic> json) =
      _$IcoTokenTypeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  bool get isActive;

  /// Create a copy of IcoTokenTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IcoTokenTypeModelImplCopyWith<_$IcoTokenTypeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
