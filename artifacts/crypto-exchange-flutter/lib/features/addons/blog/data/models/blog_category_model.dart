import '../../domain/entities/blog_category_entity.dart';

class BlogCategoryModel {
  const BlogCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.postCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final int postCount;

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      postCount: json['postCount'] as int? ?? 0,
    );
  }

  BlogCategoryEntity toEntity() {
    return BlogCategoryEntity(
      id: id,
      name: name,
      slug: slug,
      description: description,
      image: image,
      postCount: postCount,
    );
  }
}
