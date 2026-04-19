import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/author_entity.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;
  final bool emailVerified;
  final String status;
  final String role;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileInfoEntity? profile;
  final NotificationSettingsEntity? settings;
  final TwoFactorEntity? twoFactor;
  final int? kycLevel;
  final AuthorEntity? author;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    required this.emailVerified,
    required this.status,
    required this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    this.settings,
    this.twoFactor,
    this.kycLevel,
    this.author,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        avatar,
        emailVerified,
        status,
        role,
        emailVerifiedAt,
        createdAt,
        updatedAt,
        profile,
        settings,
        twoFactor,
        kycLevel,
        author,
      ];
}

class ProfileInfoEntity extends Equatable {
  final String? bio;
  final LocationEntity? location;
  final SocialLinksEntity? social;

  const ProfileInfoEntity({
    this.bio,
    this.location,
    this.social,
  });

  @override
  List<Object?> get props => [bio, location, social];
}

class LocationEntity extends Equatable {
  final String? address;
  final String? city;
  final String? country;
  final String? zip;

  const LocationEntity({
    this.address,
    this.city,
    this.country,
    this.zip,
  });

  @override
  List<Object?> get props => [address, city, country, zip];
}

class SocialLinksEntity extends Equatable {
  final String? twitter;
  final String? dribbble;
  final String? instagram;
  final String? github;
  final String? gitlab;
  final String? telegram;

  const SocialLinksEntity({
    this.twitter,
    this.dribbble,
    this.instagram,
    this.github,
    this.gitlab,
    this.telegram,
  });

  @override
  List<Object?> get props =>
      [twitter, dribbble, instagram, github, gitlab, telegram];
}

class NotificationSettingsEntity extends Equatable {
  final bool? email;
  final bool? sms;
  final bool? push;

  const NotificationSettingsEntity({
    this.email,
    this.sms,
    this.push,
  });

  @override
  List<Object?> get props => [email, sms, push];
}

class TwoFactorEntity extends Equatable {
  final String? type;
  final bool? enabled;
  final String? secret;
  final List<String>? recoveryCodes;

  const TwoFactorEntity({
    this.type,
    this.enabled,
    this.secret,
    this.recoveryCodes,
  });

  @override
  List<Object?> get props => [type, enabled, secret, recoveryCodes];
}
