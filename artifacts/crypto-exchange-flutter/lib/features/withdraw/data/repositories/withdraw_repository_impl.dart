import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../transfer/domain/entities/currency_option_entity.dart';
import '../../../transfer/data/models/currency_option_model.dart';
import '../../domain/entities/withdraw_method_entity.dart';
import '../../domain/entities/withdraw_request_entity.dart';
import '../../domain/entities/withdraw_response_entity.dart';
import '../../domain/repositories/withdraw_repository.dart';
import '../datasources/withdraw_remote_datasource.dart';
import '../models/withdraw_request_model.dart';
import '../models/withdraw_method_model.dart';
import '../models/withdraw_response_model.dart';

@Injectable(as: WithdrawRepository)
class WithdrawRepositoryImpl implements WithdrawRepository {
  final WithdrawRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const WithdrawRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> getWithdrawCurrencies({
    required String walletType,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getWithdrawCurrencies(
        walletType: walletType,
      );

      final entities = models.map((model) => model.toEntity()).toList();

      // Filter out currencies with zero balance
      final validCurrencies = entities.where((currency) {
        return currency.balance != null && currency.balance! > 0;
      }).toList();

      // Return empty list instead of failure when no currencies available
      // This allows checking multiple wallet types

      return Right(validCurrencies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WithdrawMethodEntity>>> getWithdrawMethods({
    required String walletType,
    required String currency,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getWithdrawMethods(
        walletType: walletType,
        currency: currency,
      );

      final entities = models.map((model) => model.toEntity()).toList();

      // Filter only active methods
      final activeMethods =
          entities.where((method) => method.isActive).toList();

      if (activeMethods.isEmpty) {
        return Left(
            ValidationFailure('No withdrawal methods available for $currency'));
      }

      return Right(activeMethods);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WithdrawResponseEntity>> submitWithdrawal(
    WithdrawRequestEntity request,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final requestModel = request.toModel();
      final responseModel =
          await _remoteDataSource.submitWithdrawal(requestModel);

      return Right(responseModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
