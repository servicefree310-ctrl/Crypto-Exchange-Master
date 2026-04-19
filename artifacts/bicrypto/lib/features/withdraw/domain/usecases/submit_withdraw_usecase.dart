import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/withdraw_request_entity.dart';
import '../entities/withdraw_response_entity.dart';
import '../repositories/withdraw_repository.dart';

@injectable
class SubmitWithdrawUseCase
    implements UseCase<WithdrawResponseEntity, WithdrawRequestEntity> {
  final WithdrawRepository _repository;

  const SubmitWithdrawUseCase(this._repository);

  @override
  Future<Either<Failure, WithdrawResponseEntity>> call(
      WithdrawRequestEntity params) async {
    // Validate request
    final validation = _validateRequest(params);
    if (validation != null) return Left(validation);

    return await _repository.submitWithdrawal(params);
  }

  ValidationFailure? _validateRequest(WithdrawRequestEntity request) {
    // Validate amount
    if (request.amount <= 0) {
      return const ValidationFailure('Amount must be greater than zero');
    }

    // Validate wallet type
    final validWalletTypes = ['FIAT', 'SPOT', 'ECO'];
    if (!validWalletTypes.contains(request.walletType)) {
      return ValidationFailure('Invalid wallet type: ${request.walletType}');
    }

    // Validate decimal precision
    final amountStr = request.amount.toString();
    if (amountStr.contains('.')) {
      final decimals = amountStr.split('.')[1].length;
      // Most cryptocurrencies support up to 8 decimal places
      // FIAT typically supports 2
      final maxDecimals = request.walletType == 'FIAT' ? 2 : 8;
      if (decimals > maxDecimals) {
        return ValidationFailure(
          'Amount has too many decimal places. Maximum allowed is $maxDecimals',
        );
      }
    }

    // Validate required fields based on wallet type
    if (request.walletType == 'FIAT') {
      if (request.methodId == null || request.methodId!.isEmpty) {
        return const ValidationFailure(
            'Method ID is required for FIAT withdrawals');
      }
    } else if (request.walletType == 'SPOT' || request.walletType == 'ECO') {
      if (request.toAddress == null || request.toAddress!.isEmpty) {
        return const ValidationFailure('Withdrawal address is required');
      }
      if (request.chain == null || request.chain!.isEmpty) {
        return const ValidationFailure('Network/Chain is required');
      }
    }

    return null;
  }
}
