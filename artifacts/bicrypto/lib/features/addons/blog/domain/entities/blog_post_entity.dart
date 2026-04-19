import 'package:equatable/equatable.dart';

enum PostStatus { published, draft, trash }

class BlogPostEntity extends Equatable {
  const BlogPostEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.slug,
    required this.status,
    this.description,
    this.image,
    this.views,
    this.categoryId,
    this.authorId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.category,
    this.author,
    this.tags = const [],
    this.comments = const [],
    this.relatedPosts = const [],
  });

  final String id;
  final String title;
  final String content;
  final String slug;
  final PostStatus status;
  final String? description;
  final String? image;
  final int? views;
  final String? categoryId;
  final String? authorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final BlogCategoryEntity? category;
  final BlogAuthorEntity? author;
  final List<BlogTagEntity> tags;
  final List<BlogCommentEntity> comments;
  final List<BlogPostEntity> relatedPosts;

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        slug,
        status,
        description,
        image,
        views,
        categoryId,
        authorId,
        createdAt,
        updatedAt,
        deletedAt,
        category,
        author,
        tags,
        comments,
        relatedPosts,
      ];

  BlogPostEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? slug,
    PostStatus? status,
    String? description,
    String? image,
    int? views,
    String? categoryId,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    BlogCategoryEntity? category,
    BlogAuthorEntity? author,
    List<BlogTagEntity>? tags,
    List<BlogCommentEntity>? comments,
    List<BlogPostEntity>? relatedPosts,
  }) {
    return BlogPostEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      description: description ?? this.description,
      image: image ?? this.image,
      views: views ?? this.views,
      categoryId: categoryId ?? this.categoryId,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      category: category ?? this.category,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      relatedPosts: relatedPosts ?? this.relatedPosts,
    );
  }
}

class BlogCategoryEntity extends Equatable {
  const BlogCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.postCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final int postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        image,
        postCount,
        createdAt,
        updatedAt,
      ];
}

class BlogTagEntity extends Equatable {
  const BlogTagEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.postCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final int postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        postCount,
        createdAt,
        updatedAt,
      ];
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
  List<Object?> get props => [id, firstName, lastName, email, avatar, role];
}

class BlogRoleEntity extends Equatable {
  const BlogRoleEntity({
    required this.name,
  });

  final String name;

  @override
  List<Object?> get props => [name];
}

class BlogAuthorEntity extends Equatable {
  const BlogAuthorEntity({
    required this.id,
    required this.userId,
    this.bio,
    this.postCount = 0,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final String id;
  final String userId;
  final String? bio;
  final int postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BlogUserEntity? user;

  @override
  List<Object?> get props => [
        id,
        userId,
        bio,
        postCount,
        createdAt,
        updatedAt,
        user,
      ];
}

class BlogCommentEntity extends Equatable {
  const BlogCommentEntity({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final String id;
  final String content;
  final String postId;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BlogUserEntity? user;

  @override
  List<Object?> get props => [
        id,
        content,
        postId,
        userId,
        createdAt,
        updatedAt,
        user,
      ];
}

class BlogPaginationEntity extends Equatable {
  const BlogPaginationEntity({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
  });

  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  @override
  List<Object?> get props => [currentPage, perPage, totalItems, totalPages];
}

class BlogPostsResponseEntity extends Equatable {
  const BlogPostsResponseEntity({
    required this.data,
    required this.pagination,
  });

  final List<BlogPostEntity> data;
  final BlogPaginationEntity pagination;

  @override
  List<Object?> get props => [data, pagination];
}
