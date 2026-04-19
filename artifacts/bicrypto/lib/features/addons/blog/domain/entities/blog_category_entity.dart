import 'package:equatable/equatable.dart';

class BlogCategoryEntity extends Equatable {
  const BlogCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.postCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final int postCount;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        image,
        description,
        postCount,
      ];

  BlogCategoryEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? image,
    String? description,
    int? postCount,
  }) {
    return BlogCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      description: description ?? this.description,
      postCount: postCount ?? this.postCount,
    );
  }
}
