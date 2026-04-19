import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/deposit_gateway_entity.dart';
import '../entities/deposit_method_entity.dart';
import '../entities/deposit_transaction_entity.dart';
import '../entities/currency_option_entity.dart';

abstract class DepositRepository {
  Future<Either<Failure, List<CurrencyOptionEntity>>> getCurrencyOptions(
      String walletType);
  Future<Either<Failure, List<DepositGatewayEntity>>> getDepositGateways(
      String currency);
  Future<Either<Failure, List<DepositMethodEntity>>> getDepositMethods(
      String currency);
  Future<Either<Failure, DepositTransactionEntity>> createFiatDeposit({
    required String methodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> customFields,
  });
  Future<Either<Failure, Map<String, dynamic>>> createStripePaymentIntent({
    required double amount,
    required String currency,
  });
  Future<Either<Failure, DepositTransactionEntity>> verifyStripePayment({
    required String paymentIntentId,
  });

  // PayPal methods
  Future<Either<Failure, Map<String, dynamic>>> createPayPalOrder({
    required double amount,
    required String currency,
  });

  Future<Either<Failure, DepositTransactionEntity>> verifyPayPalPayment({
    required String orderId,
  });
}
