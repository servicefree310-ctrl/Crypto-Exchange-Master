import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../data/datasources/blog_remote_datasource.dart';
import '../../domain/entities/blog_post_entity.dart';
import '../../../../../core/errors/failures.dart';

// Events
abstract class BlogEvent extends Equatable {
  const BlogEvent();

  @override
  List<Object?> get props => [];
}

class BlogLoadPostsRequested extends BlogEvent {
  const BlogLoadPostsRequested({
    this.page = 1,
    this.category,
    this.tag,
    this.search,
    this.refresh = false,
  });

  final int page;
  final String? category;
  final String? tag;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [page, category, tag, search, refresh];
}

class BlogLoadPostRequested extends BlogEvent {
  const BlogLoadPostRequested(this.slug);

  final String slug;

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

class BlogLoadCommentsRequested extends BlogEvent {
  const BlogLoadCommentsRequested(this.postId);

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class BlogSearchRequested extends BlogEvent {
  const BlogSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class BlogRefreshRequested extends BlogEvent {
  const BlogRefreshRequested();
}

class BlogLoadMoreRequested extends BlogEvent {
  const BlogLoadMoreRequested();
}

class BlogAddCommentRequested extends BlogEvent {
  const BlogAddCommentRequested(
      {required this.postId, required this.content, required this.userId});
  final String postId;
  final String content;
  final String userId;
  @override
  List<Object?> get props => [postId, content, userId];
}

// States
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
  const BlogPostsLoaded({
    required this.posts,
    required this.pagination,
    this.categories = const [],
    this.tags = const [],
    this.authors = const [],
    this.hasReachedMax = false,
  });

  final List<BlogPostEntity> posts;
  final BlogPaginationEntity pagination;
  final List<BlogCategoryEntity> categories;
  final List<BlogTagEntity> tags;
  final List<BlogAuthorEntity> authors;
  final bool hasReachedMax;

  @override
  List<Object?> get props =>
      [posts, pagination, categories, tags, authors, hasReachedMax];

  BlogPostsLoaded copyWith({
    List<BlogPostEntity>? posts,
    BlogPaginationEntity? pagination,
    List<BlogCategoryEntity>? categories,
    List<BlogTagEntity>? tags,
    List<BlogAuthorEntity>? authors,
    bool? hasReachedMax,
  }) {
    return BlogPostsLoaded(
      posts: posts ?? this.posts,
      pagination: pagination ?? this.pagination,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      authors: authors ?? this.authors,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class BlogPostLoaded extends BlogState {
  const BlogPostLoaded({
    required this.post,
    this.comments = const [],
  });

  final BlogPostEntity post;
  final List<BlogCommentEntity> comments;

  @override
  List<Object?> get props => [post, comments];
}

class BlogError extends BlogState {
  const BlogError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class BlogLoadingMore extends BlogState {
  const BlogLoadingMore({
    required this.posts,
    required this.pagination,
    this.categories = const [],
    this.tags = const [],
    this.authors = const [],
  });

  final List<BlogPostEntity> posts;
  final BlogPaginationEntity pagination;
  final List<BlogCategoryEntity> categories;
  final List<BlogTagEntity> tags;
  final List<BlogAuthorEntity> authors;

  @override
  List<Object?> get props => [posts, pagination, categories, tags, authors];
}

// BLoC
@injectable
class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final BlogRemoteDataSource _dataSource;

  // Current filter state
  String? _currentCategory;
  String? _currentTag;
  String? _currentSearch;
  int _currentPage = 1;
  List<BlogPostEntity> _allPosts = [];
  BlogPaginationEntity? _pagination;
  List<BlogCategoryEntity> _categories = [];
  List<BlogTagEntity> _tags = [];
  List<BlogAuthorEntity> _authors = [];

  BlogBloc(this._dataSource) : super(const BlogInitial()) {
    on<BlogLoadPostsRequested>(_onLoadPosts);
    on<BlogLoadPostRequested>(_onLoadPost);
    on<BlogLoadCategoriesRequested>(_onLoadCategories);
    on<BlogLoadTagsRequested>(_onLoadTags);
    on<BlogLoadAuthorsRequested>(_onLoadAuthors);
    on<BlogLoadCommentsRequested>(_onLoadComments);
    on<BlogSearchRequested>(_onSearch);
    on<BlogRefreshRequested>(_onRefresh);
    on<BlogLoadMoreRequested>(_onLoadMore);
    on<BlogAddCommentRequested>(_onAddComment);
  }

  Future<void> _onLoadPosts(
      BlogLoadPostsRequested event, Emitter<BlogState> emit) async {
    try {
      if (event.refresh || state is BlogInitial) {
        emit(const BlogLoading());
        _currentPage = 1;
        _allPosts.clear();
      }

      _currentCategory = event.category;
      _currentTag = event.tag;
      _currentSearch = event.search;

      final response = await _dataSource.getPosts(
        page: event.page,
        category: event.category,
        tag: event.tag,
        search: event.search,
      );

      if (event.page == 1) {
        _allPosts = response.data;
      } else {
        _allPosts.addAll(response.data);
      }

      _pagination = response.pagination;
      _currentPage = response.pagination.currentPage;

      emit(BlogPostsLoaded(
        posts: _allPosts,
        pagination: response.pagination,
        categories: _categories,
        tags: _tags,
        authors: _authors,
        hasReachedMax: !response.pagination.hasNextPage,
      ));
    } catch (e) {
      emit(BlogError(failure: ServerFailure(e.toString())));
    }
  }

  Future<void> _onLoadPost(
      BlogLoadPostRequested event, Emitter<BlogState> emit) async {
    try {
      emit(const BlogLoading());

      final post = await _dataSource.getPost(event.slug);

      // Load comments if post has any
      List<BlogCommentEntity> comments = [];
      if (post.comments.isNotEmpty) {
        try {
          comments = await _dataSource.getPostComments(post.id);
        } catch (e) {
          // Comments loading failed, but post loaded successfully
          dev.log('Failed to load comments: $e');
        }
      }

      emit(BlogPostLoaded(post: post, comments: comments));
    } catch (e) {
      emit(BlogError(failure: ServerFailure(e.toString())));
    }
  }

  Future<void> _onLoadCategories(
      BlogLoadCategoriesRequested event, Emitter<BlogState> emit) async {
    try {
      _categories = await _dataSource.getCategories();

      if (state is BlogPostsLoaded) {
        final currentState = state as BlogPostsLoaded;
        emit(currentState.copyWith(categories: _categories));
      }
    } catch (e) {
      // Don't emit error for categories, just log it
      dev.log('Failed to load categories: $e');
    }
  }

  Future<void> _onLoadTags(
      BlogLoadTagsRequested event, Emitter<BlogState> emit) async {
    try {
      _tags = await _dataSource.getTags();

      if (state is BlogPostsLoaded) {
        final currentState = state as BlogPostsLoaded;
        emit(currentState.copyWith(tags: _tags));
      }
    } catch (e) {
      // Don't emit error for tags, just log it
      dev.log('Failed to load tags: $e');
    }
  }

  Future<void> _onLoadAuthors(
      BlogLoadAuthorsRequested event, Emitter<BlogState> emit) async {
    try {
      _authors = await _dataSource.getTopAuthors();

      if (state is BlogPostsLoaded) {
        final currentState = state as BlogPostsLoaded;
        emit(currentState.copyWith(authors: _authors));
      }
    } catch (e) {
      // Don't emit error for authors, just log it
      dev.log('Failed to load authors: $e');
    }
  }

  Future<void> _onLoadComments(
      BlogLoadCommentsRequested event, Emitter<BlogState> emit) async {
    try {
      final comments = await _dataSource.getPostComments(event.postId);

      if (state is BlogPostLoaded) {
        final currentState = state as BlogPostLoaded;
        emit(BlogPostLoaded(post: currentState.post, comments: comments));
      }
    } catch (e) {
      // Don't emit error for comments, just log it
      dev.log('Failed to load comments: $e');
    }
  }

  Future<void> _onSearch(
      BlogSearchRequested event, Emitter<BlogState> emit) async {
    add(BlogLoadPostsRequested(search: event.query, refresh: true));
  }

  Future<void> _onRefresh(
      BlogRefreshRequested event, Emitter<BlogState> emit) async {
    add(BlogLoadPostsRequested(
      category: _currentCategory,
      tag: _currentTag,
      search: _currentSearch,
      refresh: true,
    ));
  }

  Future<void> _onLoadMore(
      BlogLoadMoreRequested event, Emitter<BlogState> emit) async {
    if (state is BlogPostsLoaded) {
      final currentState = state as BlogPostsLoaded;
      if (!currentState.hasReachedMax) {
        emit(BlogLoadingMore(
          posts: currentState.posts,
          pagination: currentState.pagination,
          categories: currentState.categories,
          tags: currentState.tags,
          authors: currentState.authors,
        ));

        try {
          final nextPage = _currentPage + 1;
          final response = await _dataSource.getPosts(
            page: nextPage,
            category: _currentCategory,
            tag: _currentTag,
            search: _currentSearch,
          );

          _allPosts.addAll(response.data);
          _pagination = response.pagination;
          _currentPage = response.pagination.currentPage;

          emit(BlogPostsLoaded(
            posts: _allPosts,
            pagination: response.pagination,
            categories: _categories,
            tags: _tags,
            authors: _authors,
            hasReachedMax: !response.pagination.hasNextPage,
          ));
        } catch (e) {
          emit(BlogError(failure: ServerFailure(e.toString())));
        }
      }
    }
  }

  Future<void> _onAddComment(
      BlogAddCommentRequested event, Emitter<BlogState> emit) async {
    if (state is! BlogPostLoaded) return;
    final current = state as BlogPostLoaded;
    try {
      final newComment = await _dataSource.addComment(
        postId: event.postId,
        content: event.content,
        userId: event.userId,
      );
      emit(BlogPostLoaded(
          post: current.post, comments: [...current.comments, newComment]));
    } catch (e) {
      // optionally emit error snack via other mechanism
    }
  }
}
