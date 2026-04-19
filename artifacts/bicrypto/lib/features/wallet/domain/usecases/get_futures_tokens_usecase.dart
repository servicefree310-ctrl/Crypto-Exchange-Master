import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../entities/eco_token_entity.dart';
import '../repositories/futures_deposit_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Parameters for getting FUTURES tokens
class GetFuturesTokensParams extends Equatable {
  final String currency;

  const GetFuturesTokensParams({required this.currency});

  @override
  List<Object> get props => [currency];
}

/// Use case for fetching available FUTURES tokens for a currency
@injectable
class GetFuturesTokensUseCase
    implements UseCase<List<EcoTokenEntity>, GetFuturesTokensParams> {
  final FuturesDepositRepository _repository;

  const GetFuturesTokensUseCase(this._repository);

  @override
  Future<Either<Failure, List<EcoTokenEntity>>> call(
      GetFuturesTokensParams params) {
    return _repository.getFuturesTokens(params.currency);
  }
}
