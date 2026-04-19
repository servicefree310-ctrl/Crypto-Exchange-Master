import '../../domain/entities/blog_comment_entity.dart';
import '../../domain/entities/blog_author_entity.dart';

class BlogCommentModel extends BlogCommentEntity {
  const BlogCommentModel({
    required super.id,
    required super.content,
    required super.postId,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    super.user,
    super.parentId,
    super.deletedAt,
  });

  factory BlogCommentModel.fromJson(Map<String, dynamic> json) {
    return BlogCommentModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      user: json['user'] != null ? BlogUserModel.fromJson(json['user']) : null,
      parentId: json['parentId']?.toString(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user != null ? (user as BlogUserModel).toJson() : null,
      'parentId': parentId,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

class BlogUserModel extends BlogUserEntity {
  const BlogUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.avatar,
    super.role,
  });

  factory BlogUserModel.fromJson(Map<String, dynamic> json) {
    return BlogUserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      role: json['role'] != null ? BlogRoleModel.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatar': avatar,
      'role': role != null ? (role as BlogRoleModel).toJson() : null,
    };
  }
}

class BlogRoleModel extends BlogRoleEntity {
  const BlogRoleModel({
    required super.name,
  });

  factory BlogRoleModel.fromJson(Map<String, dynamic> json) {
    return BlogRoleModel(
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
