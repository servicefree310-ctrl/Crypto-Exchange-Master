import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/news_entity.dart';
import '../repositories/news_repository.dart';

class GetTrendingNewsParams {
  const GetTrendingNewsParams({
    this.limit = 10,
    this.offset = 0,
  });

  final int limit;
  final int offset;
}

@injectable
class GetTrendingNewsUseCase
    implements UseCase<List<NewsEntity>, GetTrendingNewsParams> {
  const GetTrendingNewsUseCase(this._newsRepository);

  final NewsRepository _newsRepository;

  @override
  Future<Either<Failure, List<NewsEntity>>> call(
      GetTrendingNewsParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _newsRepository.getTrendingNews(
      limit: params.limit,
      offset: params.offset,
    );
  }

  ValidationFailure? _validateParams(GetTrendingNewsParams params) {
    if (params.limit < 1 || params.limit > 50) {
      return const ValidationFailure('Limit must be between 1 and 50');
    }
    if (params.offset < 0) {
      return const ValidationFailure('Offset must be non-negative');
    }
    return null;
  }
}
