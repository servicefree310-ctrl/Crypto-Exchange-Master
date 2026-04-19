import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/eco_token_entity.dart';
import '../../domain/entities/eco_deposit_address_entity.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';
import '../../domain/repositories/eco_deposit_repository.dart';
import '../datasources/eco_deposit_remote_datasource.dart';
import '../models/eco_token_model.dart';
import '../models/eco_deposit_address_model.dart';
import '../models/eco_deposit_verification_model.dart';

@Injectable(as: EcoDepositRepository)
class EcoDepositRepositoryImpl implements EcoDepositRepository {
  final EcoDepositRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const EcoDepositRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<String>>> getEcoCurrencies() async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final currencies = await _remoteDataSource.fetchEcoCurrencies();
      return Right(currencies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EcoTokenEntity>>> getEcoTokens(
      String currency) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final tokens = await _remoteDataSource.fetchEcoTokens(currency);
      final tokenEntities = tokens.map((token) => token.toEntity()).toList();
      return Right(tokenEntities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EcoDepositAddressEntity>> generatePermitAddress(
    String currency,
    String chain,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final addressModel =
          await _remoteDataSource.generatePermitAddress(currency, chain);
      return Right(addressModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EcoDepositAddressEntity>> generateNoPermitAddress(
    String currency,
    String chain,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final addressModel =
          await _remoteDataSource.generateNoPermitAddress(currency, chain);
      return Right(addressModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EcoDepositAddressEntity>> generateNativeAddress(
    String currency,
    String chain,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final addressModel =
          await _remoteDataSource.generateNativeAddress(currency, chain);
      return Right(addressModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlockAddress(String address) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.unlockAddress(address);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<EcoDepositVerificationEntity> monitorEcoDeposit() {
    return _remoteDataSource
        .connectToEcoWebSocket()
        .map((verification) => verification.toEntity());
  }

  @override
  void startMonitoring({
    required String currency,
    required String chain,
    String? address,
  }) {
    _remoteDataSource.startMonitoring(
      currency: currency,
      chain: chain,
      address: address,
    );
  }

  @override
  void stopMonitoring() {
    _remoteDataSource.dispose();
  }
}
