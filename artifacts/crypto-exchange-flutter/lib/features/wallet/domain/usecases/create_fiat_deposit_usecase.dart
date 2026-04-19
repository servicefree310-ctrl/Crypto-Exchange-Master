import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/deposit_transaction_entity.dart';
import '../repositories/deposit_repository.dart';

class CreateFiatDepositParams {
  final String methodId;
  final double amount;
  final String currency;
  final Map<String, dynamic> customFields;

  const CreateFiatDepositParams({
    required this.methodId,
    required this.amount,
    required this.currency,
    required this.customFields,
  });
}

@injectable
class CreateFiatDepositUseCase
    implements UseCase<DepositTransactionEntity, CreateFiatDepositParams> {
  const CreateFiatDepositUseCase(this._repository);

  final DepositRepository _repository;

  @override
  Future<Either<Failure, DepositTransactionEntity>> call(
      CreateFiatDepositParams params) async {
    dev.log('🔵 CREATE_FIAT_DEPOSIT_UC: Creating deposit');
    dev.log(
        '🔵 CREATE_FIAT_DEPOSIT_UC: Method: ${params.methodId}, Amount: ${params.amount}, Currency: ${params.currency}');

    // Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(validation);
    }

    try {
      final result = await _repository.createFiatDeposit(
        methodId: params.methodId,
        amount: params.amount,
        currency: params.currency,
        customFields: params.customFields,
      );

      return result.fold(
        (failure) {
          dev.log('🔴 CREATE_FIAT_DEPOSIT_UC: Repository failure: $failure');
          return Left(failure);
        },
        (transaction) {
          dev.log(
              '🟢 CREATE_FIAT_DEPOSIT_UC: Successfully created deposit: ${transaction.id}');
          return Right(transaction);
        },
      );
    } catch (e) {
      dev.log('🔴 CREATE_FIAT_DEPOSIT_UC: Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  ValidationFailure? _validateParams(CreateFiatDepositParams params) {
    if (params.methodId.isEmpty) {
      return ValidationFailure('Method ID cannot be empty');
    }

    if (params.amount <= 0) {
      return ValidationFailure('Amount must be greater than 0');
    }

    if (params.currency.isEmpty) {
      return ValidationFailure('Currency cannot be empty');
    }

    return null;
  }
}
