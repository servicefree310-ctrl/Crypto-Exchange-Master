import 'package:equatable/equatable.dart';

abstract class BlogEvent extends Equatable {
  const BlogEvent();

  @override
  List<Object?> get props => [];
}

class BlogLoadPostsRequested extends BlogEvent {
  final int page;
  final int limit;
  final String? category;
  final String? tag;
  final String? search;

  const BlogLoadPostsRequested({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.tag,
    this.search,
  });

  @override
  List<Object?> get props => [page, limit, category, tag, search];
}

class BlogLoadPostRequested extends BlogEvent {
  final String slug;

  const BlogLoadPostRequested({required this.slug});

  @override
  List<Object?> get props => [slug];
}

class BlogLoadCategoriesRequested extends BlogEvent {
  const BlogLoadCategoriesRequested();
}

class BlogLoadTagsRequested extends BlogEvent {
  const BlogLoadTagsRequested();
}

class BlogLoadAuthorsRequested extends BlogEvent {
  const BlogLoadAuthorsRequested();
}

class BlogLoadFeaturedPostsRequested extends BlogEvent {
  const BlogLoadFeaturedPostsRequested();
}

class BlogSearchPostsRequested extends BlogEvent {
  final String query;
  final int page;
  final int limit;

  const BlogSearchPostsRequested({
    required this.query,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

class BlogRefreshRequested extends BlogEvent {
  const BlogRefreshRequested();
}

class BlogLoadMorePostsRequested extends BlogEvent {
  const BlogLoadMorePostsRequested();
}
