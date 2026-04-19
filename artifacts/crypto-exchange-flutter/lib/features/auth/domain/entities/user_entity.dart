import 'package:equatable/equatable.dart';
import 'author_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatar;
  final bool emailVerified;
  final String status;
  final String? role;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TwoFactorEntity? twoFactor;
  final AuthorEntity? author;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatar,
    required this.emailVerified,
    required this.status,
    this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.twoFactor,
    this.author,
  });

  String get fullName => '$firstName $lastName';

  bool get isActive => status == 'ACTIVE';
  bool get isBanned => status == 'BANNED';
  bool get isSuspended => status == 'SUSPENDED';
  bool get isInactive => status == 'INACTIVE';

  bool get isAuthor => author != null;
  bool get isApprovedAuthor => author?.status == AuthorStatus.approved;
  bool get hasPendingAuthorApplication =>
      author?.status == AuthorStatus.pending;

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        avatar,
        emailVerified,
        status,
        role,
        emailVerifiedAt,
        createdAt,
        updatedAt,
        twoFactor,
        author,
      ];

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatar,
    bool? emailVerified,
    String? status,
    String? role,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    TwoFactorEntity? twoFactor,
    AuthorEntity? author,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      emailVerified: emailVerified ?? this.emailVerified,
      status: status ?? this.status,
      role: role ?? this.role,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      twoFactor: twoFactor ?? this.twoFactor,
      author: author ?? this.author,
    );
  }
}

class TwoFactorEntity extends Equatable {
  final String id;
  final String userId;
  final String type;
  final bool enabled;
  final String? secret;

  const TwoFactorEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.enabled,
    this.secret,
  });

  bool get isSmsEnabled => enabled && type == 'SMS';
  bool get isEmailEnabled => enabled && type == 'EMAIL';
  bool get isAppEnabled => enabled && type == 'APP';

  @override
  List<Object?> get props => [id, userId, type, enabled, secret];
}
