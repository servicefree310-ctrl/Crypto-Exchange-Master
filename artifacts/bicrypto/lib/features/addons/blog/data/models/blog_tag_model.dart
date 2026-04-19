import '../../domain/entities/blog_tag_entity.dart';

class BlogTagModel {
  const BlogTagModel({
    required this.id,
    required this.name,
    required this.slug,
    this.postCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final int postCount;

  factory BlogTagModel.fromJson(Map<String, dynamic> json) {
    return BlogTagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      postCount: json['postCount'] as int? ?? 0,
    );
  }

  BlogTagEntity toEntity() {
    return BlogTagEntity(
      id: id,
      name: name,
      slug: slug,
      postCount: postCount,
    );
  }
}
