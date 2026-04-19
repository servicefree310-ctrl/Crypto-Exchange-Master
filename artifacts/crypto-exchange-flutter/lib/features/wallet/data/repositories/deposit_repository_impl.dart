import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/deposit_gateway_entity.dart';
import '../../domain/entities/deposit_method_entity.dart';
import '../../domain/entities/deposit_transaction_entity.dart';
import '../../domain/entities/currency_option_entity.dart';
import '../../domain/repositories/deposit_repository.dart';
import '../datasources/deposit_remote_datasource.dart';
import '../models/deposit_gateway_model.dart';
import '../models/deposit_method_model.dart';
import '../models/deposit_transaction_model.dart';

@Injectable(as: DepositRepository)
class DepositRepositoryImpl implements DepositRepository {
  const DepositRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final DepositRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> getCurrencyOptions(
      String walletType) async {
    dev.log('🔵 DEPOSIT_REPO: Getting currency options for $walletType');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final currencyModels =
          await _remoteDataSource.fetchCurrencyOptions(walletType);
      final currencies =
          currencyModels.map((model) => model.toEntity()).toList();

      dev.log(
          '🟢 DEPOSIT_REPO: Successfully fetched ${currencies.length} currency options');
      return Right(currencies);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error fetching currency options: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DepositGatewayEntity>>> getDepositGateways(
      String currency) async {
    dev.log('🔵 DEPOSIT_REPO: Getting deposit gateways for $currency');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await _remoteDataSource.fetchDepositMethods(currency);
      final gatewayModels = result['gateways'] as List<DepositGatewayModel>;
      final gateways = gatewayModels.map((model) => model.toEntity()).toList();

      dev.log(
          '🟢 DEPOSIT_REPO: Successfully fetched ${gateways.length} gateways');
      return Right(gateways);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error fetching gateways: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DepositMethodEntity>>> getDepositMethods(
      String currency) async {
    dev.log('🔵 DEPOSIT_REPO: Getting deposit methods for $currency');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await _remoteDataSource.fetchDepositMethods(currency);
      final methodModels = result['methods'] as List<DepositMethodModel>;
      final methods = methodModels.map((model) => model.toEntity()).toList();

      dev.log('🟢 DEPOSIT_REPO: Successfully fetched ${methods.length} methods');
      return Right(methods);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error fetching methods: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DepositTransactionEntity>> createFiatDeposit({
    required String methodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> customFields,
  }) async {
    dev.log('🔵 DEPOSIT_REPO: Creating FIAT deposit');
    dev.log(
        '🔵 DEPOSIT_REPO: Method: $methodId, Amount: $amount, Currency: $currency');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final transactionModel = await _remoteDataSource.createFiatDeposit(
        methodId: methodId,
        amount: amount,
        currency: currency,
        customFields: customFields,
      );

      final transaction = transactionModel.toEntity();
      dev.log('🟢 DEPOSIT_REPO: Successfully created deposit: ${transaction.id}');
      return Right(transaction);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error creating deposit: $e');

      // Handle specific error cases
      if (e.toString().contains('Unauthorized')) {
        return Left(AuthFailure('Authentication failed'));
      } else if (e.toString().contains('validation') ||
          e.toString().contains('invalid')) {
        return Left(ValidationFailure(e.toString()));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createStripePaymentIntent({
    required double amount,
    required String currency,
  }) async {
    dev.log(
        '🔵 DEPOSIT_REPO: Creating Stripe payment intent for $amount $currency');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final paymentIntentData =
          await _remoteDataSource.createStripePaymentIntent(
        amount: amount,
        currency: currency,
      );

      dev.log('🟢 DEPOSIT_REPO: Successfully created Stripe payment intent');
      return Right(paymentIntentData);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error creating Stripe payment intent: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DepositTransactionEntity>> verifyStripePayment({
    required String paymentIntentId,
  }) async {
    dev.log(
        '🔵 DEPOSIT_REPO: Verifying Stripe payment for intent: $paymentIntentId');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final transactionModel = await _remoteDataSource.verifyStripePayment(
        paymentIntentId: paymentIntentId,
      );
      final transaction = transactionModel.toEntity();

      dev.log('🟢 DEPOSIT_REPO: Successfully verified Stripe payment');
      return Right(transaction);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error verifying Stripe payment: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createPayPalOrder({
    required double amount,
    required String currency,
  }) async {
    dev.log('🔵 DEPOSIT_REPO: Creating PayPal order for $amount $currency');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final orderData = await _remoteDataSource.createPayPalOrder(
        amount: amount,
        currency: currency,
      );

      dev.log('🟢 DEPOSIT_REPO: Successfully created PayPal order');
      return Right(orderData);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error creating PayPal order: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DepositTransactionEntity>> verifyPayPalPayment({
    required String orderId,
  }) async {
    dev.log('🔵 DEPOSIT_REPO: Verifying PayPal payment for order: $orderId');

    if (!await _networkInfo.isConnected) {
      dev.log('🔴 DEPOSIT_REPO: No network connection');
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final transactionModel = await _remoteDataSource.verifyPayPalPayment(
        orderId: orderId,
      );
      final transaction = transactionModel.toEntity();

      dev.log('🟢 DEPOSIT_REPO: Successfully verified PayPal payment');
      return Right(transaction);
    } catch (e) {
      dev.log('🔴 DEPOSIT_REPO: Error verifying PayPal payment: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
