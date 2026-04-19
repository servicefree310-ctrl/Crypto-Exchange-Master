import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/news_model.dart';
import '../models/news_category_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getLatestNews({
    String? category,
    int? limit,
    int? offset,
  });

  Future<List<NewsModel>> getTrendingNews({
    int? limit,
    int? offset,
  });

  Future<List<NewsModel>> searchNews({
    required String query,
    String? category,
    int? limit,
    int? offset,
  });

  Future<List<NewsCategoryModel>> getNewsCategories();

  Future<NewsModel> getNewsById(String id);

  Future<List<NewsModel>> getNewsByCategory({
    required String category,
    int? limit,
    int? offset,
  });
}

@Injectable(as: NewsRemoteDataSource)
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  const NewsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  // Using CryptoCompare News API as the primary source
  static const String _baseUrl = 'https://min-api.cryptocompare.com/data/v2';

  // Cache for search results to avoid duplicate API calls
  static final Map<String, List<NewsModel>> _searchCache = {};
  static const int _cacheExpiryMinutes = 5;
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Cache for latest and trending news
  static List<NewsModel>? _latestNewsCache;
  static List<NewsModel>? _trendingNewsCache;
  static DateTime? _latestNewsCacheTime;
  static DateTime? _trendingNewsCacheTime;
  static const int _newsCacheExpiryMinutes = 3; // Shorter cache for news

  @override
  Future<List<NewsModel>> getLatestNews({
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      // Check cache first (only for non-category requests)
      if (category == null &&
          _latestNewsCache != null &&
          _latestNewsCacheTime != null) {
        final cacheAge =
            DateTime.now().difference(_latestNewsCacheTime!).inMinutes;
        if (cacheAge < _newsCacheExpiryMinutes) {
          dev.log('📰 NEWS: Using cached latest news (age: ${cacheAge}m)');
          return _applyLimitAndOffset(_latestNewsCache!, limit, offset);
        }
      }

      dev.log('📰 NEWS: Fetching latest news from API');
      final response = await _apiClient.get(
        '$_baseUrl/news/',
        queryParameters: {
          'lang': 'EN',
          'sortOrder': 'latest',
          if (category != null) 'categories': category,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      final List<dynamic> newsList = response.data['Data'] ?? [];
      final newsModels =
          newsList.map((json) => _mapCryptoCompareToNewsModel(json)).toList();

      // Cache the results (only for non-category requests)
      if (category == null) {
        _latestNewsCache = newsModels;
        _latestNewsCacheTime = DateTime.now();
        dev.log('📰 NEWS: Cached latest news (${newsModels.length} items)');
      }

      return newsModels;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch latest news',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<NewsModel>> getTrendingNews({
    int? limit,
    int? offset,
  }) async {
    try {
      // Check cache first
      if (_trendingNewsCache != null && _trendingNewsCacheTime != null) {
        final cacheAge =
            DateTime.now().difference(_trendingNewsCacheTime!).inMinutes;
        if (cacheAge < _newsCacheExpiryMinutes) {
          dev.log('📈 NEWS: Using cached trending news (age: ${cacheAge}m)');
          return _applyLimitAndOffset(_trendingNewsCache!, limit, offset);
        }
      }

      dev.log('📈 NEWS: Fetching trending news from API');
      final response = await _apiClient.get(
        '$_baseUrl/news/',
        queryParameters: {
          'lang': 'EN',
          'sortOrder': 'popular',
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      final List<dynamic> newsList = response.data['Data'] ?? [];
      final newsModels =
          newsList.map((json) => _mapCryptoCompareToNewsModel(json)).toList();

      // Cache the results
      _trendingNewsCache = newsModels;
      _trendingNewsCacheTime = DateTime.now();
      dev.log('📈 NEWS: Cached trending news (${newsModels.length} items)');

      return newsModels;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch trending news',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<NewsModel>> searchNews({
    required String query,
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      final searchKey = '${query.toLowerCase()}_${category ?? 'all'}';

      // Check cache first
      if (_searchCache.containsKey(searchKey)) {
        final cacheTime = _cacheTimestamps[searchKey];
        if (cacheTime != null &&
            DateTime.now().difference(cacheTime).inMinutes <
                _cacheExpiryMinutes) {
          dev.log('🔍 NEWS_SEARCH: Using cached results for "$query"');
          final cachedResults = _searchCache[searchKey]!;
          return _applyLimitAndOffset(cachedResults, limit, offset);
        }
      }

      dev.log('🔍 NEWS_SEARCH: Searching for "$query"');

      // Use the regular news endpoint and filter client-side since CryptoCompare search might not work
      final response = await _apiClient.get(
        '$_baseUrl/news/',
        queryParameters: {
          'lang': 'EN',
          'sortOrder': 'latest',
          'limit': 100, // Get more to filter
        },
      );

      final List<dynamic> newsList = response.data['Data'] ?? [];
      dev.log('🔍 NEWS_SEARCH: Total news fetched: ${newsList.length}');

      // Filter news based on search query (client-side search)
      final filteredNews = newsList.where((news) {
        final title = (news['title'] ?? '').toString().toLowerCase();
        final body = (news['body'] ?? '').toString().toLowerCase();
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) || body.contains(searchQuery);
      }).toList();

      dev.log('🔍 NEWS_SEARCH: Filtered news count: ${filteredNews.length}');

      // Convert to models
      final newsModels = filteredNews
          .map((json) =>
              _mapCryptoCompareToNewsModel(json as Map<String, dynamic>))
          .toList();

      // Cache the results
      _searchCache[searchKey] = newsModels;
      _cacheTimestamps[searchKey] = DateTime.now();

      // Clean old cache entries
      _cleanCache();

      return _applyLimitAndOffset(newsModels, limit, offset);
    } on DioException catch (e) {
      dev.log('🔍 NEWS_SEARCH: DioException: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to search news',
      );
    } catch (e) {
      dev.log('🔍 NEWS_SEARCH: General error: ${e.toString()}');
      throw ServerException('Search error: ${e.toString()}');
    }
  }

  List<NewsModel> _applyLimitAndOffset(
      List<NewsModel> news, int? limit, int? offset) {
    int startIndex = offset ?? 0;
    int endIndex = limit != null ? startIndex + limit : news.length;

    if (startIndex >= news.length) return [];
    if (endIndex > news.length) endIndex = news.length;

    return news.sublist(startIndex, endIndex);
  }

  void _cleanCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value).inMinutes >= _cacheExpiryMinutes) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _searchCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  @override
  Future<List<NewsCategoryModel>> getNewsCategories() async {
    try {
      // CryptoCompare categories
      const categories = [
        {'id': 'BTC', 'name': 'Bitcoin', 'icon': '₿', 'isActive': true},
        {'id': 'ETH', 'name': 'Ethereum', 'icon': 'Ξ', 'isActive': true},
        {'id': 'DEFI', 'name': 'DeFi', 'icon': '🔄', 'isActive': true},
        {'id': 'NFT', 'name': 'NFTs', 'icon': '🖼️', 'isActive': true},
        {'id': 'REG', 'name': 'Regulation', 'icon': '⚖️', 'isActive': true},
        {'id': 'TECH', 'name': 'Technology', 'icon': '🔧', 'isActive': true},
        {'id': 'MARKET', 'name': 'Market', 'icon': '📈', 'isActive': true},
        {'id': 'EXCHANGE', 'name': 'Exchanges', 'icon': '🏢', 'isActive': true},
      ];

      return categories
          .map((cat) => NewsCategoryModel(
                id: cat['id'] as String,
                name: cat['name'] as String,
                icon: cat['icon'] as String,
                isActive: cat['isActive'] as bool,
              ))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch news categories');
    }
  }

  @override
  Future<NewsModel> getNewsById(String id) async {
    try {
      final response = await _apiClient.get('$_baseUrl/news/article/$id');
      return _mapCryptoCompareToNewsModel(response.data['Data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch news article',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<NewsModel>> getNewsByCategory({
    required String category,
    int? limit,
    int? offset,
  }) async {
    return getLatestNews(
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  // Helper method to map CryptoCompare API response to our NewsModel
  NewsModel _mapCryptoCompareToNewsModel(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      summary: json['body'] ?? '',
      content: json['body'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageurl'] ?? '',
      source: json['source'] ?? '',
      publishedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['published_on'] ?? 0) * 1000,
      ),
      categories: _extractCategories(json),
      sentiment: _determineSentiment(json),
      readTime: _calculateReadTime(json['body'] ?? ''),
    );
  }

  List<String> _extractCategories(Map<String, dynamic> json) {
    final categories = <String>[];
    if (json['categories'] != null) {
      categories.addAll((json['categories'] as String).split('|'));
    }
    if (json['source_info'] != null && json['source_info']['name'] != null) {
      categories.add(json['source_info']['name']);
    }
    return categories.where((cat) => cat.isNotEmpty).toList();
  }

  String _determineSentiment(Map<String, dynamic> json) {
    // Simple sentiment analysis based on keywords
    final body = (json['body'] ?? '').toLowerCase();
    final title = (json['title'] ?? '').toLowerCase();
    final text = '$title $body';

    final positiveWords = [
      'bullish',
      'surge',
      'rally',
      'gain',
      'up',
      'positive',
      'growth'
    ];
    final negativeWords = [
      'bearish',
      'crash',
      'drop',
      'fall',
      'down',
      'negative',
      'decline'
    ];

    int positiveCount =
        positiveWords.where((word) => text.contains(word)).length;
    int negativeCount =
        negativeWords.where((word) => text.contains(word)).length;

    if (positiveCount > negativeCount) return 'positive';
    if (negativeCount > positiveCount) return 'negative';
    return 'neutral';
  }

  int _calculateReadTime(String content) {
    // Average reading speed: 200 words per minute
    final wordCount = content.split(' ').length;
    return (wordCount / 200).ceil();
  }
}
