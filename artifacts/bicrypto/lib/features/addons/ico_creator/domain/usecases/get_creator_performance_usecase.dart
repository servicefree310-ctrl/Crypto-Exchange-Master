import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/errors/failures.dart';
import '../repositories/creator_repository.dart';
import '../entities/chart_point_entity.dart';

@injectable
class GetCreatorPerformanceUseCase {
  const GetCreatorPerformanceUseCase(this._repo);

  final CreatorRepository _repo;

  Future<Either<Failure, List<ChartPointEntity>>> call(String range) {
    return _repo.getPerformance(range);
  }
}
