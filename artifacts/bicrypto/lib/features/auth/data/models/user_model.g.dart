// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      emailVerified: json['emailVerified'] as bool,
      status: json['status'] as String,
      role: json['role'] as String?,
      emailVerifiedAt: json['emailVerifiedAt'] == null
          ? null
          : DateTime.parse(json['emailVerifiedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      twoFactorModel: json['twoFactor'] == null
          ? null
          : TwoFactorModel.fromJson(json['twoFactor'] as Map<String, dynamic>),
      authorModel: json['author'] == null
          ? null
          : AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'emailVerified': instance.emailVerified,
      'status': instance.status,
      'role': instance.role,
      'emailVerifiedAt': instance.emailVerifiedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'twoFactor': instance.twoFactorModel,
      'author': instance.authorModel,
    };

TwoFactorModel _$TwoFactorModelFromJson(Map<String, dynamic> json) =>
    TwoFactorModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      enabled: json['enabled'] as bool,
      secret: json['secret'] as String?,
    );

Map<String, dynamic> _$TwoFactorModelToJson(TwoFactorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'enabled': instance.enabled,
      'secret': instance.secret,
    };

AuthorModel _$AuthorModelFromJson(Map<String, dynamic> json) => AuthorModel(
      id: json['id'] as String,
      status: json['status'] as String,
      bio: json['bio'] as String?,
      postCount: (json['postCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AuthorModelToJson(AuthorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'bio': instance.bio,
      'postCount': instance.postCount,
    };
