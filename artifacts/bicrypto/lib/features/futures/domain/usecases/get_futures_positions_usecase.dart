import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/futures_position_entity.dart';
import '../repositories/futures_position_repository.dart';

class GetFuturesPositionsParams {
  const GetFuturesPositionsParams({required this.symbol});

  final String symbol;
}

@injectable
class GetFuturesPositionsUseCase
    implements UseCase<List<FuturesPositionEntity>, GetFuturesPositionsParams> {
  const GetFuturesPositionsUseCase(this._repository);

  final FuturesPositionRepository _repository;

  @override
  Future<Either<Failure, List<FuturesPositionEntity>>> call(
      GetFuturesPositionsParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.getPositions(symbol: params.symbol);
  }

  ValidationFailure? _validateParams(GetFuturesPositionsParams params) {
    if (params.symbol.isEmpty) {
      return const ValidationFailure('Symbol is required');
    }
    return null;
  }
}
