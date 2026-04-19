import '../../domain/entities/blog_author_entity.dart';

class BlogUserModel {
  const BlogUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    required this.role,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final BlogRoleModel role;

  factory BlogUserModel.fromJson(Map<String, dynamic> json) {
    return BlogUserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      role: BlogRoleModel.fromJson(json['role'] as Map<String, dynamic>),
    );
  }

  BlogUserEntity toEntity() {
    return BlogUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatar: avatar,
      role: role.toEntity(),
    );
  }
}

class BlogRoleModel {
  const BlogRoleModel({
    required this.name,
  });

  final String name;

  factory BlogRoleModel.fromJson(Map<String, dynamic> json) {
    return BlogRoleModel(
      name: json['name'] as String,
    );
  }

  BlogRoleEntity toEntity() {
    return BlogRoleEntity(
      name: name,
    );
  }
}

class BlogAuthorModel {
  const BlogAuthorModel({
    required this.id,
    required this.userId,
    required this.bio,
    required this.postCount,
    required this.user,
  });

  final String id;
  final String userId;
  final String bio;
  final int postCount;
  final BlogUserModel user;

  factory BlogAuthorModel.fromJson(Map<String, dynamic> json) {
    return BlogAuthorModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bio: json['bio'] as String,
      postCount: json['postCount'] as int? ?? 0,
      user: BlogUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  BlogAuthorEntity toEntity() {
    return BlogAuthorEntity(
      id: id,
      userId: userId,
      bio: bio,
      postCount: postCount,
      user: user.toEntity(),
    );
  }
}
