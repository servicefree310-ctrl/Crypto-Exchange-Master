import 'package:equatable/equatable.dart';
import 'blog_author_entity.dart';

class BlogCommentEntity extends Equatable {
  const BlogCommentEntity({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.parentId,
    this.deletedAt,
  });

  final String id;
  final String content;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BlogUserEntity? user;
  final String? parentId;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        content,
        postId,
        userId,
        createdAt,
        updatedAt,
        user,
        parentId,
        deletedAt,
      ];

  BlogCommentEntity copyWith({
    String? id,
    String? content,
    String? postId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    BlogUserEntity? user,
    String? parentId,
    DateTime? deletedAt,
  }) {
    return BlogCommentEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      parentId: parentId ?? this.parentId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
