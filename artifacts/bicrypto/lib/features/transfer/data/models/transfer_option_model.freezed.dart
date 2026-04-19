// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransferOptionModel _$TransferOptionModelFromJson(Map<String, dynamic> json) {
  return _TransferOptionModel.fromJson(json);
}

/// @nodoc
mixin _$TransferOptionModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this TransferOptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransferOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransferOptionModelCopyWith<TransferOptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferOptionModelCopyWith<$Res> {
  factory $TransferOptionModelCopyWith(
          TransferOptionModel value, $Res Function(TransferOptionModel) then) =
      _$TransferOptionModelCopyWithImpl<$Res, TransferOptionModel>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$TransferOptionModelCopyWithImpl<$Res, $Val extends TransferOptionModel>
    implements $TransferOptionModelCopyWith<$Res> {
  _$TransferOptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransferOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferOptionModelImplCopyWith<$Res>
    implements $TransferOptionModelCopyWith<$Res> {
  factory _$$TransferOptionModelImplCopyWith(_$TransferOptionModelImpl value,
          $Res Function(_$TransferOptionModelImpl) then) =
      __$$TransferOptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$TransferOptionModelImplCopyWithImpl<$Res>
    extends _$TransferOptionModelCopyWithImpl<$Res, _$TransferOptionModelImpl>
    implements _$$TransferOptionModelImplCopyWith<$Res> {
  __$$TransferOptionModelImplCopyWithImpl(_$TransferOptionModelImpl _value,
      $Res Function(_$TransferOptionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransferOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$TransferOptionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferOptionModelImpl implements _TransferOptionModel {
  const _$TransferOptionModelImpl({required this.id, required this.name});

  factory _$TransferOptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferOptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'TransferOptionModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferOptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of TransferOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferOptionModelImplCopyWith<_$TransferOptionModelImpl> get copyWith =>
      __$$TransferOptionModelImplCopyWithImpl<_$TransferOptionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferOptionModelImplToJson(
      this,
    );
  }
}

abstract class _TransferOptionModel implements TransferOptionModel {
  const factory _TransferOptionModel(
      {required final String id,
      required final String name}) = _$TransferOptionModelImpl;

  factory _TransferOptionModel.fromJson(Map<String, dynamic> json) =
      _$TransferOptionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of TransferOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransferOptionModelImplCopyWith<_$TransferOptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
