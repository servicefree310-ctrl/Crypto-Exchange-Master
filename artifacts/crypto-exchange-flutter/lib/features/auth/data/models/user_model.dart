import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/author_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  @JsonKey(name: 'twoFactor')
  final TwoFactorModel? twoFactorModel;

  @JsonKey(name: 'author')
  final AuthorModel? authorModel;

  UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.avatar,
    required super.emailVerified,
    required super.status,
    super.role,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    this.twoFactorModel,
    this.authorModel,
  }) : super(twoFactor: twoFactorModel, author: authorModel?.toEntity());

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phone: entity.phone,
      avatar: entity.avatar,
      emailVerified: entity.emailVerified,
      status: entity.status,
      role: entity.role,
      emailVerifiedAt: entity.emailVerifiedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      twoFactorModel: entity.twoFactor != null
          ? TwoFactorModel.fromEntity(entity.twoFactor!)
          : null,
      authorModel:
          entity.author != null ? AuthorModel.fromEntity(entity.author!) : null,
    );
  }
}

@JsonSerializable()
class TwoFactorModel extends TwoFactorEntity {
  const TwoFactorModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.enabled,
    super.secret,
  });

  factory TwoFactorModel.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorModelFromJson(json);

  Map<String, dynamic> toJson() => _$TwoFactorModelToJson(this);

  factory TwoFactorModel.fromEntity(TwoFactorEntity entity) {
    return TwoFactorModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      enabled: entity.enabled,
      secret: entity.secret,
    );
  }
}

@JsonSerializable()
class AuthorModel {
  final String id;
  final String status;
  final String? bio;
  final int postCount;

  const AuthorModel({
    required this.id,
    required this.status,
    this.bio,
    this.postCount = 0,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);

  AuthorEntity toEntity() {
    return AuthorEntity(
      id: id,
      status: _parseAuthorStatus(status),
      bio: bio,
      postCount: postCount,
    );
  }

  factory AuthorModel.fromEntity(AuthorEntity entity) {
    return AuthorModel(
      id: entity.id,
      status: _authorStatusToString(entity.status),
      bio: entity.bio,
      postCount: entity.postCount,
    );
  }
}

// Helper functions
AuthorStatus _parseAuthorStatus(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return AuthorStatus.pending;
    case 'APPROVED':
      return AuthorStatus.approved;
    case 'REJECTED':
      return AuthorStatus.rejected;
    default:
      return AuthorStatus.pending;
  }
}

String _authorStatusToString(AuthorStatus status) {
  switch (status) {
    case AuthorStatus.pending:
      return 'PENDING';
    case AuthorStatus.approved:
      return 'APPROVED';
    case AuthorStatus.rejected:
      return 'REJECTED';
  }
}
