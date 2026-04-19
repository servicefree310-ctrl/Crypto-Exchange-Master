import 'dart:convert';
import 'dart:developer' as dev;
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/profile_entity.dart';
import '../../../auth/domain/entities/author_entity.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel extends ProfileEntity {
  @JsonKey(name: 'profile')
  final ProfileInfoModel? profileInfo;

  @JsonKey(name: 'settings')
  final NotificationSettingsModel? notificationSettings;

  @JsonKey(name: 'twoFactor')
  final TwoFactorModel? twoFactorAuth;

  @JsonKey(name: 'roleId')
  final int roleId;

  @JsonKey(name: 'role', includeToJson: false)
  final RoleModel? roleData;

  @JsonKey(name: 'phoneVerified')
  final bool? phoneVerified;

  @JsonKey(name: 'featureAccess')
  final List<String>? featureAccess;

  @override
  @JsonKey(name: 'kycLevel')
  final int? kycLevel;

  @JsonKey(name: 'author')
  final AuthorModel? authorProfile;

  ProfileModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.avatar,
    required super.emailVerified,
    required super.status,
    required super.role,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    this.profileInfo,
    this.notificationSettings,
    this.twoFactorAuth,
    required this.roleId,
    this.roleData,
    this.phoneVerified,
    this.featureAccess,
    this.kycLevel,
    this.authorProfile,
  }) : super(
          profile: profileInfo,
          settings: notificationSettings,
          twoFactor: twoFactorAuth,
          kycLevel: kycLevel,
          author: authorProfile?.toEntity(),
        );

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    dev.log('🔵 PROFILE_MODEL: Parsing JSON: ${json.toString()}');

    try {
      // Parse dates safely
      DateTime? emailVerifiedAt;
      if (json['emailVerifiedAt'] != null) {
        try {
          emailVerifiedAt = DateTime.parse(json['emailVerifiedAt'] as String);
        } catch (e) {
          dev.log('🔴 PROFILE_MODEL: Error parsing emailVerifiedAt: $e');
        }
      }

      DateTime createdAt = DateTime.now();
      DateTime updatedAt = DateTime.now();

      try {
        createdAt = DateTime.parse(json['createdAt'] as String);
        updatedAt = DateTime.parse(json['updatedAt'] as String);
      } catch (e) {
        dev.log('🔴 PROFILE_MODEL: Error parsing dates: $e');
      }

      // Handle role data - can be nested object or just roleId
      String roleString = 'User';
      int roleIdValue = 1;
      RoleModel? roleData;

      // Check if role is nested object (from backend includes)
      final dynamic roleRaw = json['role'];
      if (roleRaw != null) {
        if (roleRaw is Map<String, dynamic>) {
          roleData = RoleModel.fromJson(roleRaw);
          roleString = roleRaw['name'] as String? ?? 'User';
          roleIdValue = roleRaw['id'] as int? ?? 1;
        } else if (roleRaw is String) {
          roleString = roleRaw;
        } else if (roleRaw is int) {
          roleIdValue = roleRaw;
        }
      }

      // Handle roleId field
      final dynamic roleIdRaw = json['roleId'];
      if (roleIdRaw != null) {
        if (roleIdRaw is String) {
          roleIdValue = int.tryParse(roleIdRaw) ?? roleIdValue;
        } else if (roleIdRaw is int) {
          roleIdValue = roleIdRaw;
        }
      }

      // Fallback role mapping
      if (roleString == 'User') {
        switch (roleIdValue) {
          case 2:
            roleString = 'Admin';
            break;
          case 3:
            roleString = 'Super Admin';
            break;
        }
      }

      // Handle profile data - can be JSON string or object
      ProfileInfoModel? profileInfo;
      final dynamic profileRaw = json['profile'];
      if (profileRaw != null) {
        try {
          if (profileRaw is String) {
            // Parse JSON string
            final Map<String, dynamic> profileMap = jsonDecode(profileRaw);
            profileInfo = ProfileInfoModel.fromJson(profileMap);
          } else if (profileRaw is Map<String, dynamic>) {
            profileInfo = ProfileInfoModel.fromJson(profileRaw);
          }
        } catch (e) {
          dev.log('🔴 PROFILE_MODEL: Error parsing profile: $e');
        }
      }

      // Handle settings data - can be JSON string or object
      NotificationSettingsModel? notificationSettings;
      final dynamic settingsRaw = json['settings'];
      if (settingsRaw != null) {
        try {
          if (settingsRaw is String) {
            // Parse JSON string
            final Map<String, dynamic> settingsMap = jsonDecode(settingsRaw);
            notificationSettings =
                NotificationSettingsModel.fromJson(settingsMap);
          } else if (settingsRaw is Map<String, dynamic>) {
            notificationSettings =
                NotificationSettingsModel.fromJson(settingsRaw);
          }
        } catch (e) {
          dev.log('🔴 PROFILE_MODEL: Error parsing settings: $e');
        }
      }

      // Handle twoFactor data - can be nested object
      TwoFactorModel? twoFactorAuth;
      final dynamic twoFactorRaw = json['twoFactor'];
      if (twoFactorRaw != null && twoFactorRaw is Map<String, dynamic>) {
        try {
          twoFactorAuth = TwoFactorModel.fromJson(twoFactorRaw);
        } catch (e) {
          dev.log('🔴 PROFILE_MODEL: Error parsing twoFactor: $e');
        }
      }

      // Handle author data - can be nested object
      AuthorModel? authorProfile;
      final dynamic authorRaw = json['author'];
      if (authorRaw != null && authorRaw is Map<String, dynamic>) {
        try {
          authorProfile = AuthorModel.fromJson(authorRaw);
        } catch (e) {
          dev.log('🔴 PROFILE_MODEL: Error parsing author: $e');
        }
      }

      // Handle featureAccess array
      List<String>? featureAccess;
      final dynamic featureAccessRaw = json['featureAccess'];
      if (featureAccessRaw != null) {
        try {
          if (featureAccessRaw is List) {
            featureAccess = List<String>.from(featureAccessRaw);
          } else if (featureAccessRaw is String) {
            // Parse JSON string array
            final List<dynamic> featureList = jsonDecode(featureAccessRaw);
            featureAccess = List<String>.from(featureList);
          }
        } catch (e) {
          dev.log('🔴 PROFILE_MODEL: Error parsing featureAccess: $e');
        }
      }

      // Handle kycLevel
      int? kycLevel;
      final dynamic kycLevelRaw = json['kycLevel'];
      if (kycLevelRaw != null) {
        if (kycLevelRaw is int) {
          kycLevel = kycLevelRaw;
        } else if (kycLevelRaw is String) {
          kycLevel = int.tryParse(kycLevelRaw);
        }
      }

      final profileModel = ProfileModel(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phone: json['phone'] as String?,
        avatar: json['avatar'] as String?,
        emailVerified: json['emailVerified'] as bool? ?? false,
        status: json['status'] as String? ?? 'ACTIVE',
        role: roleString,
        emailVerifiedAt: emailVerifiedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        profileInfo: profileInfo,
        notificationSettings: notificationSettings,
        twoFactorAuth: twoFactorAuth,
        roleId: roleIdValue,
        roleData: roleData,
        phoneVerified: json['phoneVerified'] as bool?,
        featureAccess: featureAccess,
        kycLevel: kycLevel,
        authorProfile: authorProfile,
      );

      dev.log('🟢 PROFILE_MODEL: Successfully parsed profile model');
      return profileModel;
    } catch (e, stackTrace) {
      dev.log('🔴 PROFILE_MODEL: Error in fromJson: $e');
      dev.log('🔴 PROFILE_MODEL: StackTrace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

@JsonSerializable()
class RoleModel {
  final int id;
  final String name;
  final List<PermissionModel>? permissions;

  const RoleModel({
    required this.id,
    required this.name,
    this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
        id: json['id'] as int,
        name: json['name'] as String,
        permissions: json['permissions'] != null
            ? (json['permissions'] as List)
                .map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'permissions': permissions?.map((e) => e.toJson()).toList(),
      };
}

@JsonSerializable()
class PermissionModel {
  final int id;
  final String name;

  const PermissionModel({
    required this.id,
    required this.name,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      PermissionModel(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

@JsonSerializable()
class ProfileInfoModel extends ProfileInfoEntity {
  @JsonKey(name: 'location')
  final LocationModel? locationInfo;

  @JsonKey(name: 'social')
  final SocialLinksModel? socialLinks;

  const ProfileInfoModel({
    super.bio,
    this.locationInfo,
    this.socialLinks,
  }) : super(
          location: locationInfo,
          social: socialLinks,
        );

  factory ProfileInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileInfoModelToJson(this);
}

@JsonSerializable()
class LocationModel extends LocationEntity {
  const LocationModel({
    super.address,
    super.city,
    super.country,
    super.zip,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

@JsonSerializable()
class SocialLinksModel extends SocialLinksEntity {
  const SocialLinksModel({
    super.twitter,
    super.dribbble,
    super.instagram,
    super.github,
    super.gitlab,
    super.telegram,
  });

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) =>
      _$SocialLinksModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocialLinksModelToJson(this);
}

@JsonSerializable()
class NotificationSettingsModel extends NotificationSettingsEntity {
  const NotificationSettingsModel({
    super.email,
    super.sms,
    super.push,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsModelToJson(this);
}

@JsonSerializable()
class TwoFactorModel extends TwoFactorEntity {
  const TwoFactorModel({
    super.type,
    super.enabled,
    super.secret,
    super.recoveryCodes,
  });

  factory TwoFactorModel.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorModelFromJson(json);

  Map<String, dynamic> toJson() => _$TwoFactorModelToJson(this);
}

@JsonSerializable()
class AuthorModel {
  final String id;
  final String status;

  const AuthorModel({
    required this.id,
    required this.status,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) => AuthorModel(
        id: json['id'] as String,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
      };

  // Convert to domain entity
  AuthorEntity toEntity() {
    AuthorStatus authorStatus;
    switch (status.toLowerCase()) {
      case 'approved':
        authorStatus = AuthorStatus.approved;
        break;
      case 'pending':
        authorStatus = AuthorStatus.pending;
        break;
      case 'rejected':
        authorStatus = AuthorStatus.rejected;
        break;
      default:
        authorStatus = AuthorStatus.pending;
    }

    return AuthorEntity(
      id: id,
      status: authorStatus,
    );
  }
}
