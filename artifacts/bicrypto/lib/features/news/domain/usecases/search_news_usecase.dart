import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/news_entity.dart';
import '../repositories/news_repository.dart';

class SearchNewsParams {
  const SearchNewsParams({
    required this.query,
    this.category,
    this.limit = 20,
    this.offset = 0,
  });

  final String query;
  final String? category;
  final int limit;
  final int offset;
}

@injectable
class SearchNewsUseCase implements UseCase<List<NewsEntity>, SearchNewsParams> {
  const SearchNewsUseCase(this._newsRepository);

  final NewsRepository _newsRepository;

  @override
  Future<Either<Failure, List<NewsEntity>>> call(
      SearchNewsParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _newsRepository.searchNews(
      query: params.query,
      category: params.category,
      limit: params.limit,
      offset: params.offset,
    );
  }

  ValidationFailure? _validateParams(SearchNewsParams params) {
    if (params.query.trim().isEmpty) {
      return const ValidationFailure('Search query cannot be empty');
    }
    if (params.query.trim().length < 2) {
      return const ValidationFailure(
          'Search query must be at least 2 characters');
    }
    if (params.limit < 1 || params.limit > 100) {
      return const ValidationFailure('Limit must be between 1 and 100');
    }
    if (params.offset < 0) {
      return const ValidationFailure('Offset must be non-negative');
    }
    return null;
  }
}
