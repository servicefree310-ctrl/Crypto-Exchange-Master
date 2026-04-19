import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/spot_currency_entity.dart';
import '../../domain/entities/spot_network_entity.dart';
import '../../domain/entities/spot_deposit_address_entity.dart';
import '../../domain/entities/spot_deposit_transaction_entity.dart';
import '../../domain/entities/spot_deposit_verification_result.dart';
import '../../domain/repositories/spot_deposit_repository.dart';
import '../datasources/spot_deposit_remote_datasource.dart';
import '../models/spot_currency_model.dart';
import '../models/spot_network_model.dart';
import '../models/spot_deposit_address_model.dart';
import '../models/spot_deposit_transaction_model.dart';

@Injectable(as: SpotDepositRepository)
class SpotDepositRepositoryImpl implements SpotDepositRepository {
  final SpotDepositRemoteDataSource _remoteDataSource;

  const SpotDepositRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<SpotCurrencyEntity>>> getSpotCurrencies() async {
    try {
      final currencies = await _remoteDataSource.fetchSpotCurrencies();
      return Right(currencies
          .map((model) => model.toEntity())
          .toList()
          .cast<SpotCurrencyEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SpotNetworkEntity>>> getSpotNetworks(
    String currency,
  ) async {
    try {
      final networks = await _remoteDataSource.fetchSpotNetworks(currency);
      return Right(networks
          .map((model) => model.toEntity())
          .toList()
          .cast<SpotNetworkEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TypeError {
      // Handle type casting errors (null is not subtype of num)
      // This usually happens when trying to load SPOT networks for fiat currencies
      return Left(ServerFailure(
          '$currency is not available for SPOT deposits. Please select a different cryptocurrency.'));
    } catch (e) {
      return Left(ServerFailure(
          'No networks available for $currency. Please try a different currency.'));
    }
  }

  @override
  Future<Either<Failure, SpotDepositAddressEntity>> generateDepositAddress(
    String currency,
    String network,
  ) async {
    try {
      final address = await _remoteDataSource.generateSpotDepositAddress(
        currency: currency,
        network: network,
      );
      return Right(address.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SpotDepositTransactionEntity>> createSpotDeposit(
    String currency,
    String chain,
    String transactionHash,
  ) async {
    try {
      final transaction = await _remoteDataSource.createSpotDeposit(
        currency: currency,
        chain: chain,
        transactionHash: transactionHash,
      );
      return Right(transaction.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<SpotDepositVerificationResult> verifySpotDeposit(
    String transactionId,
  ) {
    return _remoteDataSource
        .connectToVerificationStream(transactionId)
        .map((data) {
      try {
        // The data is already the verification data from the filtered WebSocket message
        final status = _parseInteger(data['status']) ?? 500;
        final message = data['message']?.toString() ?? 'Unknown error';

        // Handle successful completion
        if (status == 200 || status == 201) {
          final transactionData = data['transaction'] as Map<String, dynamic>?;
          final balance = _parseDouble(data['balance']);
          final currency = data['currency']?.toString();
          final chain = data['chain']?.toString();
          final method = data['method']?.toString();

          SpotDepositTransactionEntity? transaction;
          if (transactionData != null) {
            // Convert transaction data to entity with safe parsing
            transaction = SpotDepositTransactionEntity(
              id: transactionData['id']?.toString() ?? '',
              userId: transactionData['userId']?.toString() ?? '',
              walletId: transactionData['walletId']?.toString() ?? '',
              type: transactionData['type']?.toString() ?? 'DEPOSIT',
              amount: _parseDouble(transactionData['amount']) ?? 0.0,
              status: transactionData['status']?.toString() ?? 'COMPLETED',
              currency: currency ?? '',
              chain: chain ?? '',
              referenceId: transactionData['referenceId']?.toString() ?? '',
              metadata: transactionData['metadata'] as Map<String, dynamic>?,
              description: transactionData['description']?.toString(),
              createdAt: _parseDateTime(transactionData['createdAt']) ??
                  DateTime.now(),
            );
          }

          return SpotDepositVerificationResult(
            status: status,
            message: message,
            transaction: transaction,
            balance: balance,
            currency: currency,
            chain: chain,
            method: method,
          );
        }

        return SpotDepositVerificationResult(
          status: status,
          message: message,
        );
      } catch (e) {
        return SpotDepositVerificationResult(
          status: 500,
          message: 'Error parsing verification result: ${e.toString()}',
        );
      }
    }).handleError((error) {
      return SpotDepositVerificationResult(
        status: 500,
        message: 'WebSocket error: ${error.toString()}',
      );
    });
  }

  /// Safely parse a value to double
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  /// Safely parse a value to integer
  int? _parseInteger(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  /// Safely parse a DateTime from various formats
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
