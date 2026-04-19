import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/news_model.dart';

abstract class NewsLocalDataSource {
  Future<List<NewsModel>> getCachedNews(String key);
  Future<void> cacheNews(String key, List<NewsModel> news);
  Future<void> clearCache(String key);
  Future<List<String>> getBookmarkedNewsIds();
  Future<void> bookmarkNews(String newsId);
  Future<void> removeBookmark(String newsId);
  Future<bool> isNewsBookmarked(String newsId);
}

@Injectable(as: NewsLocalDataSource)
class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  const NewsLocalDataSourceImpl(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static const String _newsCachePrefix = 'news_cache_';
  static const String _bookmarksKey = 'bookmarked_news_ids';

  @override
  Future<List<NewsModel>> getCachedNews(String key) async {
    try {
      final jsonString = _sharedPreferences.getString('$_newsCachePrefix$key');
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached news: $e');
    }
  }

  @override
  Future<void> cacheNews(String key, List<NewsModel> news) async {
    try {
      final jsonList = news.map((model) => model.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _sharedPreferences.setString('$_newsCachePrefix$key', jsonString);
    } catch (e) {
      throw CacheException('Failed to cache news: $e');
    }
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      await _sharedPreferences.remove('$_newsCachePrefix$key');
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<List<String>> getBookmarkedNewsIds() async {
    try {
      final jsonString = _sharedPreferences.getString(_bookmarksKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((id) => id.toString()).toList();
    } catch (e) {
      throw CacheException('Failed to get bookmarked news IDs: $e');
    }
  }

  @override
  Future<void> bookmarkNews(String newsId) async {
    try {
      final bookmarkedIds = await getBookmarkedNewsIds();
      if (!bookmarkedIds.contains(newsId)) {
        bookmarkedIds.add(newsId);
        final jsonString = json.encode(bookmarkedIds);
        await _sharedPreferences.setString(_bookmarksKey, jsonString);
      }
    } catch (e) {
      throw CacheException('Failed to bookmark news: $e');
    }
  }

  @override
  Future<void> removeBookmark(String newsId) async {
    try {
      final bookmarkedIds = await getBookmarkedNewsIds();
      bookmarkedIds.remove(newsId);
      final jsonString = json.encode(bookmarkedIds);
      await _sharedPreferences.setString(_bookmarksKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to remove bookmark: $e');
    }
  }

  @override
  Future<bool> isNewsBookmarked(String newsId) async {
    try {
      final bookmarkedIds = await getBookmarkedNewsIds();
      return bookmarkedIds.contains(newsId);
    } catch (e) {
      throw CacheException('Failed to check bookmark status: $e');
    }
  }
}
