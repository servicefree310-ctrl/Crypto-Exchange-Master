import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/futures_position_entity.dart';
import '../repositories/futures_position_repository.dart';

class ClosePositionParams {
  const ClosePositionParams({
    required this.positionId,
    required this.symbol,
    required this.side,
  });

  final String positionId;
  final String symbol;
  final String side;
}

@injectable
class ClosePositionUseCase
    implements UseCase<FuturesPositionEntity, ClosePositionParams> {
  const ClosePositionUseCase(this._repository);

  final FuturesPositionRepository _repository;

  @override
  Future<Either<Failure, FuturesPositionEntity>> call(
      ClosePositionParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.closePosition(
      symbol: params.symbol,
      side: params.side,
    );
  }

  ValidationFailure? _validateParams(ClosePositionParams params) {
    if (params.positionId.isEmpty) {
      return const ValidationFailure('Position ID is required');
    }
    return null;
  }
}
