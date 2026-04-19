import 'package:equatable/equatable.dart';

abstract class BlogState extends Equatable {
  const BlogState();

  @override
  List<Object?> get props => [];
}

class BlogInitial extends BlogState {
  const BlogInitial();
}

class BlogLoading extends BlogState {
  const BlogLoading();
}

class BlogPostsLoaded extends BlogState {
  final List<Map<String, dynamic>> posts;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;

  const BlogPostsLoaded({
    required this.posts,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [posts, hasReachedMax, currentPage, isLoadingMore];

  BlogPostsLoaded copyWith({
    List<Map<String, dynamic>>? posts,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return BlogPostsLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class BlogPostLoaded extends BlogState {
  final Map<String, dynamic> post;

  const BlogPostLoaded({required this.post});

  @override
  List<Object?> get props => [post];
}

class BlogCategoriesLoaded extends BlogState {
  final List<Map<String, dynamic>> categories;

  const BlogCategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class BlogTagsLoaded extends BlogState {
  final List<Map<String, dynamic>> tags;

  const BlogTagsLoaded({required this.tags});

  @override
  List<Object?> get props => [tags];
}

class BlogAuthorsLoaded extends BlogState {
  final List<Map<String, dynamic>> authors;

  const BlogAuthorsLoaded({required this.authors});

  @override
  List<Object?> get props => [authors];
}

class BlogFeaturedPostsLoaded extends BlogState {
  final List<Map<String, dynamic>> featuredPosts;

  const BlogFeaturedPostsLoaded({required this.featuredPosts});

  @override
  List<Object?> get props => [featuredPosts];
}

class BlogError extends BlogState {
  final String message;

  const BlogError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BlogSearchResultsLoaded extends BlogState {
  final List<Map<String, dynamic>> searchResults;
  final String query;
  final bool hasReachedMax;
  final int currentPage;

  const BlogSearchResultsLoaded({
    required this.searchResults,
    required this.query,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [searchResults, query, hasReachedMax, currentPage];

  BlogSearchResultsLoaded copyWith({
    List<Map<String, dynamic>>? searchResults,
    String? query,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return BlogSearchResultsLoaded(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
