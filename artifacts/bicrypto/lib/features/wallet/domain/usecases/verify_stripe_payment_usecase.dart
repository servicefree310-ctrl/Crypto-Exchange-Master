import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/deposit_transaction_entity.dart';
import '../repositories/deposit_repository.dart';

@injectable
class VerifyStripePaymentUseCase
    implements UseCase<DepositTransactionEntity, VerifyStripePaymentParams> {
  const VerifyStripePaymentUseCase(this._repository);

  final DepositRepository _repository;

  @override
  Future<Either<Failure, DepositTransactionEntity>> call(
      VerifyStripePaymentParams params) async {
    dev.log(
        '🔵 VERIFY_STRIPE_PAYMENT_UC: Verifying payment intent: ${params.paymentIntentId}');

    // Validate parameters
    final validationFailure = _validateParams(params);
    if (validationFailure != null) {
      dev.log(
          '🔴 VERIFY_STRIPE_PAYMENT_UC: Validation failed: ${validationFailure.message}');
      return Left(validationFailure);
    }

    return await _repository.verifyStripePayment(
      paymentIntentId: params.paymentIntentId,
    );
  }

  ValidationFailure? _validateParams(VerifyStripePaymentParams params) {
    if (params.paymentIntentId.isEmpty) {
      return const ValidationFailure('Payment intent ID is required');
    }

    // Stripe payment intent IDs start with 'pi_'
    if (!params.paymentIntentId.startsWith('pi_')) {
      return const ValidationFailure('Invalid payment intent ID format');
    }

    return null;
  }
}

class VerifyStripePaymentParams {
  const VerifyStripePaymentParams({
    required this.paymentIntentId,
  });

  final String paymentIntentId;

  @override
  String toString() {
    return 'VerifyStripePaymentParams(paymentIntentId: $paymentIntentId)';
  }
}
