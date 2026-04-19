import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../market/domain/repositories/market_repository.dart';

@injectable
class GetTradingMarketsUseCase
    implements UseCase<List<MarketDataEntity>, NoParams> {
  const GetTradingMarketsUseCase(this._marketRepository);

  final MarketRepository _marketRepository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(NoParams params) async {
    return await _marketRepository.getMarkets();
  }
}
