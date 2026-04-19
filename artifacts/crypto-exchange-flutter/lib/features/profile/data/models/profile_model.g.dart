// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      emailVerified: json['emailVerified'] as bool,
      status: json['status'] as String,
      role: json['role'] as String,
      emailVerifiedAt: json['emailVerifiedAt'] == null
          ? null
          : DateTime.parse(json['emailVerifiedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      profileInfo: json['profile'] == null
          ? null
          : ProfileInfoModel.fromJson(json['profile'] as Map<String, dynamic>),
      notificationSettings: json['settings'] == null
          ? null
          : NotificationSettingsModel.fromJson(
              json['settings'] as Map<String, dynamic>),
      twoFactorAuth: json['twoFactor'] == null
          ? null
          : TwoFactorModel.fromJson(json['twoFactor'] as Map<String, dynamic>),
      roleId: (json['roleId'] as num).toInt(),
      roleData: json['role'] == null
          ? null
          : RoleModel.fromJson(json['role'] as Map<String, dynamic>),
      phoneVerified: json['phoneVerified'] as bool?,
      featureAccess: (json['featureAccess'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      kycLevel: (json['kycLevel'] as num?)?.toInt(),
      authorProfile: json['author'] == null
          ? null
          : AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'emailVerified': instance.emailVerified,
      'status': instance.status,
      'role': instance.role,
      'emailVerifiedAt': instance.emailVerifiedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'profile': instance.profileInfo,
      'settings': instance.notificationSettings,
      'twoFactor': instance.twoFactorAuth,
      'roleId': instance.roleId,
      'phoneVerified': instance.phoneVerified,
      'featureAccess': instance.featureAccess,
      'kycLevel': instance.kycLevel,
      'author': instance.authorProfile,
    };

RoleModel _$RoleModelFromJson(Map<String, dynamic> json) => RoleModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoleModelToJson(RoleModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'permissions': instance.permissions,
    };

PermissionModel _$PermissionModelFromJson(Map<String, dynamic> json) =>
    PermissionModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$PermissionModelToJson(PermissionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

ProfileInfoModel _$ProfileInfoModelFromJson(Map<String, dynamic> json) =>
    ProfileInfoModel(
      bio: json['bio'] as String?,
      locationInfo: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      socialLinks: json['social'] == null
          ? null
          : SocialLinksModel.fromJson(json['social'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileInfoModelToJson(ProfileInfoModel instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'location': instance.locationInfo,
      'social': instance.socialLinks,
    };

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'zip': instance.zip,
    };

SocialLinksModel _$SocialLinksModelFromJson(Map<String, dynamic> json) =>
    SocialLinksModel(
      twitter: json['twitter'] as String?,
      dribbble: json['dribbble'] as String?,
      instagram: json['instagram'] as String?,
      github: json['github'] as String?,
      gitlab: json['gitlab'] as String?,
      telegram: json['telegram'] as String?,
    );

Map<String, dynamic> _$SocialLinksModelToJson(SocialLinksModel instance) =>
    <String, dynamic>{
      'twitter': instance.twitter,
      'dribbble': instance.dribbble,
      'instagram': instance.instagram,
      'github': instance.github,
      'gitlab': instance.gitlab,
      'telegram': instance.telegram,
    };

NotificationSettingsModel _$NotificationSettingsModelFromJson(
        Map<String, dynamic> json) =>
    NotificationSettingsModel(
      email: json['email'] as bool?,
      sms: json['sms'] as bool?,
      push: json['push'] as bool?,
    );

Map<String, dynamic> _$NotificationSettingsModelToJson(
        NotificationSettingsModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'sms': instance.sms,
      'push': instance.push,
    };

TwoFactorModel _$TwoFactorModelFromJson(Map<String, dynamic> json) =>
    TwoFactorModel(
      type: json['type'] as String?,
      enabled: json['enabled'] as bool?,
      secret: json['secret'] as String?,
      recoveryCodes: (json['recoveryCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TwoFactorModelToJson(TwoFactorModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'enabled': instance.enabled,
      'secret': instance.secret,
      'recoveryCodes': instance.recoveryCodes,
    };

AuthorModel _$AuthorModelFromJson(Map<String, dynamic> json) => AuthorModel(
      id: json['id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$AuthorModelToJson(AuthorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
    };
