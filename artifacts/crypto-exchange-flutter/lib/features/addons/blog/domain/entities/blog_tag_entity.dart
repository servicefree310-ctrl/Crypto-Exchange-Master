import 'package:equatable/equatable.dart';

class BlogTagEntity extends Equatable {
  const BlogTagEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.postCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final int postCount;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        postCount,
      ];

  BlogTagEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    int? postCount,
  }) {
    return BlogTagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      postCount: postCount ?? this.postCount,
    );
  }
}
