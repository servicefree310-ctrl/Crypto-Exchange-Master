import 'package:dartz/dartz.dart';
import '../entities/eco_deposit_address_entity.dart';
import '../entities/eco_deposit_verification_entity.dart';
import '../entities/eco_token_entity.dart';
import '../../../../core/errors/failures.dart';

/// Repository interface for FUTURES deposits
/// Uses ECO entities since backend infrastructure is shared
abstract class FuturesDepositRepository {
  /// Fetches available FUTURES currencies
  Future<Either<Failure, List<EcoTokenEntity>>> getFuturesCurrencies();

  /// Fetches available tokens for a specific FUTURES currency
  Future<Either<Failure, List<EcoTokenEntity>>> getFuturesTokens(
      String currency);

  /// Generates a FUTURES wallet address for deposits
  Future<Either<Failure, EcoDepositAddressEntity>> generateFuturesAddress(
    String currency,
    String chain,
    String contractType,
  );

  /// Monitors FUTURES deposits via WebSocket
  Stream<EcoDepositVerificationEntity> monitorFuturesDeposit(
    String currency,
    String chain,
    String? address,
  );

  /// Unlocks FUTURES address for NO_PERMIT contract types
  Future<Either<Failure, void>> unlockFuturesAddress(
    String currency,
    String chain,
    String address,
  );
}
