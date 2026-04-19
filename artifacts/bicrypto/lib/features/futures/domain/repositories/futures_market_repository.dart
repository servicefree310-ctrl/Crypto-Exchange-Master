import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/futures_market_entity.dart';

abstract class FuturesMarketRepository {
  Future<Either<Failure, List<FuturesMarketEntity>>> getFuturesMarkets();
}
