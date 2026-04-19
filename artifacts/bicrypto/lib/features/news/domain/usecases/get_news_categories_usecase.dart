import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/news_entity.dart';
import '../repositories/news_repository.dart';

@injectable
class GetNewsCategoriesUseCase
    implements UseCase<List<NewsCategoryEntity>, NoParams> {
  const GetNewsCategoriesUseCase(this._newsRepository);

  final NewsRepository _newsRepository;

  @override
  Future<Either<Failure, List<NewsCategoryEntity>>> call(
      NoParams params) async {
    return await _newsRepository.getNewsCategories();
  }
}
