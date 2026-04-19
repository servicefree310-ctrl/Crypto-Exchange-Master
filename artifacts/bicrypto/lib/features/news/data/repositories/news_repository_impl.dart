import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/news_remote_datasource.dart';
import '../datasources/news_local_datasource.dart';
import '../models/news_model.dart';
import '../models/news_category_model.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';

@Injectable(as: NewsRepository)
class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final NewsRemoteDataSource _remoteDataSource;
  final NewsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<NewsEntity>>> getLatestNews({
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        // Try to get cached news
        final cachedNews =
            await _localDataSource.getCachedNews('latest_${category ?? 'all'}');
        if (cachedNews.isNotEmpty) {
          return Right(cachedNews.map((model) => model.toEntity()).toList());
        }
        return const Left(NetworkFailure(
            'No internet connection and no cached data available'));
      }

      // Get fresh data from API
      final newsModels = await _remoteDataSource.getLatestNews(
        category: category,
        limit: limit,
        offset: offset,
      );

      // Cache the data
      await _localDataSource.cacheNews(
          'latest_${category ?? 'all'}', newsModels);

      return Right(newsModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsEntity>>> getTrendingNews({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        final cachedNews = await _localDataSource.getCachedNews('trending');
        if (cachedNews.isNotEmpty) {
          return Right(cachedNews.map((model) => model.toEntity()).toList());
        }
        return const Left(NetworkFailure(
            'No internet connection and no cached data available'));
      }

      final newsModels = await _remoteDataSource.getTrendingNews(
        limit: limit,
        offset: offset,
      );

      await _localDataSource.cacheNews('trending', newsModels);

      return Right(newsModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsEntity>>> searchNews({
    required String query,
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(
            NetworkFailure('Search requires internet connection'));
      }

      final newsModels = await _remoteDataSource.searchNews(
        query: query,
        category: category,
        limit: limit,
        offset: offset,
      );

      return Right(newsModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsCategoryEntity>>> getNewsCategories() async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final categoryModels = await _remoteDataSource.getNewsCategories();
      return Right(categoryModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NewsEntity>> getNewsById(String id) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final newsModel = await _remoteDataSource.getNewsById(id);
      return Right(newsModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsEntity>>> getNewsByCategory({
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

  @override
  Future<Either<Failure, void>> bookmarkNews(String newsId) async {
    try {
      await _localDataSource.bookmarkNews(newsId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String newsId) async {
    try {
      await _localDataSource.removeBookmark(newsId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsEntity>>> getBookmarkedNews() async {
    try {
      final bookmarkedIds = await _localDataSource.getBookmarkedNewsIds();
      if (bookmarkedIds.isEmpty) {
        return const Right([]);
      }

      // Instead of making individual API calls, try to get from cached data first
      final allCachedNews = <NewsEntity>[];

      // Try to get from latest news cache
      try {
        final latestCached = await _localDataSource.getCachedNews('latest_all');
        allCachedNews.addAll(latestCached.map((model) => model.toEntity()));
      } catch (e) {
        // Ignore cache errors
      }

      // Try to get from trending news cache
      try {
        final trendingCached = await _localDataSource.getCachedNews('trending');
        allCachedNews.addAll(trendingCached.map((model) => model.toEntity()));
      } catch (e) {
        // Ignore cache errors
      }

      // Filter bookmarked news from cached data
      final bookmarkedNews = allCachedNews
          .where((news) => bookmarkedIds.contains(news.id))
          .toList();

      // If we found all bookmarked news in cache, return them
      if (bookmarkedNews.length == bookmarkedIds.length) {
        return Right(bookmarkedNews);
      }

      // If some bookmarked news are missing from cache, only fetch those
      final missingIds = bookmarkedIds
          .where((id) => !bookmarkedNews.any((news) => news.id == id))
          .toList();

      if (missingIds.isNotEmpty) {
        // Only make API calls for missing news
        for (final id in missingIds) {
          final result = await getNewsById(id);
          result.fold(
            (failure) => null, // Skip failed requests
            (news) => bookmarkedNews.add(news),
          );
        }
      }

      return Right(bookmarkedNews);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
