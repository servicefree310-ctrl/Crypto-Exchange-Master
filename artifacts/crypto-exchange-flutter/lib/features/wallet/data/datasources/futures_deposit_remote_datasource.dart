import '../models/eco_deposit_address_model.dart';
import '../models/eco_deposit_verification_model.dart';
import '../models/eco_token_model.dart';

/// Remote data source for FUTURES deposits
/// Reuses ECO infrastructure with FUTURES wallet type
abstract class FuturesDepositRemoteDataSource {
  /// Fetches available FUTURES currencies from the backend
  Future<List<String>> getFuturesCurrencies();

  /// Fetches available tokens for a specific FUTURES currency
  Future<List<EcoTokenModel>> getFuturesTokens(String currency);

  /// Generates a FUTURES wallet address for deposits
  Future<EcoDepositAddressModel> generateFuturesAddress(
    String currency,
    String chain,
    String contractType,
  );

  /// Monitors FUTURES deposits via WebSocket
  Stream<EcoDepositVerificationModel> monitorFuturesDeposit(
    String currency,
    String chain,
    String? address,
  );

  /// Unlocks FUTURES address for NO_PERMIT contract types
  Future<void> unlockFuturesAddress(
    String currency,
    String chain,
    String address,
  );
}
