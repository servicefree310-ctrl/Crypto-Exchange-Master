import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/futures_position_entity.dart';
import '../repositories/futures_position_repository.dart';

class ChangeLeverageParams {
  const ChangeLeverageParams({
    required this.symbol,
    required this.leverage,
  });

  final String symbol;
  final double leverage;
}

@injectable
class ChangeLeverageUseCase
    implements UseCase<FuturesPositionEntity, ChangeLeverageParams> {
  const ChangeLeverageUseCase(this._repository);

  final FuturesPositionRepository _repository;

  @override
  Future<Either<Failure, FuturesPositionEntity>> call(
      ChangeLeverageParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.updateLeverage(
      symbol: params.symbol,
      leverage: params.leverage,
    );
  }

  ValidationFailure? _validateParams(ChangeLeverageParams params) {
    if (params.symbol.isEmpty) {
      return const ValidationFailure('Symbol is required');
    }
    if (params.leverage < 1 || params.leverage > 100) {
      return const ValidationFailure('Leverage must be between 1 and 100');
    }
    return null;
  }
}
