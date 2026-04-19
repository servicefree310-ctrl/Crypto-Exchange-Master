import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';
import '../datasources/wallet_cache_datasource.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final WalletCacheDataSource cacheDataSource;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<WalletType, List<WalletEntity>>>>
      getWallets() async {
    try {
      dev.log('🔵 WALLET_REPO: Getting wallets...');

      // Check if we're online
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Fetch from remote
          dev.log('🔵 WALLET_REPO: Fetching from remote (online)');
          final remoteWallets = await remoteDataSource.getWallets();

          // Convert models to entities and String keys to WalletType
          final Map<WalletType, List<WalletEntity>> walletsMap = {};
          dev.log(
              '🔵 WALLET_REPO: Starting conversion of ${remoteWallets.length} wallet types');

          for (final entry in remoteWallets.entries) {
            final typeString = entry.key;
            final models = entry.value;
            dev.log(
                '🔵 WALLET_REPO: Processing $typeString with ${models.length} models');

            final walletType = _parseWalletType(typeString);
            dev.log('🔵 WALLET_REPO: Converted "$typeString" to $walletType');

            final entities = <WalletEntity>[];
            for (final model in models) {
              dev.log(
                  '🔵 WALLET_REPO: Converting model: ${model.currency} (${model.balance})');
              final entity = model.toEntity();
              entities.add(entity);
              dev.log(
                  '🔵 WALLET_REPO: Added entity: ${entity.currency} (${entity.balance})');
            }

            walletsMap[walletType] = entities;
            dev.log(
                '🔵 WALLET_REPO: Stored ${entities.length} entities for $walletType');
          }

          dev.log(
              '🔵 WALLET_REPO: Final wallet map has ${walletsMap.length} types');
          for (final entry in walletsMap.entries) {
            dev.log(
                '🔵 WALLET_REPO: ${entry.key}: ${entry.value.length} wallets');
          }

          // Cache the results
          await cacheDataSource.cacheWallets(remoteWallets);
          dev.log(
              '🔵 WALLET_REPO: Remote wallets fetched and cached successfully');

          return Right(walletsMap);
        } catch (e) {
          dev.log(
              '🔴 WALLET_REPO: Remote fetch failed, falling back to cache: $e');

          // If remote fails, try to get from cache
          final cachedWallets = await cacheDataSource.getCachedWallets();
          if (cachedWallets != null) {
            final Map<WalletType, List<WalletEntity>> walletsMap = {};
            for (final entry in cachedWallets.entries) {
              final walletType = _parseWalletType(entry.key);
              walletsMap[walletType] =
                  entry.value.map((model) => model as WalletEntity).toList();
            }
            dev.log(
                '🔵 WALLET_REPO: Returned cached wallets after remote failure');
            return Right(walletsMap);
          }

          // If both remote and cache fail, return server failure
          return Left(ServerFailure('Failed to get wallets: $e'));
        }
      } else {
        // We're offline, try cache first
        dev.log('🔵 WALLET_REPO: Offline - checking cache');
        final cachedWallets = await cacheDataSource.getCachedWallets();

        if (cachedWallets != null) {
          final Map<WalletType, List<WalletEntity>> walletsMap = {};
          for (final entry in cachedWallets.entries) {
            final walletType = _parseWalletType(entry.key);
            walletsMap[walletType] =
                entry.value.map((model) => model as WalletEntity).toList();
          }
          dev.log('🔵 WALLET_REPO: Returned cached wallets (offline)');
          return Right(walletsMap);
        }

        return Left(NetworkFailure(
            'No internet connection and no cached data available'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in getWallets: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WalletEntity>>> getWalletsByType(
      WalletType type) async {
    try {
      dev.log('🔵 WALLET_REPO: Getting ${type.name} wallets...');

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteWallets =
              await remoteDataSource.getWalletsByType(type.name);
          final wallets =
              remoteWallets.map((model) => model as WalletEntity).toList();

          // Cache individual wallets
          for (final wallet in remoteWallets) {
            await cacheDataSource.cacheWallet(wallet);
          }

          dev.log('🔵 WALLET_REPO: ${type.name} wallets fetched and cached');
          return Right(wallets);
        } catch (e) {
          dev.log(
              '🔴 WALLET_REPO: Remote fetch failed for ${type.name}, trying cache: $e');

          // Fallback to cache
          final cachedWallets = await cacheDataSource.getCachedWallets();
          if (cachedWallets != null && cachedWallets.containsKey(type.name)) {
            final wallets = cachedWallets[type.name]!
                .map((model) => model as WalletEntity)
                .toList();
            return Right(wallets);
          }

          return Left(ServerFailure('Failed to get ${type.name} wallets: $e'));
        }
      } else {
        // Offline - try cache
        final cachedWallets = await cacheDataSource.getCachedWallets();
        if (cachedWallets != null && cachedWallets.containsKey(type.name)) {
          final wallets = cachedWallets[type.name]!
              .map((model) => model as WalletEntity)
              .toList();
          dev.log(
              '🔵 WALLET_REPO: Returned cached ${type.name} wallets (offline)');
          return Right(wallets);
        }

        return Left(NetworkFailure(
            'No internet connection and no cached ${type.name} wallets'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in getWalletsByType: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWallet(
      WalletType type, String currency) async {
    try {
      dev.log('🔵 WALLET_REPO: Getting ${type.name} wallet for $currency');

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteWallet =
              await remoteDataSource.getWallet(type.name, currency);
          await cacheDataSource.cacheWallet(remoteWallet);

          dev.log(
              '🔵 WALLET_REPO: Wallet fetched and cached: ${remoteWallet.id}');
          return Right(remoteWallet);
        } catch (e) {
          dev.log('🔴 WALLET_REPO: Remote fetch failed, trying cache: $e');

          // Try to find in cache
          final cachedWallets = await cacheDataSource.getCachedWallets();
          if (cachedWallets != null && cachedWallets.containsKey(type.name)) {
            final wallet = cachedWallets[type.name]!
                .where((w) => w.currency == currency)
                .firstOrNull;

            if (wallet != null) {
              return Right(wallet);
            }
          }

          return Left(ServerFailure('Failed to get wallet: $e'));
        }
      } else {
        // Offline - check cache
        final cachedWallets = await cacheDataSource.getCachedWallets();
        if (cachedWallets != null && cachedWallets.containsKey(type.name)) {
          final wallet = cachedWallets[type.name]!
              .where((w) => w.currency == currency)
              .firstOrNull;

          if (wallet != null) {
            dev.log(
                '🔵 WALLET_REPO: Found cached wallet (offline): ${wallet.id}');
            return Right(wallet);
          }
        }

        return Left(NetworkFailure(
            'No internet connection and wallet not found in cache'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in getWallet: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletById(String walletId) async {
    try {
      dev.log('🔵 WALLET_REPO: Getting wallet by ID: $walletId');

      // First check cache (it's faster for individual wallets)
      final cachedWallet = await cacheDataSource.getCachedWallet(walletId);

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteWallet = await remoteDataSource.getWalletById(walletId);
          await cacheDataSource.cacheWallet(remoteWallet);

          dev.log(
              '🔵 WALLET_REPO: Wallet fetched by ID and cached: ${remoteWallet.id}');
          return Right(remoteWallet);
        } catch (e) {
          dev.log('🔴 WALLET_REPO: Remote fetch by ID failed, using cache: $e');

          if (cachedWallet != null) {
            return Right(cachedWallet);
          }

          return Left(ServerFailure('Failed to get wallet by ID: $e'));
        }
      } else {
        // Offline
        if (cachedWallet != null) {
          dev.log(
              '🔵 WALLET_REPO: Found cached wallet by ID (offline): $walletId');
          return Right(cachedWallet);
        }

        return Left(NetworkFailure(
            'No internet connection and wallet not found in cache'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in getWalletById: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> updateWalletBalance(
      String walletId, double newBalance) async {
    try {
      dev.log(
          '🔵 WALLET_REPO: Updating wallet balance: $walletId -> $newBalance');

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final updatedWallet =
              await remoteDataSource.updateWalletBalance(walletId, newBalance);
          await cacheDataSource.cacheWallet(updatedWallet);

          dev.log('🔵 WALLET_REPO: Wallet balance updated and cached');
          return Right(updatedWallet);
        } catch (e) {
          return Left(ServerFailure('Failed to update wallet balance: $e'));
        }
      } else {
        // For offline, we can update cache optimistically
        try {
          await cacheDataSource.updateCachedWalletBalance(walletId, newBalance);
          final updatedWallet = await cacheDataSource.getCachedWallet(walletId);

          if (updatedWallet != null) {
            dev.log('🔵 WALLET_REPO: Wallet balance updated in cache (offline)');
            return Right(updatedWallet);
          }

          return Left(CacheFailure('Failed to update wallet balance in cache'));
        } catch (e) {
          return Left(CacheFailure('Error updating cached wallet balance: $e'));
        }
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in updateWalletBalance: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> createWallet(
      WalletType type, String currency) async {
    try {
      dev.log('🔵 WALLET_REPO: Creating ${type.name} wallet for $currency');

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return Left(
            NetworkFailure('No internet connection - cannot create wallet'));
      }

      try {
        final newWallet =
            await remoteDataSource.createWallet(type.name, currency);
        await cacheDataSource.cacheWallet(newWallet);

        dev.log('🔵 WALLET_REPO: Wallet created and cached: ${newWallet.id}');
        return Right(newWallet);
      } catch (e) {
        return Left(ServerFailure('Failed to create wallet: $e'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in createWallet: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> transferFunds({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  }) async {
    try {
      dev.log(
          '🔵 WALLET_REPO: Transferring funds: $amount from $fromWalletId to $toWalletId');

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return Left(
            NetworkFailure('No internet connection - cannot transfer funds'));
      }

      try {
        final result = await remoteDataSource.transferFunds(
          fromWalletId: fromWalletId,
          toWalletId: toWalletId,
          amount: amount,
          description: description,
        );

        // Clear wallet cache to force refresh
        await cacheDataSource.clearWalletCache();

        dev.log('🔵 WALLET_REPO: Funds transferred successfully');
        return Right(result);
      } catch (e) {
        return Left(ServerFailure('Failed to transfer funds: $e'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in transferFunds: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> transferToUser({
    required String fromWalletId,
    required String recipientUserId,
    required double amount,
    String? description,
  }) async {
    try {
      dev.log(
          '🔵 WALLET_REPO: Transferring to user: $amount to $recipientUserId');

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return Left(
            NetworkFailure('No internet connection - cannot transfer to user'));
      }

      try {
        final result = await remoteDataSource.transferToUser(
          fromWalletId: fromWalletId,
          recipientUserId: recipientUserId,
          amount: amount,
          description: description,
        );

        // Clear wallet cache to force refresh
        await cacheDataSource.clearWalletCache();

        dev.log('🔵 WALLET_REPO: Transfer to user completed successfully');
        return Right(result);
      } catch (e) {
        return Left(ServerFailure('Failed to transfer to user: $e'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in transferToUser: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWalletPerformance() async {
    try {
      dev.log('🔵 WALLET_REPO: Getting wallet performance data');

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return Left(NetworkFailure(
            'No internet connection - cannot fetch performance data'));
      }

      try {
        final performance = await remoteDataSource.getWalletPerformance();

        dev.log('🔵 WALLET_REPO: Wallet performance data fetched successfully');
        return Right(performance);
      } catch (e) {
        return Left(ServerFailure('Failed to get wallet performance: $e'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in getWalletPerformance: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalBalanceUSD() async {
    try {
      dev.log('🔵 WALLET_REPO: Getting total balance in USD');

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return Left(NetworkFailure(
            'No internet connection - cannot fetch total balance'));
      }

      try {
        final totalBalance = await remoteDataSource.getTotalBalanceUSD();

        dev.log('🔵 WALLET_REPO: Total balance USD fetched: \$$totalBalance');
        return Right(totalBalance);
      } catch (e) {
        return Left(ServerFailure('Failed to get total balance USD: $e'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in getTotalBalanceUSD: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<WalletType, List<WalletEntity>>>>
      refreshWallets() async {
    try {
      dev.log('🔵 WALLET_REPO: Refreshing wallet data');

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return Left(
            NetworkFailure('No internet connection - cannot refresh wallets'));
      }

      try {
        // Clear cache first
        await cacheDataSource.clearWalletCache();

        // Fetch fresh data
        final walletsData = await remoteDataSource.getWallets();

        // Convert String keys to WalletType keys
        final Map<WalletType, List<WalletEntity>> convertedWallets = {};
        for (final entry in walletsData.entries) {
          final walletType = _parseWalletType(entry.key);
          convertedWallets[walletType] =
              entry.value.map((model) => model as WalletEntity).toList();
        }

        // Cache the fresh data
        await cacheDataSource.cacheWallets(walletsData);

        dev.log('🔵 WALLET_REPO: Wallets refreshed and cached successfully');
        return Right(convertedWallets);
      } catch (e) {
        return Left(ServerFailure('Failed to refresh wallets: $e'));
      }
    } catch (e) {
      dev.log('🔴 WALLET_REPO: Unexpected error in refreshWallets: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getSymbolBalances({
    required String type,
    required String currency,
    required String pair,
  }) async {
    try {
      final response = await remoteDataSource.getSymbolBalances(
        type: type,
        currency: currency,
        pair: pair,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboard() async {
    try {
      // For now, return empty dashboard data
      // TODO: Implement getWalletDashboard in WalletRemoteDataSource
      final response = <String, dynamic>{};
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletByTypeCurrency(
      String type, String currency) async {
    // Convert string type to WalletType enum
    final walletType = _parseWalletType(type);
    return getWallet(walletType, currency);
  }

  // Helper method to parse string to WalletType enum
  WalletType _parseWalletType(String type) {
    switch (type.toUpperCase()) {
      case 'SPOT':
        return WalletType.SPOT;
      case 'FIAT':
        return WalletType.FIAT;
      case 'ECO':
        return WalletType.ECO;
      case 'FUTURES':
        return WalletType.FUTURES;
      default:
        return WalletType.SPOT;
    }
  }
}
