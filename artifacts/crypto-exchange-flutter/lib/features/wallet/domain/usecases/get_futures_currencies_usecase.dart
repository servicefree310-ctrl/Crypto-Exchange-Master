import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/eco_token_entity.dart';
import '../repositories/futures_deposit_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Use case for fetching available FUTURES currencies
@injectable
class GetFuturesCurrenciesUseCase
    implements UseCase<List<EcoTokenEntity>, NoParams> {
  final FuturesDepositRepository _repository;

  const GetFuturesCurrenciesUseCase(this._repository);

  @override
  Future<Either<Failure, List<EcoTokenEntity>>> call(NoParams params) {
    return _repository.getFuturesCurrencies();
  }
}
