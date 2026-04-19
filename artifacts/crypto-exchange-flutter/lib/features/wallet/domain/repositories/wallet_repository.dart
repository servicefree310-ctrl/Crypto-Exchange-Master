import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  /// Get all wallets grouped by type
  Future<Either<Failure, Map<WalletType, List<WalletEntity>>>> getWallets();

  /// Get wallets by specific type
  Future<Either<Failure, List<WalletEntity>>> getWalletsByType(WalletType type);

  /// Get specific wallet by type and currency
  Future<Either<Failure, WalletEntity>> getWallet(
      WalletType type, String currency);

  /// Get wallet by ID
  Future<Either<Failure, WalletEntity>> getWalletById(String walletId);

  /// Update wallet balance (for real-time updates)
  Future<Either<Failure, WalletEntity>> updateWalletBalance(
      String walletId, double newBalance);

  /// Create new wallet
  Future<Either<Failure, WalletEntity>> createWallet(
      WalletType type, String currency);

  /// Transfer funds between wallets
  Future<Either<Failure, Map<String, dynamic>>> transferFunds({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  });

  /// Transfer funds to another user (P2P)
  Future<Either<Failure, Map<String, dynamic>>> transferToUser({
    required String fromWalletId,
    required String recipientUserId,
    required double amount,
    String? description,
  });

  /// Get wallet total balance in USD
  Future<Either<Failure, double>> getTotalBalanceUSD();

  /// Get wallet performance data
  Future<Either<Failure, Map<String, dynamic>>> getWalletPerformance();

  /// Refresh wallet data from server
  Future<Either<Failure, Map<WalletType, List<WalletEntity>>>> refreshWallets();

  /// Get balances for both currency and pair using symbol endpoint
  Future<Either<Failure, Map<String, double>>> getSymbolBalances({
    required String type,
    required String currency,
    required String pair,
  });

  Future<Either<Failure, Map<String, dynamic>>> getDashboard();
  Future<Either<Failure, WalletEntity>> getWalletByTypeCurrency(
      String type, String currency);
}
