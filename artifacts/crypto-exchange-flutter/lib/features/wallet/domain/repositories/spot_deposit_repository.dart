import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/spot_currency_entity.dart';
import '../entities/spot_network_entity.dart';
import '../entities/spot_deposit_address_entity.dart';
import '../entities/spot_deposit_transaction_entity.dart';
import '../entities/spot_deposit_verification_result.dart';

abstract class SpotDepositRepository {
  Future<Either<Failure, List<SpotCurrencyEntity>>> getSpotCurrencies();

  Future<Either<Failure, List<SpotNetworkEntity>>> getSpotNetworks(
    String currency,
  );

  Future<Either<Failure, SpotDepositAddressEntity>> generateDepositAddress(
    String currency,
    String network,
  );

  Future<Either<Failure, SpotDepositTransactionEntity>> createSpotDeposit(
    String currency,
    String chain,
    String transactionHash,
  );

  Stream<SpotDepositVerificationResult> verifySpotDeposit(
    String transactionId,
  );
}
