import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../entities/eco_deposit_address_entity.dart';
import '../repositories/futures_deposit_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Parameters for generating FUTURES address
class GenerateFuturesAddressParams extends Equatable {
  final String currency;
  final String chain;
  final String contractType;

  const GenerateFuturesAddressParams({
    required this.currency,
    required this.chain,
    required this.contractType,
  });

  @override
  List<Object> get props => [currency, chain, contractType];
}

/// Use case for generating FUTURES deposit address
@injectable
class GenerateFuturesAddressUseCase
    implements UseCase<EcoDepositAddressEntity, GenerateFuturesAddressParams> {
  final FuturesDepositRepository _repository;

  const GenerateFuturesAddressUseCase(this._repository);

  @override
  Future<Either<Failure, EcoDepositAddressEntity>> call(
      GenerateFuturesAddressParams params) {
    // Validate parameters
    if (params.currency.isEmpty) {
      return Future.value(Left(ValidationFailure('Currency is required')));
    }
    if (params.chain.isEmpty) {
      return Future.value(Left(ValidationFailure('Chain is required')));
    }
    if (params.contractType.isEmpty) {
      return Future.value(Left(ValidationFailure('Contract type is required')));
    }

    return _repository.generateFuturesAddress(
      params.currency,
      params.chain,
      params.contractType,
    );
  }
}
