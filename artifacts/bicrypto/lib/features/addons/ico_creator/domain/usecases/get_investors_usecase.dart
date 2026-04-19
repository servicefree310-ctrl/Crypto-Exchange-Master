import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/errors/failures.dart';
import '../repositories/creator_repository.dart';
import '../entities/investor_entity.dart';

@injectable
class GetInvestorsUseCase {
  const GetInvestorsUseCase(this._repository);

  final CreatorRepository _repository;

  Future<Either<Failure, List<InvestorEntity>>> call() async {
    return _repository.getInvestors();
  }
}
