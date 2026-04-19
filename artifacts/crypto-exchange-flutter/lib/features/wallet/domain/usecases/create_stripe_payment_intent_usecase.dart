import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/deposit_repository.dart';

@injectable
class CreateStripePaymentIntentUseCase
    implements UseCase<Map<String, dynamic>, CreateStripePaymentIntentParams> {
  const CreateStripePaymentIntentUseCase(this._repository);

  final DepositRepository _repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      CreateStripePaymentIntentParams params) async {
    dev.log(
        '🔵 CREATE_STRIPE_PAYMENT_INTENT_UC: Creating payment intent for ${params.amount} ${params.currency}');

    // Validate parameters
    final validationFailure = _validateParams(params);
    if (validationFailure != null) {
      dev.log(
          '🔴 CREATE_STRIPE_PAYMENT_INTENT_UC: Validation failed: ${validationFailure.message}');
      return Left(validationFailure);
    }

    return await _repository.createStripePaymentIntent(
      amount: params.amount,
      currency: params.currency,
    );
  }

  ValidationFailure? _validateParams(CreateStripePaymentIntentParams params) {
    if (params.amount <= 0) {
      return const ValidationFailure('Amount must be greater than 0');
    }

    if (params.amount < 0.50) {
      return ValidationFailure('Minimum amount is ${params.currency} 0.50');
    }

    if (params.amount > 999999) {
      return ValidationFailure('Maximum amount is ${params.currency} 999,999');
    }

    if (params.currency.isEmpty) {
      return const ValidationFailure('Currency is required');
    }

    if (params.currency.length != 3) {
      return const ValidationFailure(
          'Currency must be 3 characters (e.g., USD)');
    }

    return null;
  }
}

class CreateStripePaymentIntentParams {
  const CreateStripePaymentIntentParams({
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  @override
  String toString() {
    return 'CreateStripePaymentIntentParams(amount: $amount, currency: $currency)';
  }
}
