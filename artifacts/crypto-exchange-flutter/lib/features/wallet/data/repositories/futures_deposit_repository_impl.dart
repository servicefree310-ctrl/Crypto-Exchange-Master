import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/futures_deposit_repository.dart';
import '../../domain/entities/eco_deposit_address_entity.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';
import '../../domain/entities/eco_token_entity.dart';
import '../datasources/futures_deposit_remote_datasource.dart';
import '../models/eco_token_model.dart';
import '../models/eco_deposit_address_model.dart';
import '../models/eco_deposit_verification_model.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';

@Injectable(as: FuturesDepositRepository)
class FuturesDepositRepositoryImpl implements FuturesDepositRepository {
  final FuturesDepositRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const FuturesDepositRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<EcoTokenEntity>>> getFuturesCurrencies() async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final currencies = await _remoteDataSource.getFuturesCurrencies();

      // Convert string list to EcoTokenEntity list for consistency
      final entities = currencies
          .map((currency) => EcoTokenEntity(
                currency: currency,
                chain: 'FUTURES', // Default chain for initial display
                name: currency.toUpperCase(),
                contractType:
                    'UNKNOWN', // Will be determined when fetching tokens
                limits: EcoLimitsEntity(
                  deposit: EcoDepositLimitsEntity(min: 0.0, max: 999999999.0),
                  withdraw: EcoWithdrawLimitsEntity(min: 0.0, max: 999999999.0),
                ),
                fee: EcoFeeEntity(
                  percentage: 0.0,
                  min: 0.0,
                ),
                status: true,
                icon: '/img/crypto/${currency.toLowerCase()}.webp',
              ))
          .toList();

      return Right(entities);
    } catch (e) {
      dev.log('❌ FUTURES_REPO: Error fetching currencies: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EcoTokenEntity>>> getFuturesTokens(
      String currency) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final tokens = await _remoteDataSource.getFuturesTokens(currency);
      final entities = tokens.map((model) => model.toEntity()).toList();

      if (entities.isEmpty) {
        return Left(ServerFailure('No tokens available for $currency'));
      }

      return Right(entities);
    } catch (e) {
      dev.log('❌ FUTURES_REPO: Error fetching tokens for $currency: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EcoDepositAddressEntity>> generateFuturesAddress(
    String currency,
    String chain,
    String contractType,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final addressModel = await _remoteDataSource.generateFuturesAddress(
        currency,
        chain,
        contractType,
      );

      return Right(addressModel.toEntity());
    } catch (e) {
      dev.log('❌ FUTURES_REPO: Error generating address: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<EcoDepositVerificationEntity> monitorFuturesDeposit(
    String currency,
    String chain,
    String? address,
  ) {
    try {
      return _remoteDataSource
          .monitorFuturesDeposit(currency, chain, address)
          .map((model) => model.toEntity());
    } catch (e) {
      dev.log('❌ FUTURES_REPO: Error monitoring deposit: $e');
      // Return error stream
      return Stream.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlockFuturesAddress(
    String currency,
    String chain,
    String address,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.unlockFuturesAddress(currency, chain, address);
      return const Right(null);
    } catch (e) {
      dev.log('❌ FUTURES_REPO: Error unlocking address: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
