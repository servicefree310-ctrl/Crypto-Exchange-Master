import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/currency_option_entity.dart';
import '../../domain/entities/transfer_option_entity.dart';
import '../../domain/entities/transfer_request_entity.dart';
import '../../domain/entities/transfer_response_entity.dart';

import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_datasource.dart';
import '../models/transfer_request_model.dart';

@Injectable(as: TransferRepository)
class TransferRepositoryImpl implements TransferRepository {
  const TransferRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final TransferRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  // Real transfer rules from v5 backend
  static const Map<String, List<String>> _validTransfers = {
    'FIAT': ['SPOT', 'ECO'],
    'SPOT': ['FIAT', 'ECO'],
    'ECO': ['FIAT', 'SPOT', 'FUTURES'],
    'FUTURES': ['ECO'], // ONLY ECO!
  };

  @override
  Future<Either<Failure, List<TransferOptionEntity>>>
      getTransferOptions() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getTransferOptions();
      final entities = <TransferOptionEntity>[];
      for (final model in models) {
        entities.add(TransferOptionEntity(
          id: model.id,
          name: model.name,
        ));
      }
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> getTransferCurrencies({
    required String walletType,
    String? targetWalletType,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    // Validate transfer rules
    if (targetWalletType != null) {
      final validTargets = _validTransfers[walletType];
      if (validTargets == null || !validTargets.contains(targetWalletType)) {
        return Left(ValidationFailure(
          'Invalid transfer: $walletType to $targetWalletType is not allowed',
        ));
      }
    }

    try {
      final models = await _remoteDataSource.getCurrencies(
        walletType: walletType,
        targetWalletType: targetWalletType,
      );
      final entities = <CurrencyOptionEntity>[];
      for (final model in models) {
        entities.add(CurrencyOptionEntity(
          value: model.value,
          label: model.label,
          icon: model.icon,
          balance: model.balance,
        ));
      }
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> getWalletBalance({
    required String walletType,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getWalletBalance(
        walletType: walletType,
      );
      final entities = <CurrencyOptionEntity>[];
      for (final model in models) {
        entities.add(CurrencyOptionEntity(
          value: model.value,
          label: model.label,
          icon: model.icon,
          balance: model.balance,
        ));
      }
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateRecipient(
      String uuid) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await _remoteDataSource.validateRecipient(uuid);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransferResponseEntity>> createTransfer(
    TransferRequestEntity request,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    // Validate transfer rules for wallet transfers
    if (request.transferType == 'wallet') {
      final validTargets = _validTransfers[request.fromType];
      if (validTargets == null || !validTargets.contains(request.toType)) {
        return Left(ValidationFailure(
          'Invalid wallet transfer: ${request.fromType} to ${request.toType} is not allowed',
        ));
      }

      // Wallet transfers must be between different wallet types
      if (request.fromType == request.toType) {
        return Left(ValidationFailure(
          'Wallet transfers must be between different wallet types',
        ));
      }
    }

    try {
      final requestModel = TransferRequestModel(
        fromType: request.fromType,
        toType: request.toType,
        fromCurrency: request.fromCurrency,
        toCurrency: request.toCurrency,
        amount: request.amount,
        transferType: request.transferType,
        clientId: request.clientId,
      );

      final responseModel =
          await _remoteDataSource.createTransfer(requestModel);

      // Use the extension method from the model
      final entity = TransferResponseEntity(
        message: responseModel.message,
        fromTransfer: TransferTransactionEntity(
          id: responseModel.fromTransfer.id,
          userId: responseModel.fromTransfer.userId,
          walletId: responseModel.fromTransfer.walletId,
          type: responseModel.fromTransfer.type,
          amount: responseModel.fromTransfer.amount,
          fee: responseModel.fromTransfer.fee,
          status: responseModel.fromTransfer.status,
          description: responseModel.fromTransfer.description,
          metadata: responseModel.fromTransfer.metadata,
          createdAt: responseModel.fromTransfer.createdAt,
          updatedAt: responseModel.fromTransfer.updatedAt,
        ),
        toTransfer: TransferTransactionEntity(
          id: responseModel.toTransfer.id,
          userId: responseModel.toTransfer.userId,
          walletId: responseModel.toTransfer.walletId,
          type: responseModel.toTransfer.type,
          amount: responseModel.toTransfer.amount,
          fee: responseModel.toTransfer.fee,
          status: responseModel.toTransfer.status,
          description: responseModel.toTransfer.description,
          metadata: responseModel.toTransfer.metadata,
          createdAt: responseModel.toTransfer.createdAt,
          updatedAt: responseModel.toTransfer.updatedAt,
        ),
        fromType: responseModel.fromType,
        toType: responseModel.toType,
        fromCurrency: responseModel.fromCurrency,
        toCurrency: responseModel.toCurrency,
      );

      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
