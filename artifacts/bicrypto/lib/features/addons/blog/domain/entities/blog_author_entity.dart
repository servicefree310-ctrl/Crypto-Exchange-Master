import 'package:equatable/equatable.dart';

class BlogAuthorEntity extends Equatable {
  const BlogAuthorEntity({
    required this.id,
    required this.userId,
    this.user,
    this.bio,
    this.postCount = 0,
  });

  final String id;
  final String userId;
  final BlogUserEntity? user;
  final String? bio;
  final int postCount;

  @override
  List<Object?> get props => [
        id,
        userId,
        user,
        bio,
        postCount,
      ];

  BlogAuthorEntity copyWith({
    String? id,
    String? userId,
    BlogUserEntity? user,
    String? bio,
    int? postCount,
  }) {
    return BlogAuthorEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      bio: bio ?? this.bio,
      postCount: postCount ?? this.postCount,
    );
  }
}

class BlogUserEntity extends Equatable {
  const BlogUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.role,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final BlogRoleEntity? role;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        avatar,
        role,
      ];

  BlogUserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    BlogRoleEntity? role,
  }) {
    return BlogUserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
    );
  }
}

class BlogRoleEntity extends Equatable {
  const BlogRoleEntity({
    required this.name,
  });

  final String name;

  @override
  List<Object?> get props => [name];

  BlogRoleEntity copyWith({
    String? name,
  }) {
    return BlogRoleEntity(
      name: name ?? this.name,
    );
  }
}
