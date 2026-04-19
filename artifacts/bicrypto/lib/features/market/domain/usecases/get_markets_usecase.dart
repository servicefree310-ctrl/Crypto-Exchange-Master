import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/market_data_entity.dart';
import '../repositories/market_repository.dart';

@injectable
class GetMarketsUseCase implements UseCase<List<MarketDataEntity>, NoParams> {
  const GetMarketsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(NoParams params) async {
    return _repository.getMarkets();
  }
}

@injectable
class GetTrendingMarketsUseCase
    implements UseCase<List<MarketDataEntity>, NoParams> {
  const GetTrendingMarketsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(NoParams params) async {
    return _repository.getTrendingMarkets();
  }
}

@injectable
class GetHotMarketsUseCase
    implements UseCase<List<MarketDataEntity>, NoParams> {
  const GetHotMarketsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(NoParams params) async {
    return _repository.getHotMarkets();
  }
}

@injectable
class GetGainersMarketsUseCase
    implements UseCase<List<MarketDataEntity>, NoParams> {
  const GetGainersMarketsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(NoParams params) async {
    return _repository.getGainersMarkets();
  }
}

@injectable
class GetLosersMarketsUseCase
    implements UseCase<List<MarketDataEntity>, NoParams> {
  const GetLosersMarketsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(NoParams params) async {
    return _repository.getLosersMarkets();
  }
}

@injectable
class GetHighVolumeMarketsUseCase
    implements UseCase<List<MarketDataEntity>, NoParams> {
  const GetHighVolumeMarketsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(NoParams params) async {
    return _repository.getHighVolumeMarkets();
  }
}

@injectable
class SearchMarketsUseCase implements UseCase<List<MarketDataEntity>, String> {
  const SearchMarketsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(String params) async {
    return _repository.searchMarkets(params);
  }
}

@injectable
class GetMarketsByCategoryUseCase
    implements UseCase<List<MarketDataEntity>, String> {
  const GetMarketsByCategoryUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<MarketDataEntity>>> call(String params) async {
    return _repository.getMarketsByCategory(params);
  }
}
