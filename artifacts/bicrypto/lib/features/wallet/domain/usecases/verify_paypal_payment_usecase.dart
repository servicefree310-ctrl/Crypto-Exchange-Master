import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/deposit_transaction_entity.dart';
import '../repositories/deposit_repository.dart';

class VerifyPayPalPaymentParams {
  final String orderId;

  const VerifyPayPalPaymentParams({
    required this.orderId,
  });
}

@injectable
class VerifyPayPalPaymentUseCase
    implements UseCase<DepositTransactionEntity, VerifyPayPalPaymentParams> {
  const VerifyPayPalPaymentUseCase(this._repository);

  final DepositRepository _repository;

  @override
  Future<Either<Failure, DepositTransactionEntity>> call(
      VerifyPayPalPaymentParams params) async {
    dev.log('🔵 VERIFY_PAYPAL_PAYMENT_UC: Verifying PayPal payment');
    dev.log('🔵 VERIFY_PAYPAL_PAYMENT_UC: Order ID: ${params.orderId}');

    // Validate input
    if (params.orderId.isEmpty) {
      dev.log('🔴 VERIFY_PAYPAL_PAYMENT_UC: Invalid order ID');
      return Left(ValidationFailure('Order ID is required'));
    }

    final result = await _repository.verifyPayPalPayment(
      orderId: params.orderId,
    );

    return result.fold(
      (failure) {
        dev.log(
            '🔴 VERIFY_PAYPAL_PAYMENT_UC: Failed to verify PayPal payment: $failure');
        return Left(failure);
      },
      (transaction) {
        dev.log(
            '🟢 VERIFY_PAYPAL_PAYMENT_UC: PayPal payment verified successfully');
        return Right(transaction);
      },
    );
  }
}
