import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class NewsLoadRequested extends NewsEvent {
  const NewsLoadRequested({
    this.category,
    this.limit = 20,
    this.offset = 0,
  });

  final String? category;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [category, limit, offset];
}

class NewsRefreshRequested extends NewsEvent {
  const NewsRefreshRequested({
    this.category,
    this.limit = 20,
    this.offset = 0,
  });

  final String? category;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [category, limit, offset];
}

class NewsLoadMoreRequested extends NewsEvent {
  const NewsLoadMoreRequested({
    this.category,
    this.limit = 20,
  });

  final String? category;
  final int limit;

  @override
  List<Object?> get props => [category, limit];
}

class NewsSearchRequested extends NewsEvent {
  const NewsSearchRequested({
    required this.query,
    this.category,
    this.limit = 20,
    this.offset = 0,
  });

  final String query;
  final String? category;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [query, category, limit, offset];
}

class NewsCategoriesLoadRequested extends NewsEvent {
  const NewsCategoriesLoadRequested();
}

class NewsCategoryChanged extends NewsEvent {
  const NewsCategoryChanged({
    required this.category,
  });

  final String? category;

  @override
  List<Object?> get props => [category];
}

class NewsBookmarkRequested extends NewsEvent {
  const NewsBookmarkRequested({
    required this.newsId,
  });

  final String newsId;

  @override
  List<Object?> get props => [newsId];
}

class NewsRemoveBookmarkRequested extends NewsEvent {
  const NewsRemoveBookmarkRequested({
    required this.newsId,
  });

  final String newsId;

  @override
  List<Object?> get props => [newsId];
}

class NewsLoadBookmarkedRequested extends NewsEvent {
  const NewsLoadBookmarkedRequested();
}

class NewsLoadTrendingRequested extends NewsEvent {
  const NewsLoadTrendingRequested({
    this.limit = 10,
    this.offset = 0,
  });

  final int limit;
  final int offset;

  @override
  List<Object?> get props => [limit, offset];
}

class NewsTabChanged extends NewsEvent {
  const NewsTabChanged({
    required this.tabIndex,
  });

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}
