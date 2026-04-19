import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/usecases/get_latest_news_usecase.dart';
import '../../domain/usecases/get_trending_news_usecase.dart';
import '../../domain/usecases/search_news_usecase.dart';
import '../../domain/usecases/get_news_categories_usecase.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

@injectable
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc(
    this._getLatestNewsUseCase,
    this._getTrendingNewsUseCase,
    this._searchNewsUseCase,
    this._getNewsCategoriesUseCase,
    this._newsRepository,
  ) : super(const NewsInitial()) {
    on<NewsLoadRequested>(_onNewsLoadRequested);
    on<NewsRefreshRequested>(_onNewsRefreshRequested);
    on<NewsLoadMoreRequested>(_onNewsLoadMoreRequested);
    on<NewsSearchRequested>(_onNewsSearchRequested);
    on<NewsCategoriesLoadRequested>(_onNewsCategoriesLoadRequested);
    on<NewsCategoryChanged>(_onNewsCategoryChanged);
    on<NewsBookmarkRequested>(_onNewsBookmarkRequested);
    on<NewsRemoveBookmarkRequested>(_onNewsRemoveBookmarkRequested);
    on<NewsLoadBookmarkedRequested>(_onNewsLoadBookmarkedRequested);
    on<NewsLoadTrendingRequested>(_onNewsLoadTrendingRequested);
    on<NewsTabChanged>(_onNewsTabChanged);

    // Initialize bookmarked IDs
    _initializeBookmarkedIds();
  }

  final GetLatestNewsUseCase _getLatestNewsUseCase;
  final GetTrendingNewsUseCase _getTrendingNewsUseCase;
  final SearchNewsUseCase _searchNewsUseCase;
  final GetNewsCategoriesUseCase _getNewsCategoriesUseCase;
  final NewsRepository _newsRepository;

  // Separate caches for different tabs and categories
  List<NewsEntity> _latestNews = [];
  List<NewsEntity> _trendingNews = [];
  List<NewsEntity> _bookmarkedNews = [];
  final List<NewsEntity> _categorizedNews = []; // Separate cache for categories
  List<NewsCategoryEntity> _categories = [];

  // Category-specific caches
  final Map<String, List<NewsEntity>> _categoryNewsCache = {};
  final Map<String, DateTime> _categoryCacheTimes = {};

  String? _selectedCategory;
  int _currentOffset = 0;
  int _categoryOffset = 0; // Separate offset for categories
  bool _hasReachedMax = false;
  bool _categoryHasReachedMax = false; // Separate flag for categories
  List<String> _bookmarkedIds = [];

  // Cache timestamps for validation
  DateTime? _latestNewsCacheTime;
  DateTime? _trendingNewsCacheTime;
  DateTime? _bookmarkedNewsCacheTime;
  DateTime? _categoriesCacheTime;

  // Cache expiry duration (5 minutes)
  static const Duration _cacheExpiryDuration = Duration(minutes: 5);

  // Current active tab
  int _currentTabIndex = 0;

  // Initialize bookmarked IDs from local storage
  Future<void> _initializeBookmarkedIds() async {
    try {
      final result = await _newsRepository.getBookmarkedNews();
      result.fold(
        (failure) => null, // Ignore failures during initialization
        (news) {
          _bookmarkedIds = news.map((n) => n.id).toList();
          _bookmarkedNews = news;
          _bookmarkedNewsCacheTime = DateTime.now();
        },
      );
    } catch (e) {
      // Ignore initialization errors
    }
  }

  // Check if cache is still valid
  bool _isCacheValid(DateTime? cacheTime) {
    if (cacheTime == null) return false;
    return DateTime.now().difference(cacheTime) < _cacheExpiryDuration;
  }

  // Check if category cache is valid
  bool _isCategoryCacheValid(String category) {
    final cacheTime = _categoryCacheTimes[category];
    return cacheTime != null && _isCacheValid(cacheTime);
  }

  Future<void> _onNewsLoadRequested(
    NewsLoadRequested event,
    Emitter<NewsState> emit,
  ) async {
    // If this is a category request, check category cache first
    if (event.category != null) {
      final categoryKey = event.category!;
      if (_categoryNewsCache.containsKey(categoryKey) &&
          _isCategoryCacheValid(categoryKey)) {
        final cachedNews = _categoryNewsCache[categoryKey]!;
        emit(NewsLoaded(
          news: cachedNews,
          categories: _categories,
          selectedCategory: event.category,
          hasReachedMax: cachedNews.length < event.limit,
          isRefreshing: false,
          bookmarkedIds: _bookmarkedIds,
        ));
        return;
      }
    } else {
      // Check if we have valid cached data for latest news (no category filter)
      if (_latestNews.isNotEmpty && _isCacheValid(_latestNewsCacheTime)) {
        emit(NewsLoaded(
          news: _latestNews,
          categories: _categories,
          selectedCategory: _selectedCategory,
          hasReachedMax: _hasReachedMax,
          isRefreshing: false,
          bookmarkedIds: _bookmarkedIds,
        ));
        return;
      }
    }

    emit(const NewsLoading());

    final result = await _getLatestNewsUseCase(
      GetLatestNewsParams(
        category: event.category,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (news) {
        if (event.category != null) {
          // Cache category-specific data
          final categoryKey = event.category!;
          _categoryNewsCache[categoryKey] = news;
          _categoryCacheTimes[categoryKey] = DateTime.now();
          _categoryOffset = event.offset + news.length;
          _categoryHasReachedMax = news.length < event.limit;
        } else {
          // Cache latest news data
          _latestNews = news;
          _latestNewsCacheTime = DateTime.now();
          _currentOffset = event.offset + news.length;
          _hasReachedMax = news.length < event.limit;
        }

        _selectedCategory = event.category;

        emit(NewsLoaded(
          news: news,
          categories: _categories,
          selectedCategory: _selectedCategory,
          hasReachedMax:
              event.category != null ? _categoryHasReachedMax : _hasReachedMax,
          isRefreshing: false,
          bookmarkedIds: _bookmarkedIds,
        ));
      },
    );
  }

  Future<void> _onNewsRefreshRequested(
    NewsRefreshRequested event,
    Emitter<NewsState> emit,
  ) async {
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await _getLatestNewsUseCase(
      GetLatestNewsParams(
        category: event.category ?? _selectedCategory,
        limit: event.limit,
        offset: 0,
      ),
    );

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (news) {
        if (event.category != null || _selectedCategory != null) {
          // Update category cache
          final categoryKey = event.category ?? _selectedCategory ?? 'all';
          _categoryNewsCache[categoryKey] = news;
          _categoryCacheTimes[categoryKey] = DateTime.now();
          _categoryOffset = news.length;
          _categoryHasReachedMax = news.length < event.limit;
        } else {
          // Update latest news cache
          _latestNews = news;
          _latestNewsCacheTime = DateTime.now();
          _currentOffset = news.length;
          _hasReachedMax = news.length < event.limit;
        }

        _selectedCategory = event.category ?? _selectedCategory;

        emit(NewsLoaded(
          news: news,
          categories: _categories,
          selectedCategory: _selectedCategory,
          hasReachedMax: (event.category != null || _selectedCategory != null)
              ? _categoryHasReachedMax
              : _hasReachedMax,
          isRefreshing: false,
          bookmarkedIds: _bookmarkedIds,
        ));
      },
    );
  }

  Future<void> _onNewsLoadMoreRequested(
    NewsLoadMoreRequested event,
    Emitter<NewsState> emit,
  ) async {
    final hasReachedMax = (event.category != null || _selectedCategory != null)
        ? _categoryHasReachedMax
        : _hasReachedMax;
    if (hasReachedMax) return;

    final currentOffset = (event.category != null || _selectedCategory != null)
        ? _categoryOffset
        : _currentOffset;
    final category = event.category ?? _selectedCategory;

    final result = await _getLatestNewsUseCase(
      GetLatestNewsParams(
        category: category,
        limit: event.limit,
        offset: currentOffset,
      ),
    );

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (news) {
        if (category != null) {
          // Update category cache
          final categoryKey = category;
          final existingNews = _categoryNewsCache[categoryKey] ?? [];
          existingNews.addAll(news);
          _categoryNewsCache[categoryKey] = existingNews;
          _categoryOffset += news.length;
          _categoryHasReachedMax = news.length < event.limit;
        } else {
          // Update latest news cache
          _latestNews.addAll(news);
          _currentOffset += news.length;
          _hasReachedMax = news.length < event.limit;
        }

        final currentNews =
            category != null ? _categoryNewsCache[category] ?? [] : _latestNews;

        emit(NewsLoaded(
          news: currentNews,
          categories: _categories,
          selectedCategory: _selectedCategory,
          hasReachedMax:
              category != null ? _categoryHasReachedMax : _hasReachedMax,
          isRefreshing: false,
          bookmarkedIds: _bookmarkedIds,
        ));
      },
    );
  }

  Future<void> _onNewsSearchRequested(
    NewsSearchRequested event,
    Emitter<NewsState> emit,
  ) async {
    emit(const NewsLoading());

    final result = await _searchNewsUseCase(
      SearchNewsParams(
        query: event.query,
        category: event.category,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (news) {
        if (news.isEmpty) {
          emit(const NewsEmpty(message: 'No news found for your search'));
        } else {
          emit(NewsSearchLoaded(
            news: news,
            query: event.query,
            hasReachedMax: news.length < event.limit,
            isRefreshing: false,
            bookmarkedIds: _bookmarkedIds,
          ));
        }
      },
    );
  }

  Future<void> _onNewsCategoriesLoadRequested(
    NewsCategoriesLoadRequested event,
    Emitter<NewsState> emit,
  ) async {
    // Check if we have valid cached categories
    if (_categories.isNotEmpty && _isCacheValid(_categoriesCacheTime)) {
      if (state is NewsLoaded) {
        final currentState = state as NewsLoaded;
        emit(currentState.copyWith(categories: _categories));
      }
      return;
    }

    final result = await _getNewsCategoriesUseCase(const NoParams());

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (categories) {
        _categories = categories;
        _categoriesCacheTime = DateTime.now();
        if (state is NewsLoaded) {
          final currentState = state as NewsLoaded;
          emit(currentState.copyWith(categories: categories));
        }
      },
    );
  }

  Future<void> _onNewsCategoryChanged(
    NewsCategoryChanged event,
    Emitter<NewsState> emit,
  ) async {
    _selectedCategory = event.category;
    _categoryOffset = 0;
    _categoryHasReachedMax = false;

    // Check if we have cached data for this category
    final categoryKey = event.category ?? 'all';
    if (_categoryNewsCache.containsKey(categoryKey) &&
        _isCategoryCacheValid(categoryKey)) {
      final cachedNews = _categoryNewsCache[categoryKey]!;
      emit(NewsLoaded(
        news: cachedNews,
        categories: _categories,
        selectedCategory: _selectedCategory,
        hasReachedMax: cachedNews.length < 20,
        isRefreshing: false,
        bookmarkedIds: _bookmarkedIds,
      ));
      return;
    }

    // Load new category data
    emit(const NewsLoading());

    final result = await _getLatestNewsUseCase(
      GetLatestNewsParams(
        category: event.category,
        limit: 20,
        offset: 0,
      ),
    );

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (news) {
        // Cache category-specific data
        final categoryKey = event.category ?? 'all';
        _categoryNewsCache[categoryKey] = news;
        _categoryCacheTimes[categoryKey] = DateTime.now();
        _categoryOffset = news.length;
        _categoryHasReachedMax = news.length < 20;

        emit(NewsLoaded(
          news: news,
          categories: _categories,
          selectedCategory: _selectedCategory,
          hasReachedMax: _categoryHasReachedMax,
          isRefreshing: false,
          bookmarkedIds: _bookmarkedIds,
        ));
      },
    );
  }

  Future<void> _onNewsBookmarkRequested(
    NewsBookmarkRequested event,
    Emitter<NewsState> emit,
  ) async {
    final result = await _newsRepository.bookmarkNews(event.newsId);

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (_) {
        if (!_bookmarkedIds.contains(event.newsId)) {
          _bookmarkedIds.add(event.newsId);
        }
        _updateBookmarkedState();
      },
    );
  }

  Future<void> _onNewsRemoveBookmarkRequested(
    NewsRemoveBookmarkRequested event,
    Emitter<NewsState> emit,
  ) async {
    final result = await _newsRepository.removeBookmark(event.newsId);

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (_) {
        _bookmarkedIds.remove(event.newsId);
        // Also remove from bookmarked news cache if present
        _bookmarkedNews.removeWhere((news) => news.id == event.newsId);
        _updateBookmarkedState();
      },
    );
  }

  Future<void> _onNewsLoadBookmarkedRequested(
    NewsLoadBookmarkedRequested event,
    Emitter<NewsState> emit,
  ) async {
    // Check if we have valid cached bookmarked news
    if (_bookmarkedNews.isNotEmpty && _isCacheValid(_bookmarkedNewsCacheTime)) {
      emit(NewsBookmarkedLoaded(
        news: _bookmarkedNews,
        isRefreshing: false,
        bookmarkedIds: _bookmarkedIds,
      ));
      return;
    }

    emit(const NewsLoading());

    final result = await _newsRepository.getBookmarkedNews();

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (news) {
        _bookmarkedNews = news;
        _bookmarkedNewsCacheTime = DateTime.now();

        // Update bookmarked IDs from the loaded news
        _bookmarkedIds = news.map((n) => n.id).toList();

        if (news.isEmpty) {
          emit(const NewsEmpty(message: 'No bookmarked news found'));
        } else {
          emit(NewsBookmarkedLoaded(
            news: _bookmarkedNews,
            isRefreshing: false,
            bookmarkedIds: _bookmarkedIds,
          ));
        }
      },
    );
  }

  Future<void> _onNewsLoadTrendingRequested(
    NewsLoadTrendingRequested event,
    Emitter<NewsState> emit,
  ) async {
    // Check if we have valid cached trending news
    if (_trendingNews.isNotEmpty && _isCacheValid(_trendingNewsCacheTime)) {
      emit(NewsTrendingLoaded(
        news: _trendingNews,
        hasReachedMax: _trendingNews.length < event.limit,
        isRefreshing: false,
        bookmarkedIds: _bookmarkedIds,
      ));
      return;
    }

    emit(const NewsLoading());

    final result = await _getTrendingNewsUseCase(
      GetTrendingNewsParams(
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (news) {
        _trendingNews = news;
        _trendingNewsCacheTime = DateTime.now();

        if (news.isEmpty) {
          emit(const NewsEmpty(message: 'No trending news found'));
        } else {
          emit(NewsTrendingLoaded(
            news: _trendingNews,
            hasReachedMax: _trendingNews.length < event.limit,
            isRefreshing: false,
            bookmarkedIds: _bookmarkedIds,
          ));
        }
      },
    );
  }

  Future<void> _onNewsTabChanged(
    NewsTabChanged event,
    Emitter<NewsState> emit,
  ) async {
    _currentTabIndex = event.tabIndex;

    // Only load data if we don't have valid cached data for this tab
    switch (event.tabIndex) {
      case 0: // Latest
        if (_latestNews.isEmpty || !_isCacheValid(_latestNewsCacheTime)) {
          add(const NewsLoadRequested());
        } else {
          emit(NewsLoaded(
            news: _latestNews,
            categories: _categories,
            selectedCategory: _selectedCategory,
            hasReachedMax: _hasReachedMax,
            isRefreshing: false,
            bookmarkedIds: _bookmarkedIds,
          ));
        }
        break;
      case 1: // Trending
        if (_trendingNews.isEmpty || !_isCacheValid(_trendingNewsCacheTime)) {
          add(const NewsLoadTrendingRequested());
        } else {
          emit(NewsTrendingLoaded(
            news: _trendingNews,
            hasReachedMax: _trendingNews.length < 10,
            isRefreshing: false,
            bookmarkedIds: _bookmarkedIds,
          ));
        }
        break;
      case 2: // Categories
        // For categories tab, load latest news without category filter initially
        if (_latestNews.isEmpty || !_isCacheValid(_latestNewsCacheTime)) {
          add(const NewsLoadRequested());
        } else {
          emit(NewsLoaded(
            news: _latestNews,
            categories: _categories,
            selectedCategory: _selectedCategory,
            hasReachedMax: _hasReachedMax,
            isRefreshing: false,
            bookmarkedIds: _bookmarkedIds,
          ));
        }
        break;
      case 3: // Bookmarked
        if (_bookmarkedNews.isEmpty ||
            !_isCacheValid(_bookmarkedNewsCacheTime)) {
          add(const NewsLoadBookmarkedRequested());
        } else {
          emit(NewsBookmarkedLoaded(
            news: _bookmarkedNews,
            isRefreshing: false,
            bookmarkedIds: _bookmarkedIds,
          ));
        }
        break;
    }
  }

  void _updateBookmarkedState() {
    // Update all possible news states with the new bookmarked IDs
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      emit(currentState.copyWith(bookmarkedIds: _bookmarkedIds));
    } else if (state is NewsSearchLoaded) {
      final currentState = state as NewsSearchLoaded;
      emit(currentState.copyWith(bookmarkedIds: _bookmarkedIds));
    } else if (state is NewsTrendingLoaded) {
      final currentState = state as NewsTrendingLoaded;
      emit(currentState.copyWith(bookmarkedIds: _bookmarkedIds));
    } else if (state is NewsBookmarkedLoaded) {
      final currentState = state as NewsBookmarkedLoaded;
      emit(currentState.copyWith(bookmarkedIds: _bookmarkedIds));
    }
  }
}
