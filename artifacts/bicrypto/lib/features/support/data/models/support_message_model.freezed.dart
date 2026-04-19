// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SupportMessageModel _$SupportMessageModelFromJson(Map<String, dynamic> json) {
  return _SupportMessageModel.fromJson(json);
}

/// @nodoc
mixin _$SupportMessageModel {
  String? get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // "client" or "agent"
  String get text => throw _privateConstructorUsedError; // Message content
  String get time => throw _privateConstructorUsedError; // ISO timestamp string
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this SupportMessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportMessageModelCopyWith<SupportMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportMessageModelCopyWith<$Res> {
  factory $SupportMessageModelCopyWith(
          SupportMessageModel value, $Res Function(SupportMessageModel) then) =
      _$SupportMessageModelCopyWithImpl<$Res, SupportMessageModel>;
  @useResult
  $Res call({String? id, String type, String text, String time, String userId});
}

/// @nodoc
class _$SupportMessageModelCopyWithImpl<$Res, $Val extends SupportMessageModel>
    implements $SupportMessageModelCopyWith<$Res> {
  _$SupportMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = null,
    Object? text = null,
    Object? time = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupportMessageModelImplCopyWith<$Res>
    implements $SupportMessageModelCopyWith<$Res> {
  factory _$$SupportMessageModelImplCopyWith(_$SupportMessageModelImpl value,
          $Res Function(_$SupportMessageModelImpl) then) =
      __$$SupportMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String type, String text, String time, String userId});
}

/// @nodoc
class __$$SupportMessageModelImplCopyWithImpl<$Res>
    extends _$SupportMessageModelCopyWithImpl<$Res, _$SupportMessageModelImpl>
    implements _$$SupportMessageModelImplCopyWith<$Res> {
  __$$SupportMessageModelImplCopyWithImpl(_$SupportMessageModelImpl _value,
      $Res Function(_$SupportMessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SupportMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = null,
    Object? text = null,
    Object? time = null,
    Object? userId = null,
  }) {
    return _then(_$SupportMessageModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportMessageModelImpl implements _SupportMessageModel {
  const _$SupportMessageModelImpl(
      {this.id,
      required this.type,
      required this.text,
      required this.time,
      required this.userId});

  factory _$SupportMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportMessageModelImplFromJson(json);

  @override
  final String? id;
  @override
  final String type;
// "client" or "agent"
  @override
  final String text;
// Message content
  @override
  final String time;
// ISO timestamp string
  @override
  final String userId;

  @override
  String toString() {
    return 'SupportMessageModel(id: $id, type: $type, text: $text, time: $time, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportMessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, text, time, userId);

  /// Create a copy of SupportMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportMessageModelImplCopyWith<_$SupportMessageModelImpl> get copyWith =>
      __$$SupportMessageModelImplCopyWithImpl<_$SupportMessageModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportMessageModelImplToJson(
      this,
    );
  }
}

abstract class _SupportMessageModel implements SupportMessageModel {
  const factory _SupportMessageModel(
      {final String? id,
      required final String type,
      required final String text,
      required final String time,
      required final String userId}) = _$SupportMessageModelImpl;

  factory _SupportMessageModel.fromJson(Map<String, dynamic> json) =
      _$SupportMessageModelImpl.fromJson;

  @override
  String? get id;
  @override
  String get type; // "client" or "agent"
  @override
  String get text; // Message content
  @override
  String get time; // ISO timestamp string
  @override
  String get userId;

  /// Create a copy of SupportMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportMessageModelImplCopyWith<_$SupportMessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
