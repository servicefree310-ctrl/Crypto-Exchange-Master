import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/futures_position_entity.dart';

abstract class FuturesPositionRepository {
  Future<Either<Failure, List<FuturesPositionEntity>>> getPositions({
    required String symbol,
  });

  Future<Either<Failure, FuturesPositionEntity>> closePosition({
    required String symbol,
    required String side,
  });

  Future<Either<Failure, FuturesPositionEntity>> updateLeverage({
    required String symbol,
    required double leverage,
  });
}
