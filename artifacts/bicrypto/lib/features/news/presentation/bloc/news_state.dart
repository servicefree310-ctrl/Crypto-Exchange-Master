import 'package:equatable/equatable.dart';

import '../../domain/entities/news_entity.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsLoaded extends NewsState {
  const NewsLoaded({
    required this.news,
    required this.categories,
    required this.selectedCategory,
    required this.hasReachedMax,
    required this.isRefreshing,
    required this.bookmarkedIds,
  });

  final List<NewsEntity> news;
  final List<NewsCategoryEntity> categories;
  final String? selectedCategory;
  final bool hasReachedMax;
  final bool isRefreshing;
  final List<String> bookmarkedIds;

  @override
  List<Object?> get props => [
        news,
        categories,
        selectedCategory,
        hasReachedMax,
        isRefreshing,
        bookmarkedIds,
      ];

  NewsLoaded copyWith({
    List<NewsEntity>? news,
    List<NewsCategoryEntity>? categories,
    String? selectedCategory,
    bool? hasReachedMax,
    bool? isRefreshing,
    List<String>? bookmarkedIds,
  }) {
    return NewsLoaded(
      news: news ?? this.news,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
    );
  }
}

class NewsSearchLoaded extends NewsState {
  const NewsSearchLoaded({
    required this.news,
    required this.query,
    required this.hasReachedMax,
    required this.isRefreshing,
    required this.bookmarkedIds,
  });

  final List<NewsEntity> news;
  final String query;
  final bool hasReachedMax;
  final bool isRefreshing;
  final List<String> bookmarkedIds;

  @override
  List<Object?> get props =>
      [news, query, hasReachedMax, isRefreshing, bookmarkedIds];

  NewsSearchLoaded copyWith({
    List<NewsEntity>? news,
    String? query,
    bool? hasReachedMax,
    bool? isRefreshing,
    List<String>? bookmarkedIds,
  }) {
    return NewsSearchLoaded(
      news: news ?? this.news,
      query: query ?? this.query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
    );
  }
}

class NewsTrendingLoaded extends NewsState {
  const NewsTrendingLoaded({
    required this.news,
    required this.hasReachedMax,
    required this.isRefreshing,
    required this.bookmarkedIds,
  });

  final List<NewsEntity> news;
  final bool hasReachedMax;
  final bool isRefreshing;
  final List<String> bookmarkedIds;

  @override
  List<Object?> get props => [news, hasReachedMax, isRefreshing, bookmarkedIds];

  NewsTrendingLoaded copyWith({
    List<NewsEntity>? news,
    bool? hasReachedMax,
    bool? isRefreshing,
    List<String>? bookmarkedIds,
  }) {
    return NewsTrendingLoaded(
      news: news ?? this.news,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
    );
  }
}

class NewsBookmarkedLoaded extends NewsState {
  const NewsBookmarkedLoaded({
    required this.news,
    required this.isRefreshing,
    required this.bookmarkedIds,
  });

  final List<NewsEntity> news;
  final bool isRefreshing;
  final List<String> bookmarkedIds;

  @override
  List<Object?> get props => [news, isRefreshing, bookmarkedIds];

  NewsBookmarkedLoaded copyWith({
    List<NewsEntity>? news,
    bool? isRefreshing,
    List<String>? bookmarkedIds,
  }) {
    return NewsBookmarkedLoaded(
      news: news ?? this.news,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
    );
  }
}

class NewsError extends NewsState {
  const NewsError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

class NewsEmpty extends NewsState {
  const NewsEmpty({
    this.message = 'No news found',
  });

  final String message;

  @override
  List<Object?> get props => [message];
}
