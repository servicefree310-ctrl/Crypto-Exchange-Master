import '../../domain/entities/blog_post_entity.dart';

class BlogPostModel extends BlogPostEntity {
  const BlogPostModel({
    required super.id,
    required super.title,
    required super.content,
    required super.slug,
    required super.status,
    super.description,
    super.image,
    super.views,
    super.categoryId,
    super.authorId,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    super.category,
    super.author,
    super.tags,
    super.comments,
    super.relatedPosts,
  });

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    return BlogPostModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      status: _parseStatus(json['status']),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      views:
          json['views'] != null ? int.tryParse(json['views'].toString()) : null,
      categoryId: json['categoryId']?.toString(),
      authorId: json['authorId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null,
      category: json['category'] != null
          ? BlogCategoryModel.fromJson(json['category'])
          : null,
      author: json['author'] != null
          ? BlogAuthorModel.fromJson(json['author'])
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List)
              .map((tag) => BlogTagModel.fromJson(tag))
              .toList()
          : [],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => BlogCommentModel.fromJson(comment))
              .toList()
          : [],
      relatedPosts: json['relatedPosts'] != null
          ? (json['relatedPosts'] as List)
              .map((post) => BlogPostModel.fromJson(post))
              .toList()
          : [],
    );
  }

  static PostStatus _parseStatus(dynamic status) {
    if (status == null) return PostStatus.draft;

    switch (status.toString().toUpperCase()) {
      case 'PUBLISHED':
        return PostStatus.published;
      case 'DRAFT':
        return PostStatus.draft;
      case 'TRASH':
        return PostStatus.trash;
      default:
        return PostStatus.draft;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'slug': slug,
      'status': status.name.toUpperCase(),
      'description': description,
      'image': image,
      'views': views,
      'categoryId': categoryId,
      'authorId': authorId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'category':
          category != null ? (category as BlogCategoryModel).toJson() : null,
      'author': author != null ? (author as BlogAuthorModel).toJson() : null,
      'tags': tags.map((tag) => (tag as BlogTagModel).toJson()).toList(),
      'comments': comments
          .map((comment) => (comment as BlogCommentModel).toJson())
          .toList(),
      'relatedPosts':
          relatedPosts.map((post) => (post as BlogPostModel).toJson()).toList(),
    };
  }
}

class BlogCategoryModel extends BlogCategoryEntity {
  const BlogCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.image,
    super.postCount,
    super.createdAt,
    super.updatedAt,
  });

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      postCount: json['postCount'] != null
          ? int.tryParse(json['postCount'].toString()) ?? 0
          : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'postCount': postCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class BlogTagModel extends BlogTagEntity {
  const BlogTagModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.postCount,
    super.createdAt,
    super.updatedAt,
  });

  factory BlogTagModel.fromJson(Map<String, dynamic> json) {
    return BlogTagModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      postCount: json['postCount'] != null
          ? int.tryParse(json['postCount'].toString()) ?? 0
          : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'postCount': postCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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

class BlogAuthorModel extends BlogAuthorEntity {
  const BlogAuthorModel({
    required super.id,
    required super.userId,
    super.bio,
    super.postCount,
    super.createdAt,
    super.updatedAt,
    super.user,
  });

  factory BlogAuthorModel.fromJson(Map<String, dynamic> json) {
    return BlogAuthorModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      bio: json['bio']?.toString(),
      postCount: json['postCount'] != null
          ? int.tryParse(json['postCount'].toString()) ?? 0
          : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      user: json['user'] != null ? BlogUserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bio': bio,
      'postCount': postCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user != null ? (user as BlogUserModel).toJson() : null,
    };
  }
}

class BlogCommentModel extends BlogCommentEntity {
  const BlogCommentModel({
    required super.id,
    required super.content,
    required super.postId,
    required super.userId,
    super.createdAt,
    super.updatedAt,
    super.user,
  });

  factory BlogCommentModel.fromJson(Map<String, dynamic> json) {
    return BlogCommentModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      user: json['user'] != null ? BlogUserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user != null ? (user as BlogUserModel).toJson() : null,
    };
  }
}

class BlogPaginationModel extends BlogPaginationEntity {
  const BlogPaginationModel({
    required super.currentPage,
    required super.perPage,
    required super.totalItems,
    required super.totalPages,
  });

  factory BlogPaginationModel.fromJson(Map<String, dynamic> json) {
    return BlogPaginationModel(
      currentPage: json['currentPage'] != null
          ? int.tryParse(json['currentPage'].toString()) ?? 1
          : 1,
      perPage: json['perPage'] != null
          ? int.tryParse(json['perPage'].toString()) ?? 10
          : 10,
      totalItems: json['totalItems'] != null
          ? int.tryParse(json['totalItems'].toString()) ?? 0
          : 0,
      totalPages: json['totalPages'] != null
          ? int.tryParse(json['totalPages'].toString()) ?? 1
          : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'perPage': perPage,
      'totalItems': totalItems,
      'totalPages': totalPages,
    };
  }
}

class BlogPostsResponseModel extends BlogPostsResponseEntity {
  const BlogPostsResponseModel({
    required super.data,
    required super.pagination,
  });

  factory BlogPostsResponseModel.fromJson(Map<String, dynamic> json) {
    // Support both { data: [...], pagination: {...} } and { items: [...], pagination: {...} }
    final postsJson = json['data'] ?? json['items'] ?? [];
    return BlogPostsResponseModel(
      data: postsJson is List
          ? postsJson.map((post) => BlogPostModel.fromJson(post)).toList()
          : [],
      pagination: json['pagination'] != null
          ? BlogPaginationModel.fromJson(json['pagination'])
          : const BlogPaginationModel(
              currentPage: 1, perPage: 10, totalItems: 0, totalPages: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((post) => (post as BlogPostModel).toJson()).toList(),
      'pagination': (pagination as BlogPaginationModel).toJson(),
    };
  }
}
