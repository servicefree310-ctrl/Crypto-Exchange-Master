import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/futures_market_entity.dart';
import '../repositories/futures_market_repository.dart';

@injectable
class GetFuturesMarketsUseCase
    implements UseCase<List<FuturesMarketEntity>, NoParams> {
  const GetFuturesMarketsUseCase(this._repository);

  final FuturesMarketRepository _repository;

  @override
  Future<Either<Failure, List<FuturesMarketEntity>>> call(NoParams params) {
    return _repository.getFuturesMarkets();
  }
}
