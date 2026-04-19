import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/errors/failures.dart';
import '../repositories/creator_repository.dart';
import '../entities/creator_stats_entity.dart';

@injectable
class GetCreatorStatsUseCase {
  const GetCreatorStatsUseCase(this._repository);

  final CreatorRepository _repository;

  Future<Either<Failure, CreatorStatsEntity>> call() async {
    return _repository.getStats();
  }
}
