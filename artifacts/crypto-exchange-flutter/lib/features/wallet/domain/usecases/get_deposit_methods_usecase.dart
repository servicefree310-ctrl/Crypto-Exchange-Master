import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/deposit_gateway_entity.dart';
import '../entities/deposit_method_entity.dart';
import '../repositories/deposit_repository.dart';

class GetDepositMethodsParams {
  final String currency;

  const GetDepositMethodsParams({required this.currency});
}

class DepositMethodsResult {
  final List<DepositGatewayEntity> gateways;
  final List<DepositMethodEntity> methods;

  const DepositMethodsResult({
    required this.gateways,
    required this.methods,
  });
}

@injectable
class GetDepositMethodsUseCase
    implements UseCase<DepositMethodsResult, GetDepositMethodsParams> {
  const GetDepositMethodsUseCase(this._repository);

  final DepositRepository _repository;

  @override
  Future<Either<Failure, DepositMethodsResult>> call(
      GetDepositMethodsParams params) async {
    dev.log('🔵 GET_DEPOSIT_METHODS_UC: Getting methods for ${params.currency}');

    // Validate currency
    if (params.currency.isEmpty) {
      return Left(ValidationFailure('Currency cannot be empty'));
    }

    try {
      // Fetch both gateways and methods concurrently
      final results = await Future.wait([
        _repository.getDepositGateways(params.currency),
        _repository.getDepositMethods(params.currency),
      ]);

      final gatewaysResult =
          results[0] as Either<Failure, List<DepositGatewayEntity>>;
      final methodsResult =
          results[1] as Either<Failure, List<DepositMethodEntity>>;

      return gatewaysResult.fold(
        (failure) => Left(failure),
        (gateways) => methodsResult.fold(
          (failure) => Left(failure),
          (methods) {
            dev.log(
                '🟢 GET_DEPOSIT_METHODS_UC: Successfully fetched ${gateways.length} gateways and ${methods.length} methods');
            return Right(DepositMethodsResult(
              gateways: gateways,
              methods: methods,
            ));
          },
        ),
      );
    } catch (e) {
      dev.log('🔴 GET_DEPOSIT_METHODS_UC: Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
