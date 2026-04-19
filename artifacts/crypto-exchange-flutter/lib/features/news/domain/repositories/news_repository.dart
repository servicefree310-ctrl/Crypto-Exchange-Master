import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/news_entity.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<NewsEntity>>> getLatestNews({
    String? category,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<NewsEntity>>> getTrendingNews({
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<NewsEntity>>> searchNews({
    required String query,
    String? category,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<NewsCategoryEntity>>> getNewsCategories();

  Future<Either<Failure, NewsEntity>> getNewsById(String id);

  Future<Either<Failure, List<NewsEntity>>> getNewsByCategory({
    required String category,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, void>> bookmarkNews(String newsId);

  Future<Either<Failure, void>> removeBookmark(String newsId);

  Future<Either<Failure, List<NewsEntity>>> getBookmarkedNews();
}
