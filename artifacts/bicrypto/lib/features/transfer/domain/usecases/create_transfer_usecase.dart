import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transfer_request_entity.dart';
import '../entities/transfer_response_entity.dart';
import '../repositories/transfer_repository.dart';

@injectable
class CreateTransferUseCase
    implements UseCase<TransferResponseEntity, TransferRequestEntity> {
  final TransferRepository _repository;

  const CreateTransferUseCase(this._repository);

  @override
  Future<Either<Failure, TransferResponseEntity>> call(
      TransferRequestEntity params) async {
    // 1. Validate transfer rules
    final validation = _validateTransferRules(params);
    if (validation != null) return Left(validation);

    // 2. Execute transfer
    return await _repository.createTransfer(params);
  }

  ValidationFailure? _validateTransferRules(TransferRequestEntity params) {
    const validTransfers = {
      'FIAT': ['SPOT', 'ECO'],
      'SPOT': ['FIAT', 'ECO'],
      'ECO': ['FIAT', 'SPOT', 'FUTURES'],
      'FUTURES': ['ECO'],
    };

    // Validate wallet transfers
    if (params.transferType == 'wallet') {
      if (params.toType == null) {
        return const ValidationFailure(
            'Target wallet type is required for wallet transfers');
      }

      if (params.fromType == params.toType) {
        return const ValidationFailure(
            'Source and target wallet types must be different');
      }

      if (!validTransfers[params.fromType]!.contains(params.toType)) {
        return ValidationFailure(
          'Invalid transfer: ${params.fromType} cannot transfer to ${params.toType}',
        );
      }
    }

    // Validate client transfers
    if (params.transferType == 'client') {
      if (params.clientId == null || params.clientId!.isEmpty) {
        return const ValidationFailure(
            'Recipient UUID is required for client transfers');
      }
    }

    // Validate amount
    if (params.amount <= 0) {
      return const ValidationFailure('Amount must be greater than 0');
    }

    return null;
  }
}
