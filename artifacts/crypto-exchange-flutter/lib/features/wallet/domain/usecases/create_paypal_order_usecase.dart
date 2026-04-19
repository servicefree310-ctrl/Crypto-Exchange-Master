import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/deposit_repository.dart';

class CreatePayPalOrderParams {
  final double amount;
  final String currency;

  const CreatePayPalOrderParams({
    required this.amount,
    required this.currency,
  });
}

@injectable
class CreatePayPalOrderUseCase
    implements UseCase<Map<String, dynamic>, CreatePayPalOrderParams> {
  const CreatePayPalOrderUseCase(this._repository);

  final DepositRepository _repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      CreatePayPalOrderParams params) async {
    dev.log('🔵 CREATE_PAYPAL_ORDER_UC: Creating PayPal order');
    dev.log(
        '🔵 CREATE_PAYPAL_ORDER_UC: Amount: ${params.amount}, Currency: ${params.currency}');

    // Validate input
    if (params.amount <= 0) {
      dev.log('🔴 CREATE_PAYPAL_ORDER_UC: Invalid amount');
      return Left(ValidationFailure('Amount must be greater than 0'));
    }

    if (params.currency.isEmpty) {
      dev.log('🔴 CREATE_PAYPAL_ORDER_UC: Invalid currency');
      return Left(ValidationFailure('Currency is required'));
    }

    final result = await _repository.createPayPalOrder(
      amount: params.amount,
      currency: params.currency,
    );

    return result.fold(
      (failure) {
        dev.log(
            '🔴 CREATE_PAYPAL_ORDER_UC: Failed to create PayPal order: $failure');
        return Left(failure);
      },
      (orderData) {
        dev.log('🟢 CREATE_PAYPAL_ORDER_UC: PayPal order created successfully');
        return Right(orderData);
      },
    );
  }
}
